import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class TrackingPage extends StatefulWidget {
  @override
  _TrackingPageState createState() => _TrackingPageState();
}

class _TrackingPageState extends State<TrackingPage> {
  final ImagePicker _picker = ImagePicker();
  File? _imageFile;
  String? _caloriesResult;

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
    // Define a regex pattern to find the word "calories" and capture the following number
    final RegExp caloriesPattern =
        RegExp(r'calories\s*[:\-\s]*([0-9,]+)', caseSensitive: false);

    // Search for the pattern in the content
    final match = caloriesPattern.firstMatch(content);

    if (match != null) {
      // Return the extracted calories (remove any commas for clarity)
      return match.group(1)?.replaceAll(',', '') ?? 'Not found';
    } else {
      return 'Not found';
    }
  }

  void printEstimatedCalories(String responseBody) {
    try {
      
      // Decode the JSON response
      final Map<String, dynamic> jsonResponse = json.decode(responseBody);

      // Navigate to the content
      final choices = jsonResponse['choices'] as List<dynamic>;
      if (choices.isNotEmpty) {
        final choice = choices[0];
        final message = choice['message'];
        final content = message['content'];

        // Extract and print the estimated calories
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
    // Define a regex pattern to find the word "calories" and capture the following number
    final RegExp caloriesPattern =
        RegExp(r'calories\s*[:\-\s]*([0-9,]+)', caseSensitive: false);

    // Search for the pattern in the content
    final match = caloriesPattern.firstMatch(content);

    if (match != null) {
      // Extract the calories number and remove commas
      final calorieString = match.group(1)?.replaceAll(',', '') ?? '';

      // Convert the string to a double
      return double.tryParse(calorieString);
    } else {
      return null; // No calories found
    }
  }

  double? extractCaloriesFromResponse(String responseBody) {
    try {
      // Decode the JSON response
      final Map<String, dynamic> jsonResponse = json.decode(responseBody);

      // Navigate to the content
      final choices = jsonResponse['choices'] as List<dynamic>;
      if (choices.isNotEmpty) {
        final choice = choices[0];
        final message = choice['message'];
        final content = message['content'];

        // Extract the numeric value of calories
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

      // Define the request headers
      final headers = {
        'Content-Type': 'application/json',
        'Authorization':
            'Bearer sk-None-U3LU7EM3iqBRsHJ3XcSCT3BlbkFJ8dWolHAfc2niDFwapjzt',
      };

      // Define the payload
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

      // Send the POST request
      var response = await http.post(
        Uri.parse('https://api.openai.com/v1/chat/completions'),
        headers: headers,
        body: json.encode(payload),
      );

      // Print the response
      print('hi');
      print(response.body);
      final estimatedCalories = extractCaloriesFromResponse(response.body);
      if(estimatedCalories==null){
          _showErrorDialog('Calories information not found in the response.');

      }
      else{
      setState(() {
        _caloriesResult = estimatedCalories.toString();
      });
      print('Estimated Calories: $estimatedCalories');
      _showResultDialog();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tracking Page'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: _getImageFromCamera,
              child: Text('Take a Picture'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _getImageFromGallery,
              child: Text('Choose from Gallery'),
            ),
            if (_imageFile != null) ...[
              SizedBox(height: 20),
              Image.file(_imageFile!),
            ],
            if (_caloriesResult != null) ...[
              SizedBox(height: 20),
              Text('Estimated Calories: $_caloriesResult'),
            ],
          ],
        ),
      ),
    );
  }
}
