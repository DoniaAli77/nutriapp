import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nutriapp/screens/calorie_tracking_page.dart';
import 'package:nutriapp/screens/home_page.dart';
import 'package:nutriapp/screens/login_page.dart';
import 'package:nutriapp/screens/meal_pan_page.dart';
import 'package:nutriapp/screens/profile_page.dart';
import 'package:nutriapp/screens/recipe_generation_page.dart';
import 'package:nutriapp/screens/recipe_page.dart';
import 'firebase_options.dart'; // Make sure you have Firebase options configured

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(
    ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Recipe App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => LoginPage(),
        '/home': (context) => HomePage(),
        '/profile': (context) => ProfilePage(),
        '/recipes': (context) => RecipePage(),
        '/mealplans': (context) => MealPlanPage(),
        '/calories': (context) => CalorieTrackingPage(),
        '/generate_recipe': (context) => RecipeGenerationPage(),
      },
    );
  }
}
