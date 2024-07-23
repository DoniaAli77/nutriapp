import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AnalyzePage extends StatefulWidget {
  @override
  _AnalyzePageState createState() => _AnalyzePageState();
}

class _AnalyzePageState extends State<AnalyzePage> {
  Future<void> _fetchDataFromOpenAI() async {
    final apiKey = 'sk-None-FQVkW1HdOes9Yz6NU4OPT3BlbkFJzK9BCoZcafAuA1hvUh6i'; // Replace with your actual OpenAI API key
    final url = 'https://api.openai.com/v1/chat/completions'; // Replace with your actual OpenAI endpoint

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
            'content': '''I am a 35-year-old male, 6 feet tall, weighing 180 pounds, with a moderately active lifestyle. My goal is to lose 10 pounds over the next 8 weeks.

Please create a structured 4-week diet plan and suggested recipes in a JSON format with the following structure:

{
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
          "instructions": "XXXX"
        },
        "Lunch": {
          "meal_name": "XXXX",
          "ingredients": "XXXX",
          "instructions": "XXXX"
        },
        "Dinner": {
          "meal_name": "XXXX",
          "ingredients": "XXXX",
          "instructions": "XXXX"
        },
        "Snack": {
          "meal_name": "XXXX",
          "ingredients": "XXXX",
          "instructions": "XXXX"
        }
      }
    },
    ...
  },
  "suggested_recipes": {
    "Recipe 1": {
      "Ingredients": "XXXX",
      "Instructions": "XXXX"
    },
    "Recipe 2": {
      "Ingredients": "XXXX",
      "Instructions": "XXXX"
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
            final jsonString = content.substring(content.indexOf("{"), content.lastIndexOf("}") + 1);

            try {
              final parsedData = jsonDecode(jsonString) as Map<String, dynamic>;

              // Extract and save weekly plans
              final weeklyPlans = parsedData['weekly_plans'] as Map<String, dynamic>;
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
              final suggestedRecipes = parsedData['suggested_recipes'] as Map<String, dynamic>;
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
    _fetchDataFromOpenAI();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Analyzing Data'),
      ),
      body: Center(
        child: FutureBuilder<void>(
          future: _fetchDataFromOpenAI(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return _LoadingScreen();
            } else if (snapshot.hasError) {
              return _ErrorScreen();
            } else {
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
