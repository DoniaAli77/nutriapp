import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:animations/animations.dart';
import 'package:nutriapp/screens/Goal.dart';
import 'package:nutriapp/screens/SetGoalOrPass.dart';
import 'package:nutriapp/screens/home_page.dart';
import 'package:nutriapp/screens/loadingScreen.dart';
import 'package:nutriapp/screens/login_page.dart';
import 'calorie_tracking_page.dart';




class HomePage extends StatelessWidget {

  FirebaseFirestore db = FirebaseFirestore.instance;




  Future<bool> checkUserExistInGoals(String userId) async {

    try {

      // Get the document reference

      final docRef = db.collection("Nutrients").doc(userId);




      // Fetch the document snapshot

      final docSnapshot = await docRef.get();




      // Check if the document exists

      if (docSnapshot.exists) {

        return true; // Document exists

      } else {

        return false; // Document does not exist

      }

    } catch (e) {

      print("Error getting document: $e");

      return false; // Consider logging the error or handling it as needed

    }

  }




  Future<String> GetUserName(String userId) async {

    try {

      var userData = await FirebaseFirestore.instance

          .collection("users")

          .doc(userId)

          .get();




      // Check if the document exists

      if (userData.exists) {

        String name = userData.data()!["username"];

      

        return name; // Document exists

      } else {

        return "User"; // Document does not exist

      }

    } catch (e) {

      print("Error getting document: $e");

      return ""; // Consider logging the error or handling it as needed

    }

  }




  Widget build(BuildContext context) {

     User? user = FirebaseAuth.instance.currentUser;

    // // String displayName = user?.displayName ?? 'Guest';

    // //  String displayName = user != null ? 'Guest' : 'Anonymous';

     var Name = 'eman';

   GetUserName(user!.uid).then((x) => Name = x);

   String UserId = user.uid;
  //  String UserId = "12345";
    return Scaffold(

      appBar: AppBar(

        title: Text('Fancy Recipe App'),

      ),

      body: Center(

        child: Column(

          mainAxisAlignment: MainAxisAlignment.center,

          children: [

            Lottie.asset('assets/chef.json', width: 200, height: 200),

            SizedBox(height: 20),

            OpenContainer(

              closedBuilder: (context, action) => ElevatedButton(

                onPressed: () async {
 //onPressed: ()  {
                  bool userExists = await checkUserExistInGoals(UserId);

                  
                  if (userExists) {

                   Navigator.pushNamed(

                      context,

                      '/setorpass',

                      arguments: <String, String>{

                        'UserId': UserId,

                        'Name': Name.toString()

                      },

                    );

                  } else {

                    // Handle the case when the user does not exist

                    ScaffoldMessenger.of(context).showSnackBar(

                      SnackBar(

                        content: Text(Name.toString()),

                      ),

                    );

                    Navigator.pushNamed(

                      context,

                      '/goal',

                      arguments: <String, String>{

                        'UserId': UserId,

                        'Name': Name.toString()

                      },

                    );

                  }

                },

                child: Text('Track Calories'),

              ),

              openBuilder: (context, action) => LoadingScreen(),

              transitionType: ContainerTransitionType.fade,

              closedElevation: 0.0,

              openElevation: 0.0,

              closedShape: RoundedRectangleBorder(

                borderRadius: BorderRadius.circular(20),

              ),

              openShape: RoundedRectangleBorder(),

            ),

          ],

        ),

      ),

    );

  }

}
