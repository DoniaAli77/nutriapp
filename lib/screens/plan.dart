// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'package:cloud_firestore/cloud_firestore.dart';

// class AnalyzePage extends StatefulWidget {
//   @override
//   _AnalyzePageState createState() => _AnalyzePageState();
// }

// class _AnalyzePageState extends State<AnalyzePage> {
//   Future<void> _fetchDataFromOpenAI() async {
//     final apiKey =
//         'sk-None-zlMFcw87RDICYqW68fBPT3BlbkFJtUvH8Ga3P6iwyZg5pO5M'; // Replace with your actual OpenAI API key
//     final url =
//         'https://api.openai.com/v1/chat/completions'; // Replace with your actual OpenAI endpoint

//     try {
//       final headers = {
//         'Content-Type': 'application/json',
//         'Authorization':
//             'Bearer sk-None-zlMFcw87RDICYqW68fBPT3BlbkFJtUvH8Ga3P6iwyZg5pO5M',
//       };

//       final payload = {
//         'model': 'gpt-4o-mini',
//         'messages': [
//           {
//             'role': 'user',
//             'content': [
//               {
//                 'type': 'text',
//                 'text':
//                     'I am a 35-year-old male, 6 feet tall, weighing 180 pounds, with a moderately active lifestyle. My goal is to lose 10 pounds over the next 8 weeks. Please create a weekly diet plan for me, including breakfast, lunch, and dinner. Provide suggested recipes for each meal and specify the allowed calories for each meal and the total daily calorie intake. Also, suggest different recipes that are suitable for this diet but not restricted to a specific meal.'
//               }
//             ],
//           }
//         ],
//         'max_tokens': 2000,
//       };
//       var response = await http.post(
//         Uri.parse('https://api.openai.com/v1/chat/completions'),
//         headers: headers,
//         body: json.encode(payload),
//       );


//       if (response.statusCode == 200) {
//         final responseData = jsonDecode(response.body);
//         // Save the response data to Firestore
//         await _saveDataToFirestore(responseData);
//         return responseData; // Return response data for success UI
//       } else {
//         throw Exception('Failed to load data');
//       }
//     } catch (e) {
//       // Handle any errors that occur during the request
//       print('Error occurred: $e');
//       throw e; // Rethrow the error to display error UI
//     }
//   }

//   Future<void> _saveDataToFirestore(Map<String, dynamic> data) async {
//     final firestore = FirebaseFirestore.instance;
//     try {
//       await firestore.collection('api_responses').add(data);
//       print('Data saved to Firestore successfully.');
//     } catch (e) {
//       print('Failed to save data to Firestore: $e');
//     }
//   }

//   @override
//   void initState() {
//     super.initState();
//     _fetchDataFromOpenAI();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Analyzing Data'),
//       ),
//       body: Center(
//         child: FutureBuilder<void>(
//           future: _fetchDataFromOpenAI(),
//           builder: (context, snapshot) {
//             if (snapshot.connectionState == ConnectionState.waiting) {
//               return _LoadingScreen();
//             } else if (snapshot.hasError) {
//               return _ErrorScreen();
//             } else {
//               return _SuccessScreen();
//             }
//           },
//         ),
//       ),
//     );
//   }
// }

// class _LoadingScreen extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         CircularProgressIndicator(),
//         SizedBox(height: 20),
//         Text(
//           'Analyzing your data...',
//           style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//         ),
//       ],
//     );
//   }
// }

// class _ErrorScreen extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         Icon(Icons.error, color: Colors.red, size: 50),
//         SizedBox(height: 20),
//         Text(
//           'An error occurred while analyzing your data.',
//           textAlign: TextAlign.center,
//           style: TextStyle(fontSize: 18, color: Colors.red),
//         ),
//       ],
//     );
//   }
// }

// class _SuccessScreen extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         Icon(Icons.check_circle, color: Colors.green, size: 50),
//         SizedBox(height: 20),
//         Text(
//           'Data analysis completed successfully!',
//           style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//         ),
//       ],
//     );
//   }
// }
