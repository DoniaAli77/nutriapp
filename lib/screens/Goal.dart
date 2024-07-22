import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class Goal extends StatelessWidget {
  // Constructor to accept arguments


  Future<void> addGoal(String userId, String data) async {
    try {
      // Get a reference to the Firestore instance
      FirebaseFirestore db = FirebaseFirestore.instance;

      // Add or update the goal in the "Nutrients" collection
      await db
          .collection("Nutrients")
          .doc(userId)
          .set({"Goal": data}, SetOptions(merge: true));
      print("Goal added successfully");
    } catch (e) {
      print("Error writing document: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final routeArgs =
        ModalRoute.of(context)!.settings.arguments as Map<String, String>;

    final userId = routeArgs['UserId'].toString();
    final UserName = routeArgs['Name'].toString();
//extractedCategory!.id

    return Scaffold(
      appBar: AppBar(
        title: Text('Goals'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Lottie.asset('assets/chef.json', width: 200, height: 200),
            SizedBox(height: 20),
            Text(
              'Hello, $UserName',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            SizedBox(
              width: 300, // Set a fixed width for all buttons
              child: ElevatedButton(
                onPressed: () => addGoal(userId, 'Losing Weight'),
                child: Text('Losing Weight'),
              ),
            ),
            SizedBox(height: 20), // Space between buttons
            SizedBox(
              width: 300, // Same width as above
              child: ElevatedButton(
                onPressed: () =>
                    addGoal(userId, 'Gaining muscle and losing fat'),
                child: Text('Gaining muscle and losing fat'),
              ),
            ),
            SizedBox(height: 20), // Space between buttons
            SizedBox(
              width: 300, // Same width as above
              child: ElevatedButton(
                onPressed: () =>
                    addGoal(userId, 'Gaining muscle, losing fat is secondary'),
                child: Text('Gaining muscle, losing fat is secondary'),
              ),
            ),
            SizedBox(height: 20), // Space between buttons
            SizedBox(
              width: 300, // Same width as above
              child: ElevatedButton(
                onPressed: () =>
                    addGoal(userId, 'Eating healthier without losing weight'),
                child: Text('Eating healthier without losing weight'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
