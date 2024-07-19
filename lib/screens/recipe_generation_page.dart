import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nutriapp/services/openai_service.dart';

class RecipeGenerationPage extends HookConsumerWidget {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _ingredientsController = TextEditingController();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Generate Recipe'),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            TextFormField(
              controller: _ingredientsController,
              decoration: InputDecoration(labelText: 'Ingredients'),
              validator: (value) => value!.isEmpty ? 'Enter ingredients' : null,
            ),
            ElevatedButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  final openAIService = ref.read(openAIServiceProvider);
                  final recipe = await openAIService.generateRecipe(
                    _ingredientsController.text,
                  );
                  Navigator.pop(context, recipe);
                }
              },
              child: Text('Generate'),
            ),
          ],
        ),
      ),
    );
  }
}
