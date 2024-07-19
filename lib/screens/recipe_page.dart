import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nutriapp/models/recipe_model.dart';
import 'package:nutriapp/providers/firestore_provider.dart';
import 'recipe_generation_page.dart';

class RecipePage extends HookConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recipesAsyncValue = ref.watch(recipesProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Recipes'),
      ),
      body: recipesAsyncValue.when(
        data: (recipes) => ListView.builder(
          itemCount: recipes.length,
          itemBuilder: (context, index) {
            final recipe = recipes[index];
            return ListTile(
              title: Text(recipe.title),
              subtitle: Text(recipe.description),
              onTap: () {
                // Navigate to recipe details
              },
            );
          },
        ),
        loading: () => Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => RecipeGenerationPage()),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}

final recipesProvider = FutureProvider<List<Recipe>>((ref) async {
  final firestoreService = ref.read(firestoreProvider);
  return firestoreService.getRecipes();
});
