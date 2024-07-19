import 'package:cloud_firestore/cloud_firestore.dart';

class MealPlan {
  final String id;
  final String title;
  final String description;
  final List<String> meals;

  MealPlan({
    required this.id,
    required this.title,
    required this.description,
    required this.meals,
  });

  factory MealPlan.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return MealPlan(
      id: doc.id,
      title: data['title'],
      description: data['description'],
      meals: List<String>.from(data['meals']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'meals': meals,
    };
  }
}
