import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';



class ProfilePage extends StatelessWidget {
  final User? user = FirebaseAuth.instance.currentUser;

  Future<Map<String, dynamic>?> getUserInfo() async {
    try {
      var userData = await FirebaseFirestore.instance
          .collection("users")
          .doc(user!.uid)
          .get();

      if (userData.exists) {
        return userData.data();
      }
    } catch (e) {
      print("Error getting user data: $e");
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: 'hero',
      child: Scaffold(
        appBar: AppBar(
          title: Text('Profile'),
        ),
        body: FutureBuilder<Map<String, dynamic>?>(
          future: getUserInfo(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data == null) {
              return Center(child: Text('No user data found'));
            } else {
              final userData = snapshot.data!;
              return SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(height: 20),
                    CircleAvatar(
                      radius: 60,
                      backgroundImage: NetworkImage(userData['profilePictureUrl'] ?? 'https://via.placeholder.com/150'),
                    ),
                    SizedBox(height: 20),
                    Text(
                      userData['username'] ?? 'User Name',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    Text(
                      userData['email'] ?? 'user@example.com',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                    SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Column(
                        children: [
                          ListTile(
                            leading: Icon(Icons.person),
                            title: Text(userData['username'] ?? 'User Name'),
                          ),
                          Divider(),
                          ListTile(
                            leading: Icon(Icons.email),
                            title: Text(userData['email'] ?? 'user@example.com'),
                          ),
                          Divider(),
                          ListTile(
                            leading: Icon(Icons.phone),
                            title: Text(userData['phone'] ?? 'Not Provided'),
                          ),
                          Divider(),
                          ListTile(
                            leading: Icon(Icons.location_city),
                            title: Text(userData['address'] ?? 'Not Provided'),
                          ),
                          Divider(),
                        ],
                      ),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: () {
                        // Implement settings action
                      },
                      icon: Icon(Icons.settings),
                      label: Text('Settings'),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                        textStyle: TextStyle(fontSize: 18),
                      ),
                    ),
                    SizedBox(height: 20),
                  ],
                ),
              );
            }
          },
        ),
      ),
    );
  }
}
