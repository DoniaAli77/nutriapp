import 'dart:convert';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:http/http.dart' as http;

final openAIServiceProvider = Provider<OpenAIService>((ref) {
  return OpenAIService(apiKey: 'YOUR_OPENAI_API_KEY'); // Replace with your API key
});

class OpenAIService {
  final String _apiKey;

  OpenAIService({required String apiKey}) : _apiKey = apiKey;

  Future<String> generateRecipe(String ingredients) async {
    final url = Uri.parse('https://api.openai.com/v1/completions');
    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $_apiKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'model': 'text-davinci-003', // Use the correct model name
        'prompt': 'Generate a recipe with these ingredients: $ingredients',
        'max_tokens': 150, // Adjust maxTokens as needed
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['choices'][0]['text'].trim();
    } else {
      throw Exception('Failed to load data');
    }
  }
}
