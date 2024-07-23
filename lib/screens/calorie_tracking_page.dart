import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:nutriapp/screens/loadingScreen.dart';

class TrackingPage extends StatefulWidget {
  @override
  _TrackingPageState createState() => _TrackingPageState();
}

class _TrackingPageState extends State<TrackingPage> {
  final ImagePicker _picker = ImagePicker();
  File? _imageFile;
  String? _caloriesResult;
  final auth = FirebaseAuth.instance;
  var add = false;

  void addCalories() async {
    var currentUserId = FirebaseAuth.instance.currentUser!.uid;
    print(currentUserId);
    var userData = await FirebaseFirestore.instance
        .collection("users")
        .doc(currentUserId)
        .get();
    print('hiiiiiiiiii') ;   
    print( double.parse(userData.data()!["Total_Daily_Calories"]));
    FirebaseFirestore.instance.collection("users").doc(currentUserId).set({
      "Total_Daily_Calories": double.parse(userData.data()!["Total_Daily_Calories"]) - double.parse(_caloriesResult!),
    }, SetOptions(merge: true)).then((_) => setState(() {
          add = true;
        }));
  }

  Future<void> _getImageFromCamera() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      setState(() {
        _imageFile = File(image.path);
      });
      await _analyzeImage(File(image.path));
    }
  }

  Future<void> _getImageFromGallery() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _imageFile = File(image.path);
      });
      await _analyzeImage(File(image.path));
    }
  }

  Future<String> encodeImage(String imagePath) async {
    final imageBytes = await File(imagePath).readAsBytes();
    return base64Encode(imageBytes);
  }

  String extractCaloriesFromContent(String content) {
    final RegExp caloriesPattern =
        RegExp(r'calories\s*[:\-\s]*([0-9,]+)', caseSensitive: false);
    final match = caloriesPattern.firstMatch(content);

    if (match != null) {
      return match.group(1)?.replaceAll(',', '') ?? 'Not found';
    } else {
      return 'Not found';
    }
  }

  void printEstimatedCalories(String responseBody) {
    try {
      final Map<String, dynamic> jsonResponse = json.decode(responseBody);
      print(jsonResponse);
      final choices = jsonResponse['choices'] as List<dynamic>;
      if (choices.isNotEmpty) {
        final choice = choices[0];
        final message = choice['message'];
        final content = message['content'];
        final estimatedCalories = extractCaloriesFromContent(content);
        print('Estimated Calories: $estimatedCalories');
      } else {
        print('No choices available in the response.');
      }
    } catch (e) {
      print('Error parsing response: $e');
    }
  }

  double? parseCaloriesFromContent(String content) {
    final RegExp caloriesPattern =
        RegExp(r'calories\s*[:\-\s]*([0-9,]+)', caseSensitive: false);
    final match = caloriesPattern.firstMatch(content);

    if (match != null) {
      final calorieString = match.group(1)?.replaceAll(',', '') ?? '';
      return double.tryParse(calorieString);
    } else {
      return null;
    }
  }

  double? extractCaloriesFromResponse(String responseBody) {
    try {
      final Map<String, dynamic> jsonResponse = json.decode(responseBody);
      print(jsonResponse);
      final choices = jsonResponse['choices'] as List<dynamic>;
      if (choices.isNotEmpty) {
        final choice = choices[0];
        final message = choice['message'];
        final content = message['content'];
        return parseCaloriesFromContent(content);
      } else {
        print('No choices available in the response.');
        return null;
      }
    } catch (e) {
      print('Error parsing response: $e');
      return null;
    }
  }

  Future<void> _analyzeImage(File imageFile) async {
    final String apiUrl = 'https://api.openai.com/v1/chat/completions';

    try {
      String base64Image = await encodeImage(imageFile.path);

      final headers = {
        'Content-Type': 'application/json',
        'Authorization':
            'Bearer sk-None-nRV1GXV9d4vQUjaVxybET3BlbkFJaXPiaHYkrSAMgJR5exoe',
      };

      final payload = {
        'model': 'gpt-4o-mini',
        'messages': [
          {
            'role': 'user',
            'content': [
              {
                'type': 'text',
                'text':
                    'Analyze this image and estimate the average calories of the food dish shown. Clearly write the word "calories" in your response, followed by the estimated number of calories'
              },
              {
                'type': 'image_url',
                'image_url': {
                  'url': 'data:image/jpeg;base64,$base64Image',
                },
              },
            ],
          },
        ],
        'max_tokens': 300,
      };

      var response = await http.post(
        Uri.parse('https://api.openai.com/v1/chat/completions'),
        headers: headers,
        body: json.encode(payload),
      );

      final estimatedCalories = extractCaloriesFromResponse(response.body);
      if (estimatedCalories == null) {
        _showErrorDialog('Calories information not found in the response.');
      } else {
        setState(() {
          _caloriesResult = estimatedCalories.toString();
        });
        print('Estimated Calories: $estimatedCalories');
        // _showResultDialog();
      }
    } catch (e) {
      print('Error: $e');
      _showErrorDialog('Failed to analyze image. Please try again later.');
    }
  }

  Future<void> _showResultDialog() async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Calories Analysis'),
          content: Text('Estimated Calories: $_caloriesResult'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showImageSourceDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: Text('Choose an option'),
          children: <Widget>[
            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context);
                _getImageFromCamera();
              },
              child: Row(
                children: [
                  Icon(Icons.camera_alt),
                  SizedBox(width: 8),
                  Text('Take a Picture'),
                ],
              ),
            ),
            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context);
                _getImageFromGallery();
              },
              child: Row(
                children: [
                  Icon(Icons.photo_library),
                  SizedBox(width: 8),
                  Text('Choose from Gallery'),
                ],
              ),
            ),
            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Row(
                children: [
                  SizedBox(width: 8),
                  Text('Cancel'),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Track your Calories'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showImageSourceDialog,
        child: Icon(Icons.add),
      ),
      body: Center(
        child: Hero(
          tag: 'hero',
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Scan the Dish image to show calories',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (_imageFile != null) ...[
                    SizedBox(height: 20),
                    Text(
                      'Scanned Dish',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 20),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12.0),
                      child: Image.file(
                        _imageFile!,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ],
                  if (_imageFile != null && _caloriesResult == null) ...[
                    SizedBox(height: 20),
                    Text('analyzing your dish..'),
                    SizedBox(height: 20),
                    CircularProgressIndicator(),
                  ],
                  if (_caloriesResult != null) ...[
                    SizedBox(height: 20),
                    Text(
                      'Estimated Calories: $_caloriesResult',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                        onPressed: add ? null : addCalories,
                        child: Text('Add to my calories'))
                  ],
                  if (add) ...[
                    Text(
                      'added succesfully',
                      style: TextStyle(color: Colors.green),
                    )
                  ]
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
