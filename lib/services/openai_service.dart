import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openai/openai.dart';

final openAIServiceProvider = Provider<OpenAIService>((ref) {
  return OpenAIService();
});

class OpenAIService {
  final _openAI = OpenAI(apiKey: 'YOUR_OPENAI_API_KEY'); // Replace with your API key

  Future<String> generateRecipe(String ingredients) async {
    final response = await _openAI.completions.create(
      engine: 'davinci',
      prompt: 'Generate a recipe with these ingredients: $ingredients',
      maxTokens: 100,
    );
    return response.choices.first.text;
  }
}
