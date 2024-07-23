import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class Setgoalorpass extends StatelessWidget {
  const Setgoalorpass({super.key});

  @override
  Widget build(BuildContext context) {
    final routeArgs =
        ModalRoute.of(context)!.settings.arguments as Map<String, String>;

    final userId = routeArgs['UserId'].toString();
    print(" Set Goal or pass user id");
 print(userId);
    var UserName = routeArgs['Name'] as String;

    return Scaffold(
      appBar: AppBar(
        title: Text('Choose Your Goal'),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Lottie.asset('assets/chef.json', width: 200, height: 200),

              SizedBox(height: 30),

              Text(
                'What would you like to do?',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // Add your logic for staying with the same goal
                    Navigator.pushNamed(
                    context,
                    '/PersonalDetailsPage',
                    arguments: <String, String>{
                       'UserId': userId,
                        'Name': UserName.toString()
                    },
                  );

                  },
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.teal,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  
                  ),
                  child: Text(
                    'Stay with the Same Goal',
              
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),

              SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // Add your logic for setting a new goal
                   Navigator.pushNamed(

                      context,

                      '/goal',

                      arguments: <String, String>{

                        'UserId': userId,

                        'Name': UserName.toString()

                      },

                    );
                  },
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.orange,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    'Set a New Goal',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  }

