// ignore_for_file: file_names, prefer_final_fields, prefer_const_constructors

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:customer_app/Home%20Screen/home_screen.dart';
import 'package:customer_app/Utilities/inputDecoration.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UserRegistration extends StatefulWidget {
  const UserRegistration({super.key});

  @override
  State<UserRegistration> createState() => _UserRegistrationState();
}

class _UserRegistrationState extends State<UserRegistration> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _address;
  late final TextEditingController _mobile1;
  late final TextEditingController _mobile2;

  // Language selection
  Map<String, bool> _languagesSelected = {
    'English': false,
    'German': false,
    'French': false,
    'Japanese': false,
    'Chinese': false,
    'Russian': false,
    'Korean': false,
  };

  @override
  void initState() {
    super.initState();
    _name = TextEditingController();
    _address = TextEditingController();
    _mobile1 = TextEditingController();
    _mobile2 = TextEditingController();
  }

  @override
  void dispose() {
    _name.dispose();
    _address.dispose();
    _mobile1.dispose();
    _mobile2.dispose();
    super.dispose();
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Registration Successful'),
          content: const Text('Your registration was successful!'),
          actions: <Widget>[
            TextButton(
              child: const Text('Go to Home'),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => HomeScreen()));
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      children: [
        const Expanded(
          child: Divider(thickness: 1.5, color: Colors.grey),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Text(title,
              style:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ),
        const Expanded(
          child: Divider(thickness: 1.5, color: Colors.grey),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("User Registration"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Text("Create Your Account",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              TextFormField(
                controller: _name,
                decoration: commonInputDecoration('Enter name').copyWith(
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _address,
                decoration: commonInputDecoration('Enter address').copyWith(
                  prefixIcon: Icon(Icons.home),
                ),
                keyboardType: TextInputType.streetAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your address';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _mobile1,
                decoration:
                    commonInputDecoration('Enter Phone Number').copyWith(
                  prefixIcon: Icon(Icons.phone),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter phone number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _mobile2,
                keyboardType: TextInputType.phone,
                decoration:
                    commonInputDecoration('Enter Alternate Phone Number')
                        .copyWith(
                  prefixIcon: Icon(Icons.phone_android),
                ),
              ),
              const SizedBox(height: 20),
              _buildSectionHeader("Languages"),
              Text(
                "(Please select all the languages you can speak)",
                style: TextStyle(
                    fontSize: 13,
                    fontStyle: FontStyle.italic,
                    color: Colors.grey[600]),
              ),
              const SizedBox(height: 10),
              Column(
                children: _languagesSelected.keys.map((language) {
                  return CheckboxListTile(
                    title: Text(language),
                    value: _languagesSelected[language],
                    onChanged: (bool? value) {
                      setState(() {
                        _languagesSelected[language] = value ?? false;
                      });
                    },
                    controlAffinity: ListTileControlAffinity.leading,
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                icon: Icon(Icons.app_registration),
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    try {
                      final String uid = FirebaseAuth.instance.currentUser!.uid;
                      await FirebaseFirestore.instance
                          .collection("customer")
                          .doc(uid)
                          .set({
                        'name': _name.text.trim(),
                        'address': _address.text.trim(),
                        'mobile1': _mobile1.text.trim(),
                        'mobile2': _mobile2.text.trim(),
                        'email': FirebaseAuth.instance.currentUser!.email,
                        'languages': _languagesSelected,
                      });
                      _showSuccessDialog();
                    } catch (e) {
                      _showErrorDialog(
                          "Registration failed. Please try again.");
                    }
                  }
                },
                label: Text("Register"),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  textStyle: TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
