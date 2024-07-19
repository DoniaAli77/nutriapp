import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nutriapp/models/meal_plan_model.dart';
import 'package:nutriapp/providers/firestore_provider.dart';

class MealPlanCreationPage extends HookConsumerWidget {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _mealsController = TextEditingController();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Meal Plan'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(labelText: 'Title'),
                validator: (value) => value!.isEmpty ? 'Enter a title' : null,
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: 'Description'),
                validator: (value) => value!.isEmpty ? 'Enter a description' : null,
              ),
              TextFormField(
                controller: _mealsController,
                decoration: InputDecoration(labelText: 'Meals (comma-separated)'),
                validator: (value) => value!.isEmpty ? 'Enter meals' : null,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    final title = _titleController.text;
                    final description = _descriptionController.text;
                    final meals = _mealsController.text.split(',').map((meal) => meal.trim()).toList();

                    final mealPlan = MealPlan(
                      id: '', // Empty ID; Firestore will generate this
                      title: title,
                      description: description,
                      meals: meals,
                    );

                    final firestoreService = ref.read(firestoreProvider);
                    await firestoreService.addMealPlan(mealPlan, 'your-user-id'); // Replace 'your-user-id' with the actual user ID

                    Navigator.pop(context);
                  }
                },
                child: Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
