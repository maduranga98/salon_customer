import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MySalon extends StatefulWidget {
  const MySalon({super.key});

  @override
  State<MySalon> createState() => _MySalonState();
}

class _MySalonState extends State<MySalon> {
  @override
  Widget build(BuildContext context) {
    String uid = FirebaseAuth.instance.currentUser!.uid;
    return Scaffold(
        body: StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection('customers')
                .doc(uid)
                .collection('salons')
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return Center(child: Text("No services found"));
              }

              return Padding(
                padding: EdgeInsets.all(5.0),
                child: ListView.builder(
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      var data = snapshot.data!.docs[index];
                      return Card(
                        child: ListTile(
                          title: data['name'],
                          leading: data['link'],
                          subtitle: data['addess'],
                        ),
                      );
                    }),
              );
            }));
  }
}
