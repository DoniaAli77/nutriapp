import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_hooks/flutter_hooks.dart';



class MyHomePage extends HookWidget {
  @override
  Widget build(BuildContext context) {
    Future<Map<String, dynamic>> getUserInfo() async {
      try {
        var userId = FirebaseAuth.instance.currentUser!.uid;
        var userData = await FirebaseFirestore.instance.collection("users").doc(userId).get();

        if (userData.exists) {
          return userData.data()!;
        } else {
          return {'Error': 'No data'};
        }
      } catch (e) {
        print("Error getting document: $e");
        return {"Error": "Error getting document"};
      }
    }

    final userCalorie = useState(0.0);
    final userdata = useFuture(useMemoized(getUserInfo, []));

    return Scaffold(
      appBar: AppBar(
        title: Text('Calorie Tracker'),
        actions: [
          IconButton(
            onPressed: () {
              FirebaseAuth.instance.signOut();
            },
            icon: Icon(Icons.logout_rounded),
          ),
        ],
      ),
      body: AnimatedSwitcher(
        duration: Duration(milliseconds: 300),
        child: userdata.connectionState == ConnectionState.waiting
            ? Center(child: CircularProgressIndicator())
            : userdata.hasError
                ? Center(child: Text('Error: ${userdata.error}'))
                : userdata.hasData
                    ? CalorieContent(userCalorie: userCalorie, userdata: userdata)
                    : Center(child: Text('Unexpected state')),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        onTap: (index) {
          if (index == 1) {
            Navigator.pushNamed(context, '/calorie');
          }
          if (index == 2) {
            Navigator.pushNamed(context, '/profile');
          }
        },
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Coach'),
          BottomNavigationBarItem(icon: Icon(Icons.upload), label: 'Scan'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

class CalorieContent extends StatelessWidget {
  final ValueNotifier<double> userCalorie;
  final AsyncSnapshot<Map<String, dynamic>> userdata;

  CalorieContent({required this.userCalorie, required this.userdata});

  @override
  Widget build(BuildContext context) {
    userCalorie.value = double.parse(userdata.data!['Total_Daily_Calories'] ?? '0.0');

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView(
        children: [
          SizedBox(height: 20),
          Center(
            child: Column(
              children: [
                Text(
                  userCalorie.value.toString(),
                  style: Theme.of(context).textTheme.displayLarge,
                ),
                Text('Cal Left', style: Theme.of(context).textTheme.headlineMedium),
              ],
            ),
          ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              CalorieInfo(label: 'Eaten', value: '0'),
              CalorieInfo(label: 'Burned', value: '0'),
            ],
          ),
          SizedBox(height: 20),
          Divider(),
          SizedBox(height: 20),
          DietPlanCard(),
          SizedBox(height: 20),
          SuggestedRecipes(),
          SizedBox(height: 20),
          Column(
            children: [
              MealCard(mealType: 'Breakfast', calories: 534, food: 'Kofta (0 Cal)'),
              SizedBox(height: 10),
              MealCard(mealType: 'Lunch', calories: 534),
              SizedBox(height: 10),
              MealCard(mealType: 'Dinner', calories: 534),
              SizedBox(height: 20),
            ],
          ),
        ],
      ),
    );
  }
}

class CalorieInfo extends StatelessWidget {
  final String label;
  final String value;

  CalorieInfo({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.teal)),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

class DietPlanCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser!.uid;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Diet Plan', style: Theme.of(context).textTheme.headlineSmall),
            SizedBox(height: 10),
            StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance.collection('plans').doc(userId).snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                final data = snapshot.data!.data() as Map<String, dynamic>? ?? {};
                final weeks = data['weeks'] as Map<String, dynamic>? ?? {};

                return Container(
                  height: 300,
                  child: PageView.builder(
                    itemCount: weeks.length,
                    itemBuilder: (context, index) {
                      final weekKey = weeks.keys.elementAt(index);
                      final weekData = weeks[weekKey] as Map<String, dynamic>? ?? {};
                      return DietPlanWeek(
                        week: weekKey,
                        totalCalories: weekData['Total Weekly Calories'] ?? 'N/A',
                        dailyMeals: weekData['Daily Meals'] as Map<String, dynamic>? ?? {},
                        mealRecipes: weekData['Meal Recipes'] as Map<String, dynamic>? ?? {},
                      );
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class DietPlanWeek extends StatelessWidget {
  final String week;
  final String totalCalories;
  final Map<String, dynamic> dailyMeals;
  final Map<String, dynamic> mealRecipes;

  DietPlanWeek({
    required this.week,
    required this.totalCalories,
    required this.dailyMeals,
    required this.mealRecipes,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(week, style: Theme.of(context).textTheme.headlineMedium),
            SizedBox(height: 8),
            Text(
              'Total Weekly Calories: $totalCalories',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            SizedBox(height: 16),
            for (var entry in dailyMeals.entries) ...[
              Text(entry.key, style: Theme.of(context).textTheme.bodyLarge),
              MealSection(mealType: 'Breakfast', meal: entry.value['Breakfast'] ?? 'No Breakfast'),
              MealSection(mealType: 'Lunch', meal: entry.value['Lunch'] ?? 'No Lunch'),
              MealSection(mealType: 'Dinner', meal: entry.value['Dinner'] ?? 'No Dinner'),
              SizedBox(height: 16),
            ],
            SizedBox(
              height: 200,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: mealRecipes.keys.length,
                itemBuilder: (context, index) {
                  final mealType = mealRecipes.keys.elementAt(index);
                  final mealData = mealRecipes[mealType] as Map<String, dynamic>? ?? {};
                  return MealRecipeCard(
                    mealType: mealType,
                    meal: mealData['Meal'] ?? 'No meal',
                    totalCalories: mealData['total calories for this meal'] ?? 'No total',
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MealSection extends StatelessWidget {
  final String mealType;
  final String meal;

  MealSection({required this.mealType, required this.meal});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 8),
        Text('$mealType: $meal', style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }
}

class SuggestedRecipes extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser!.uid;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Suggested Recipes', style: Theme.of(context).textTheme.headlineMedium),
            SizedBox(height: 10),
            StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance.collection('suggested_recipes').doc(userId).snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                final data = snapshot.data!.data() as Map<String, dynamic>? ?? {};
                final recipes = data.entries.toList();

                return Container(
                  height: 200,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: recipes.length,
                    itemBuilder: (context, index) {
                      final recipeData = recipes[index].value as Map<String, dynamic>? ?? {};
                      return RecipeCard(
                        name: recipeData['recipe_name'] ?? 'No name',
                        ingredients: recipeData['Ingredients'] ?? 'No ingredients',
                        instructions: recipeData['Instructions'] ?? 'No instructions',
                        totalCalories: recipeData['total calories'] ?? 'No total',
                      );
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class RecipeCard extends StatelessWidget {
  final String name;
  final String ingredients;
  final String instructions;
  final String totalCalories;

  RecipeCard({
    required this.name,
    required this.ingredients,
    required this.instructions,
    required this.totalCalories,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RecipeDetailPage(
              name: name,
              ingredients: ingredients,
              instructions: instructions,
            ),
          ),
        );
      },
      child: Card(
        margin: EdgeInsets.symmetric(horizontal: 8.0),
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Container(
          width: 150,
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: Theme.of(context).textTheme.headlineSmall),
              SizedBox(height: 8),
              Text('Ingredients: $ingredients', maxLines: 2, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.bodySmall),
              Text('Instructions: $instructions', maxLines: 2, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.bodySmall),
              Text('Total Calories: $totalCalories', style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),
      ),
    );
  }
}

class RecipeDetailPage extends StatelessWidget {
  final String name;
  final String ingredients;
  final String instructions;

  RecipeDetailPage({required this.name, required this.ingredients, required this.instructions});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(name),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Ingredients', style: Theme.of(context).textTheme.headlineMedium),
            SizedBox(height: 8),
            Text(ingredients, style: Theme.of(context).textTheme.bodyLarge),
            SizedBox(height: 16),
            Text('Instructions', style: Theme.of(context).textTheme.headlineMedium),
            SizedBox(height: 8),
            Text(instructions, style: Theme.of(context).textTheme.bodyLarge),
          ],
        ),
      ),
    );
  }
}

class MealCard extends StatelessWidget {
  final String mealType;
  final int calories;
  final String? food;

  MealCard({required this.mealType, required this.calories, this.food});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(Icons.restaurant_menu, color: Colors.teal),
        title: Text(mealType, style: Theme.of(context).textTheme.headlineSmall),
        subtitle: food != null ? Text(food!, style: Theme.of(context).textTheme.bodyMedium) : null,
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('0 / $calories Cal', style: Theme.of(context).textTheme.bodyMedium),
            Icon(Icons.add_circle, color: Colors.teal),
          ],
        ),
      ),
    );
  }
}

class MealRecipeCard extends StatelessWidget {
  final String mealType;
  final String meal;
  final String totalCalories;

  MealRecipeCard({required this.mealType, required this.meal, required this.totalCalories});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 8.0),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: 150,
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(mealType, style: Theme.of(context).textTheme.headlineSmall),
            SizedBox(height: 8),
            Text('Meal: $meal', maxLines: 2, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.bodySmall),
            Text('Total Calories: $totalCalories', style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}
