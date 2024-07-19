import 'package:cloud_firestore/cloud_firestore.dart';

class CalorieEntry {
  final String id;
  final String foodItem;
  final int calories;

  CalorieEntry({
    required this.id,
    required this.foodItem,
    required this.calories,
  });

  factory CalorieEntry.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CalorieEntry(
      id: doc.id,
      foodItem: data['foodItem'],
      calories: data['calories'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'foodItem': foodItem,
      'calories': calories,
    };
  }
}
