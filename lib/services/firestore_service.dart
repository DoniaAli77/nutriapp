import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/meal_plan_model.dart';
import '../models/recipe_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<List<Recipe>> getRecipes() async {
    final snapshot = await _db.collection('recipes').get();
    return snapshot.docs.map((doc) => Recipe.fromFirestore(doc)).toList();
  }

  Future<List<MealPlan>> getMealPlans(String userId) async {
    final snapshot = await _db.collection('users').doc(userId).collection('mealPlans').get();
    return snapshot.docs.map((doc) => MealPlan.fromFirestore(doc)).toList();
  }

  Future<void> addRecipe(Recipe recipe) async {
    await _db.collection('recipes').add(recipe.toMap());
  }

  Future<void> addMealPlan(MealPlan mealPlan, String userId) async {
    await _db.collection('users').doc(userId).collection('mealPlans').add(mealPlan.toMap());
  }
}
