import 'dart:io';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

// Example provider for your API service
final apiProvider = Provider<ApiService>((ref) {
  final apiKey = dotenv.env['API_KEY'];
  return ApiService(apiKey: apiKey!);
});

class ApiService {
  final String apiKey;

  ApiService({required this.apiKey});

  Future<String> analyzeImage(File image) async {
    final url = Uri.parse('https://your-backend-service.com/analyze-image');
    final request = http.MultipartRequest('POST', url)
      ..files.add(await http.MultipartFile.fromPath('image', image.path))
      ..headers['Authorization'] = 'Bearer $apiKey';

    final response = await request.send();

    if (response.statusCode == 200) {
      final responseData = await response.stream.bytesToString();
      return responseData;
    } else {
      throw Exception('Failed to analyze image.');
    }
  }
}
