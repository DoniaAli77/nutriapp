import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/scheduler.dart'; // Import for SchedulerBinding

class AnalyzePage extends StatefulWidget {
  @override
  _AnalyzePageState createState() => _AnalyzePageState();
}

class _AnalyzePageState extends State<AnalyzePage> {
  Future<void> _fetchDataFromOpenAI(
      weight, height, Gender, FutureWeight, MedicalHistory, Age) async {
    final apiKey =
        'sk-None-Zd0yXl5OUaAlgjKlTy9gT3BlbkFJY4FoVU5ODzcguDt4MyCI'; // Replace with your actual OpenAI API key
    final url =
        'https://api.openai.com/v1/chat/completions'; // Replace with your actual OpenAI endpoint

    try {
      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      };

      final payload = {
        'model': 'gpt-4o-mini',
        'messages': [
          {
            'role': 'user',
            'content':
                '''I am a ${Age}-year-old ${Gender}, ${height} cm tall, weighing ${weight} kg, with a moderately active lifestyle,with a medical history : ${MedicalHistory}. My goal is to be ${FutureWeight} Kg over the next 4 weeks.

Please create a structured 4-week diet plan and suggested recipes in a JSON format with the following structure:

{
  "Total_Daily_Calories": "XXXX",
  "weekly_plans": {
    "Week 1": {
      "Total Weekly Calories": "XXXX",
      "Daily Meals": {
        "Day 1": {
          "Breakfast": "XXXX",
          "Lunch": "XXXX",
          "Dinner": "XXXX",
          "Snack": "XXXX"
        },
        ...
      },
      "Meal Recipes": {
        "Breakfast": {
          "meal_name": "XXXX",
          "ingredients": "XXXX",
          "instructions": "XXXX",
          "total calories for this meal": "XXXX"
        },
        "Lunch": {
          "meal_name": "XXXX",
          "ingredients": "XXXX",
          "instructions": "XXXX",
          "total calories for this meal": "XXXX"

        },
        "Dinner": {
          "meal_name": "XXXX",
          "ingredients": "XXXX",
          "instructions": "XXXX",
          "total calories for this meal": "XXXX"

        },
        "Snack": {
          "meal_name": "XXXX",
          "ingredients": "XXXX",
          "instructions": "XXXX",
          "total calories for this meal": "XXXX"

        }
      }
    },
    ...
  },
  "suggested_recipes": {
    "Recipe 1": {
      "recipe_name":"XXXX"
      "Ingredients": "XXXX",
      "Instructions": "XXXX"
      "total_calories":"XXXX"
    },
    "Recipe 2": {
      "recipe_name":"XXXX"
      "Ingredients": "XXXX",
      "Instructions": "XXXX",
      "total_calories":"XXXX"

    },
    ...
  }
}'''
          },
        ],
        'max_tokens': 10000,
      };

      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: json.encode(payload),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body) as Map<String, dynamic>;

        // Debugging: Print the raw response data
        print('Raw API Response: $responseData');

        final userId = FirebaseAuth.instance.currentUser?.uid ?? 'guest';
        if (userId == 'guest') throw Exception('User not registered');

        final choices = responseData['choices'] as List<dynamic>;
        if (choices.isNotEmpty) {
          final choice = choices[0];
          final message = choice['message'] as Map<String, dynamic>;
          final content = message['content'] as String?;

          if (content != null) {
            // Extract JSON from the content string
            final jsonString = content.substring(
                content.indexOf("{"), content.lastIndexOf("}") + 1);

            try {
              final parsedData = jsonDecode(jsonString) as Map<String, dynamic>;
              final Total_Daily_Calories =
                  parsedData['Total_Daily_Calories'] as String;
              await FirebaseFirestore.instance
                  .collection('users')
                  .doc(userId)
                  .set({'Total_Daily_Calories': Total_Daily_Calories},
                      SetOptions(merge: true));

              // Extract and save weekly plans
              final weeklyPlans =
                  parsedData['weekly_plans'] as Map<String, dynamic>;
              if (weeklyPlans.isEmpty) {
                print('No weekly plans extracted');
              } else {
                await FirebaseFirestore.instance
                    .collection('plans')
                    .doc(userId)
                    .set({'weeks': weeklyPlans});
                print('Weekly plans saved to Firestore');
              }

              // Extract and save suggested recipes
              final suggestedRecipes =
                  parsedData['suggested_recipes'] as Map<String, dynamic>;
              if (suggestedRecipes.isEmpty) {
                print('No suggested recipes extracted');
              } else {
                await FirebaseFirestore.instance
                    .collection('suggested_recipes')
                    .doc(userId)
                    .set(suggestedRecipes);
                print('Suggested recipes saved to Firestore');
              }
            } catch (jsonError) {
              print('Error parsing JSON: $jsonError');
            }
          } else {
            print('No content found in message');
          }
        } else {
          print('No choices found in response');
        }
      } else {
        throw Exception('Failed to load data: ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Error occurred: $e');
      throw e;
    }
  }

  @override
  void initState() {
    super.initState();
    // _fetchDataFromOpenAI();
  }

  @override
  Widget build(BuildContext context) {
    final routeArgs =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    var weight = routeArgs['weight'];
    var height = routeArgs['height'];
    var Gender = routeArgs['Gender'];
    var FutureWeight = routeArgs['FutureWeight'];
    var MedicalHistory = routeArgs['MedicalHistory'];
    var Age = routeArgs['Age'];

    return Scaffold(
      appBar: AppBar(
        title: Text('Analyzing Data'),
      ),
      body: Center(
        child: FutureBuilder<void>(
          future: _fetchDataFromOpenAI(
              weight, height, Gender, FutureWeight, MedicalHistory, Age),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return _LoadingScreen();
            } else if (snapshot.hasError) {
              return _ErrorScreen();
            } else {
              // Start navigation to homepage after a 10-second delay
              WidgetsBinding.instance.addPostFrameCallback((_) {
                Future.delayed(Duration(seconds: 10), () {
                  Navigator.pushReplacementNamed(context, '/home');
                });
              });

              return _SuccessScreen();
            }
          },
        ),
      ),
    );
  }
}

class _LoadingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircularProgressIndicator(),
        SizedBox(height: 20),
        Text(
          'Analyzing your data...',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}

class _ErrorScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.error, color: Colors.red, size: 50),
        SizedBox(height: 20),
        Text(
          'An error occurred while analyzing your data.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 18, color: Colors.red),
        ),
      ],
    );
  }
}

class _SuccessScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.check_circle, color: Colors.green, size: 50),
        SizedBox(height: 20),
        Text(
          'Data analysis completed successfully!',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
