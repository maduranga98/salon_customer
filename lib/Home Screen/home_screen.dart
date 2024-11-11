import 'package:customer_app/Home%20Screen/My%20Salon/my_salon.dart';
import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:customer_app/Home%20Screen/Bookings/booking.dart';
import 'package:customer_app/Home%20Screen/Main%20Page/main_page.dart';
import 'package:customer_app/Home%20Screen/Offers/offers.dart';
import 'package:customer_app/Home%20Screen/Store/store.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<CurvedNavigationBarState> _bottomNavigationKey = GlobalKey();
  int _currentPage = 0;

  static const _animationDuration = Duration(milliseconds: 600);

  final List<Widget> _pages = [
    MainPage(),
    MySalon(),
    Store(),
    Offers(),
    Booking(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: CurvedNavigationBar(
        key: _bottomNavigationKey,
        index: _currentPage, // Initialize with _currentPage
        items: const <Widget>[
          Icon(Icons.home, size: 30),
          Icon(
            Icons.content_cut,
          ),
          Icon(Icons.store, size: 30),
          Icon(Icons.local_offer, size: 30),
          Icon(Icons.calendar_month, size: 30),
        ],
        color: Colors.white,
        buttonBackgroundColor: Colors.white,
        backgroundColor: Colors.blueAccent,
        animationCurve: Curves.easeInOut,
        animationDuration: _animationDuration,
        onTap: (index) {
          setState(() {
            _currentPage = index;
          });
        },
      ),
      body: _pages[
          _currentPage], // Display the selected page based on _currentPage
    );
  }
}

// home, my saloon,offer, store, my boooking