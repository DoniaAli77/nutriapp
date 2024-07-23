import 'dart:developer';

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
  // Function to extract weekly plans from the response content
  Map<String, dynamic> extractWeeklyPlans(String content) {
    if (content == null) {
      print('No messages found in response');
      return {};
    }

    final textContent = content + '\n';
    final weeks = <String, dynamic>{};
    final regex = RegExp(r'### Week \d+([\s\S]+?)(?=### Week \d+|$)', multiLine: true);
    final matches = regex.allMatches(textContent);

    for (var match in matches) {
      final weekContent = match.group(0);
      if (weekContent != null) {
        final weekTitle = RegExp(r'### Week \d+').firstMatch(weekContent)?.group(0) ?? 'Unknown Week';
        final weekDetails = weekContent.replaceFirst(RegExp(r'### Week \d+'), '').trim();
        weeks[weekTitle] = weekDetails;
      }
    }

    return weeks;
  }

  // Function to extract suggested recipes from the response content
  Map<String, dynamic> extractSuggestedRecipes(String content) {
    if (content == null) {
      print('No messages found in response');
      return {};
    }

    final textContent = content + '\n';
    final recipes = <String, dynamic>{};
    final regex = RegExp(r'(?<=\*\*Recipe Name\*\*:[\s\S]+?)(?=\*\*Recipe Name\*\*|$)', multiLine: true);
    final matches = regex.allMatches(textContent);

    for (var match in matches) {
      final recipeContent = match.group(0);
      if (recipeContent != null) {
        final recipeNameMatch = RegExp(r'(?<=\*\*Recipe Name\*\*:)(.*?)(?=\*\*Ingredients\*\*)').firstMatch(recipeContent);
        final recipeName = recipeNameMatch?.group(0)?.trim() ?? 'Unnamed Recipe';
        final ingredientsMatch = RegExp(r'(?<=\*\*Ingredients\*\*:)(.*?)(?=\*\*Instructions\*\*)').firstMatch(recipeContent);
        final ingredients = ingredientsMatch?.group(0)?.trim() ?? '';
        final instructionsMatch = RegExp(r'(?<=\*\*Instructions\*\*:)(.*?)(?=\*\*Recipe Name\*\*|$)').firstMatch(recipeContent);
        final instructions = instructionsMatch?.group(0)?.trim() ?? '';

        if (recipeName.isNotEmpty) {
          recipes[recipeName] = {
            'ingredients': ingredients,
            'instructions': instructions,
          };
        }
      }
    }

    return recipes;
  }

  // Function to fetch data from OpenAI and process the response
  Future<void> _fetchDataFromOpenAI() async {
    final apiKey = 'sk-None-zlMFcw87RDICYqW68fBPT3BlbkFJtUvH8Ga3P6iwyZg5pO5M'; // Replace with your actual OpenAI API key
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

Please create a structured 2-week diet plan including the following:

1. **Weekly Plans**:
   - Provide a plan for each week, starting from Week 1 to Week 4.
   - For each week, include the following:
     - **Total Weekly Calories**: The total calorie count for each week.
     - **Daily Meals**: List the meals for each day (e.g., breakfast, lunch, dinner).
     - **Meal Recipes**: Include the recipe for each meal with:
       - **Ingredients**: List of ingredients with quantities.
       - **Instructions**: Detailed preparation steps.

2. **Suggested Recipes**:
   - Provide additional recipes suitable for the diet but not tied to specific meals.
   - Each recipe should include:
     - **Recipe Name**: The name of the recipe.
     - **Ingredients**: List of ingredients with quantities.
     - **Instructions**: Detailed preparation steps.

Please format your response in clear sections with headings. For the weekly plans, use the format:
- **Week X**:
  - **Total Weekly Calories**: [calories]
  - **Day X**:
    - **Breakfast**: [meal details]
    - **Lunch**: [meal details]
    - **Dinner**: [meal details]
    - **Snack**: [optional snack details]

For suggested recipes, use the format:
- **Recipe Name**:
  - **Ingredients**:
  - **Instructions**:
''',
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
        log('Raw API Response: $responseData');

        final userId = FirebaseAuth.instance.currentUser?.uid ?? 'guest';
        if (userId == 'guest') throw Exception('User not registered');

        final choices = responseData['choices'] as List<dynamic>;
        if (choices.isNotEmpty) {
          final choice = choices[0];
          final message = choice['message'] as Map<String, dynamic>;
          final content = message['content'] as String?;

          if (content != null) {
            // Extract and save weekly plans
            final weeklyPlans = extractWeeklyPlans(content);
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
            final suggestedRecipes = extractSuggestedRecipes(content);
            if (suggestedRecipes.isEmpty) {
              print('No suggested recipes extracted');
            } else {
              await FirebaseFirestore.instance
                  .collection('suggested_recipes')
                  .doc(userId)
                  .set(suggestedRecipes);
              print('Suggested recipes saved to Firestore');
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
