// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:google_ml_kit/google_ml_kit.dart';

// class CalorieTrackingPage extends StatefulWidget {
//   @override
//   _CalorieTrackingPageState createState() => _CalorieTrackingPageState();
// }

// class _CalorieTrackingPageState extends State<CalorieTrackingPage> {
//   File? _image;
//   List<String> _labels = [];
//   bool _isLoading = false;

//   final ImagePicker _picker = ImagePicker();
//   final ImageLabeler _labeler = GoogleMlKit.vision.imageLabeler();

//   Future<void> _pickImage() async {
//     final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
//     if (pickedFile != null) {
//       setState(() {
//         _image = File(pickedFile.path);
//         _isLoading = true;
//       });
//       await _analyzeImage(_image!);
//     }
//   }

//   Future<void> _analyzeImage(File image) async {
//     try {
//       final InputImage visionImage = InputImage.fromFile(image);
//       final List<ImageLabel> labels = await _labeler.processImage(visionImage);

//       setState(() {
//         _labels = labels.map((label) => '${label.label} (${(label.confidence * 100).toStringAsFixed(2)}%)').toList();
//         _isLoading = false;
//       });
//     } catch (e) {
//       setState(() {
//         _labels = ['Failed to analyze image.'];
//         _isLoading = false;
//       });
//     }
//   }

//   @override
//   void dispose() {
//     _labeler.close();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Calorie Tracking'),
//       ),
//       body: Center(
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: <Widget>[
//               _image == null
//                   ? Text('No image selected.')
//                   : Image.file(_image!),
//               SizedBox(height: 20),
//               _isLoading
//                   ? CircularProgressIndicator()
//                   : _labels.isEmpty
//                       ? Text(
//                           'No labels available.',
//                           style: TextStyle(fontSize: 16.0),
//                         )
//                       : Column(
//                           children: _labels.map((label) => Text(
//                             label,
//                             style: TextStyle(fontSize: 16.0),
//                           )).toList(),
//                         ),
//               SizedBox(height: 20),
//               ElevatedButton(
//                 onPressed: _pickImage,
//                 child: Text('Pick Image'),
//                 style: ElevatedButton.styleFrom(
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(20),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
