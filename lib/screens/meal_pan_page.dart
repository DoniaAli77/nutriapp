import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nutriapp/models/meal_plan_model.dart';
import 'package:nutriapp/providers/firestore_provider.dart';
import 'package:nutriapp/providers/user_provider.dart';
import 'package:nutriapp/screens/meal_page_creation.dart';


class MealPlanPage extends HookConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsyncValue = ref.watch(userProvider);
    final mealPlansProvider = FutureProvider.family<List<MealPlan>, String>((ref, userId) {
      final firestoreService = ref.read(firestoreProvider);
      return firestoreService.getMealPlans(userId);
    });

    return userAsyncValue.when(
      data: (user) {
        if (user != null) {
          final mealPlansAsyncValue = ref.watch(mealPlansProvider(user.uid));

          return Scaffold(
            appBar: AppBar(
              title: Text('Meal Plans'),
            ),
            body: mealPlansAsyncValue.when(
              data: (mealPlans) => ListView.builder(
                itemCount: mealPlans.length,
                itemBuilder: (context, index) {
                  final mealPlan = mealPlans[index];
                  return ListTile(
                    title: Text(mealPlan.title),
                    subtitle: Text(mealPlan.description),
                    onTap: () {
                      // Navigate to meal plan details
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
                  MaterialPageRoute(builder: (context) => MealPlanCreationPage()),
                );
              },
              child: Icon(Icons.add),
            ),
          );
        } else {
          return Center(child: Text('Not logged in'));
        }
      },
      loading: () => Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(child: Text('Error: $error')),
    );
  }
}
