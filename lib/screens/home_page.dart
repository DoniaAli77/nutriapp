import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:firebase_core/firebase_core.dart';

import 'calorie_tracking_page.dart';



void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  @override
    final auth = FirebaseAuth.instance; 

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Calorie Tracker'),
         actions: [
            Container(
              margin: EdgeInsets.only(right: 30),
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
        child: ListView.builder(
          itemCount: 9, // Adjust based on the number of items you want to display
          itemBuilder: (context, index) {
            switch (index) {
              case 0:
                return Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('12:23', style: TextStyle(fontSize: 24)),
                        Icon(Icons.notifications),
                      ],
                    ),
                    SizedBox(height: 20),
                    Center(
                      child: Column(
                        children: [
                          Text('1783', style: TextStyle(fontSize: 48)),
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
                  ],
                );
              case 1:
                return SizedBox(height: 20);
              case 2:
                return Divider();
              case 3:
                return SizedBox(height: 20);
              case 4:
                return DietPlanCard();
              case 5:
                return SizedBox(height: 20);
              case 6:
                return SuggestedRecipes();
              case 7:
                return Column(
                  children: [
                    SizedBox(height: 20),
                    MealCard(mealType: 'Breakfast', calories: 534, food: 'Kofta (0 Cal)'),
                    SizedBox(height: 10),
                    MealCard(mealType: 'Lunch', calories: 534),
                    SizedBox(height: 10),
                    MealCard(mealType: 'Dinner', calories: 534),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => TrackingPage()),
                        );
                      },
                      child: Text('Scan Image for Calories'),
                    ),
                  ],
                );
              default:
                return SizedBox.shrink();
            }
          },
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Coach'),
          BottomNavigationBarItem(icon: Icon(Icons.book), label: 'Journal'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

class DietPlanCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Text('Diet Plan', style: TextStyle(fontSize: 18)),
              ],
            ),
            SizedBox(height: 10),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('diet_plans').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return CircularProgressIndicator();
                }
                final plans = snapshot.data!.docs;
                return Column(
                  children: plans.map((plan) {
                    return DietPlanWeek(
                      week: plan['week'],
                      description: plan['description'],
                    );
                  }).toList(),
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
  final String description;

  DietPlanWeek({required this.week, required this.description});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(week, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        Text(description, style: TextStyle(fontSize: 14, color: Colors.grey)),
        SizedBox(height: 10),
      ],
    );
  }
}

class SuggestedRecipes extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Text('Suggested Recipes', style: TextStyle(fontSize: 18)),
              ],
            ),
            SizedBox(height: 10),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('recipes').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return CircularProgressIndicator();
                }
                final recipes = snapshot.data!.docs;
                return Column(
                  children: recipes.map((recipe) {
                    return RecipeCard(
                      image: recipe['image'],
                      name: recipe['name'],
                      calories: recipe['calories'],
                    );
                  }).toList(),
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
  final String image;
  final String name;
  final int calories;

  RecipeCard({required this.image, required this.name, required this.calories});

  Future<void> addCalories(int caloriesToAdd) async {
    final docRef = FirebaseFirestore.instance.collection('calories').doc('today');
    final snapshot = await docRef.get();
    if (snapshot.exists) {
      int currentCalories = snapshot.data()!['calories'] ?? 0;
      await docRef.update({'calories': currentCalories + caloriesToAdd});
    } else {
      await docRef.set({'calories': caloriesToAdd});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Image.network(image, width: 50, height: 50, fit: BoxFit.cover),
        title: Text(name),
        subtitle: Text('$calories Cal'),
        trailing: IconButton(
          icon: Icon(Icons.add_circle),
          onPressed: () => addCalories(calories),
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
