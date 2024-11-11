// ignore_for_file: library_private_types_in_public_api, deprecated_member_use, use_build_context_synchronously, avoid_print

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

void main() {
  runApp(MaterialApp(home: NearbyLocationsMap()));
}

class SalonLocation {
  final String id;
  final String name;
  final GeoPoint location;
  final double distance;

  SalonLocation({
    required this.id,
    required this.name,
    required this.location,
    required this.distance,
  });
}

class NearbyLocationsMap extends StatefulWidget {
  const NearbyLocationsMap({super.key});

  @override
  _NearbyLocationsMapState createState() => _NearbyLocationsMapState();
}

class _NearbyLocationsMapState extends State<NearbyLocationsMap> {
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  List<SalonLocation> _nearbySalons = [];
  bool _isLoading = false;
  Position? _currentPosition;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _isLoading = true);
    try {
      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        final request = await Geolocator.requestPermission();
        if (request == LocationPermission.denied) {
          throw Exception('Location permission denied');
        }
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _currentPosition = position;
      });

      _loadNearbySalons();

      if (_mapController != null) {
        _mapController!.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: LatLng(position.latitude, position.longitude),
              zoom: 14,
            ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error getting location: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadNearbySalons() async {
    if (_currentPosition == null) return;

    setState(() => _isLoading = true);
    try {
      final userLocation = GeoPoint(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
      );

      // Query Firestore for nearby salons
      final querySnapshot =
          await FirebaseFirestore.instance.collection('salons').get();

      _nearbySalons.clear();
      _markers.clear();

      // Add marker for current location
      _markers.add(
        Marker(
          markerId: MarkerId('current_location'),
          position:
              LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          infoWindow: InfoWindow(title: 'Your Location'),
        ),
      );

      // Process each salon
      for (var doc in querySnapshot.docs) {
        final GeoPoint salonLocation = doc['location'];
        print(salonLocation.latitude);
        print(salonLocation.longitude);
        final double distance = Geolocator.distanceBetween(
          userLocation.latitude,
          userLocation.longitude,
          salonLocation.latitude,
          salonLocation.longitude,
        );
        print(distance);
        // Only include salons within 5km
        if (distance <= 5000) {
          final salon = SalonLocation(
            id: doc.id,
            name: doc['name'],
            location: salonLocation,
            distance: distance,
          );

          _nearbySalons.add(salon);

          // Add marker for salon
          _markers.add(
            Marker(
              markerId: MarkerId(doc.id),
              position: LatLng(salonLocation.latitude, salonLocation.longitude),
              infoWindow: InfoWindow(
                title: doc['name'],
                snippet: '${(distance / 1000).toStringAsFixed(2)} km away',
              ),
            ),
          );
        }
      }

      // Sort salons by distance
      _nearbySalons.sort((a, b) => a.distance.compareTo(b.distance));

      setState(() {});
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading salons: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Nearby Salons'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _getCurrentLocation,
          ),
        ],
      ),
      body: Stack(
        children: [
          // Map
          _currentPosition == null
              ? Center(child: Text('Getting location...'))
              : GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: LatLng(
                      _currentPosition!.latitude,
                      _currentPosition!.longitude,
                    ),
                    zoom: 14,
                  ),
                  markers: _markers,
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                  onMapCreated: (controller) => _mapController = controller,
                ),

          // Loading indicator
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: Center(child: CircularProgressIndicator()),
            ),

          // Salon list
          DraggableScrollableSheet(
            initialChildSize: 0.3,
            minChildSize: 0.1,
            maxChildSize: 0.7,
            builder: (context, scrollController) {
              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: _nearbySalons.length,
                  itemBuilder: (context, index) {
                    final salon = _nearbySalons[index];
                    return ListTile(
                      title: Text(salon.name),
                      subtitle: Text(
                          '${(salon.distance / 1000).toStringAsFixed(2)} km away'),
                      onTap: () {
                        _mapController?.animateCamera(
                          CameraUpdate.newCameraPosition(
                            CameraPosition(
                              target: LatLng(
                                salon.location.latitude,
                                salon.location.longitude,
                              ),
                              zoom: 16,
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

//AIzaSyAl8lXRwPliMWStTAu_5iAHR0cX2Ie5HGg