import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class CalorieTrackingPage extends HookConsumerWidget {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _foodController = TextEditingController();
  final TextEditingController _caloriesController = TextEditingController();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final calorieState = ref.watch(calorieProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Calorie Tracking'),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            TextFormField(
              controller: _foodController,
              decoration: InputDecoration(labelText: 'Food Item'),
              validator: (value) => value!.isEmpty ? 'Enter a food item' : null,
            ),
            TextFormField(
              controller: _caloriesController,
              decoration: InputDecoration(labelText: 'Calories'),
              keyboardType: TextInputType.number,
              validator: (value) => value!.isEmpty ? 'Enter calories' : null,
            ),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  ref.read(calorieProvider.notifier).addCalories(
                    _foodController.text,
                    int.parse(_caloriesController.text),
                  );
                }
              },
              child: Text('Add'),
            ),
            Text('Total Calories: ${calorieState.totalCalories}'),
            Text('Remaining Calories: ${calorieState.remainingCalories}'),
          ],
        ),
      ),
    );
  }
}

final calorieProvider = StateNotifierProvider<CalorieNotifier, CalorieState>((ref) {
  return CalorieNotifier();
});

class CalorieNotifier extends StateNotifier<CalorieState> {
  CalorieNotifier() : super(CalorieState());

  void addCalories(String food, int calories) {
    state = state.copyWith(
      totalCalories: state.totalCalories + calories,
      remainingCalories: state.remainingCalories - calories,
    );
  }
}

class CalorieState {
  final int totalCalories;
  final int remainingCalories;

  CalorieState({
    this.totalCalories = 0,
    this.remainingCalories = 2000,
  });

  CalorieState copyWith({
    int? totalCalories,
    int? remainingCalories,
  }) {
    return CalorieState(
      totalCalories: totalCalories ?? this.totalCalories,
      remainingCalories: remainingCalories ?? this.remainingCalories,
    );
  }
}
