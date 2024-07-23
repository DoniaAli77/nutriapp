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
        var userData = await FirebaseFirestore.instance
            .collection("users")
            .doc(userId)
            .get();

        if (userData.exists) {
          return userData.data()!;
        } else {
          return {'Error': 'nodata'};
        }
      } catch (e) {
        print("Error getting document: $e");
        return {"Error": "Error getting document"};
      }
    }

    final userCalorie = useState(0.0);
    final userdata = useFuture(useMemoized(getUserInfo, []));

    if (userdata.connectionState == ConnectionState.waiting) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Calorie Tracker'),
        ),
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    } else if (userdata.hasError) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Calorie Tracker'),
        ),
        body: Center(
          child: Text('Error: ${userdata.error}'),
        ),
      );
    } else if (userdata.hasData) {
      userCalorie.value =
          double.parse(userdata.data!['Total_Daily_Calories'] ?? '0.0');

      return Scaffold(
        appBar: AppBar(
          title: Text('Calorie Tracker'),
          actions: [
            Container(
              child: IconButton(
                  onPressed: () {
                    FirebaseAuth.instance.signOut();
                  },
                  icon: Icon(Icons.logout_rounded)),
            )
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            children: [
              SizedBox(height: 20),
              Center(
                child: Column(
                  children: [
                    Text(userCalorie.value.toString(),
                        style: TextStyle(fontSize: 48)),
                    Text('Cal Left', style: TextStyle(fontSize: 18)),
                  ],
                ),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      Text('0', style: TextStyle(fontSize: 24)),
                      Text('Eaten', style: TextStyle(fontSize: 18)),
                    ],
                  ),
                  Column(
                    children: [
                      Text('0', style: TextStyle(fontSize: 24)),
                      Text('Burned', style: TextStyle(fontSize: 18)),
                    ],
                  ),
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
                  MealCard(
                      mealType: 'Breakfast',
                      calories: 534,
                      food: 'Kofta (0 Cal)'),
                  SizedBox(height: 10),
                  MealCard(mealType: 'Lunch', calories: 534),
                  SizedBox(height: 10),
                  MealCard(mealType: 'Dinner', calories: 534),
                  SizedBox(height: 20),
                ],
              ),
            ],
          ),
        ),
        bottomNavigationBar: Hero(
          tag: 'hero',
          child: BottomNavigationBar(
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
              BottomNavigationBarItem(
                  icon: Icon(Icons.person), label: 'Profile'),
            ],
          ),
        ),
      );
    } else {
      return Scaffold(
        appBar: AppBar(
          title: Text('Calorie Tracker'),
        ),
        body: Center(
          child: Text('Unexpected state'),
        ),
      );
    }
  }
}

class DietPlanCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser!.uid;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Diet Plan', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('plans')
                  .doc(userId)
                  .snapshots(),
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
                  height: 300,  // Adjust the height as needed
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
            Text(
              week,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Total Weekly Calories: $totalCalories',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text(
              'Daily Meals:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            ...dailyMeals.entries.map((entry) {
              final day = entry.key;
              final meals = entry.value as Map<String, dynamic>? ?? {};
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 8),
                  Text(day, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                  Text('Breakfast: ${meals['Breakfast'] ?? 'N/A'}'),
                  Text('Lunch: ${meals['Lunch'] ?? 'N/A'}'),
                  Text('Dinner: ${meals['Dinner'] ?? 'N/A'}'),
                  Text('Snack: ${meals['Snack'] ?? 'N/A'}'),
                ],
              );
            }).toList(),
            SizedBox(height: 16),
            Text(
              'Meal Recipes:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Container(
              height: 200,  // Adjust the height as needed
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: mealRecipes.length,
                itemBuilder: (context, index) {
                  final mealType = mealRecipes.keys.elementAt(index);
                  final recipe = mealRecipes[mealType] as Map<String, dynamic>? ?? {};
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: RecipeCard(
                      name: recipe['meal_name'] ?? 'No name',
                      ingredients: recipe['Ingredients'] ?? 'No ingredients',
                      instructions: recipe['Instructions'] ?? 'No instructions',
                      totalCalories:recipe['total calories for this meal'] ?? 'No total',

                    ),
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

class SuggestedRecipes extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser!.uid;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Suggested Recipes', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('suggested_recipes')
                  .doc(userId)
                  .snapshots(),
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
                  color: Colors.white,
                  height: 200,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: recipes.length,
                    reverse: true,
                    itemBuilder: (context, index) {
                      final recipeData = recipes[index].value as Map<String, dynamic>? ?? {};
                      print(recipeData);
                      return RecipeCard(
                        name: recipeData['recipe_name'] ?? 'No name',
                        ingredients: recipeData['Ingredients'] ?? 'No ingredients',
                        instructions: recipeData['Instructions'] ?? 'No instructions',
                        totalCalories:recipeData['total calories'] ?? 'No total',
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
    required this.totalCalories
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
        child: Container(
          width: 150,
          child: ListTile(
            title: Text(name),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Ingredients: $ingredients'),
                Text('Instructions: $instructions'),
                Text('totalCalories: $totalCalories')
              ],
            ),
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

  RecipeDetailPage({
    required this.name,
    required this.ingredients,
    required this.instructions,
  });

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
            Text('Ingredients', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text(ingredients, style: TextStyle(fontSize: 16)),
            SizedBox(height: 16),
            Text('Instructions', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text(instructions, style: TextStyle(fontSize: 16)),
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
      child: ListTile(
        leading: Icon(Icons.restaurant_menu),
        title: Text(mealType),
        subtitle: food != null ? Text(food!) : null,
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('0 / $calories Cal'),
            Icon(Icons.add_circle),
          ],
        ),
      ),
    );
  }
}
