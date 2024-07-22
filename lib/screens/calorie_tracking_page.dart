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
      await _analyzeImage(_imageFile!);
    }
  }

  Future<void> _getImageFromGallery() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _imageFile = File(image.path);
      });
      await _analyzeImage(_imageFile!);
    }
  }

  Future<void> _analyzeImage(File imageFile) async {
    final apiKey = 'f74be6659c14426a9cb096de2ecf28c6'; // Replace with your actual API key

    try {
      final imageBytes = await imageFile.readAsBytes();
      final base64Image = base64Encode(imageBytes);

      final response = await http.post(
        Uri.parse('https://api.clarifai.com/v2/models/food-item-recognition/outputs'),
        headers: {
          'Authorization': 'Key $apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'inputs': [
            {
              'data': {
                'image': {
                  'base64': base64Image,
                }
              }
            }
          ],
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final concepts = data['outputs'][0]['data']['concepts'];
        String description = concepts != null && concepts.isNotEmpty
            ? concepts.map((concept) => concept['name']).join(', ')
            : 'No food items detected';

        setState(() {
          _caloriesResult = description;
        });
        _showResultDialog();
      } else {
        _showErrorDialog('Failed to analyze image. Please try again later.');
      }
    } catch (e) {
      print('Error analyzing image: $e');
      _showErrorDialog('Failed to analyze image. Please try again later.');
    }
  }

  Future<void> _showResultDialog() async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Food Recognition Analysis'),
          content: Text('Detected Food Items: $_caloriesResult'),
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
              Text('Detected Food Items: $_caloriesResult'),
            ],
          ],
        ),
      ),
    );
  }
}
