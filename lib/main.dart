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
import 'package:nutriapp/screens/register_page.dart';
import 'firebase_options.dart'; // Make sure you have Firebase options configured


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  runApp(
    ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _initialized = false; 
  bool _error = false; 
 
  // Define an async function to initialize FlutterFire 
  void initializeFlutterFire() async { 
    try { 
      // Wait for Firebase to initialize and set `_initialized` state to true 
      await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
);
 
      setState(() { 
        _initialized = true; 
      }); 
    } catch(e) { 
      // Set `_error` state to true if Firebase initialization fails 
      setState(() { 
        _error = true; 
      
      }); 
    } 
  } 
 
  void initState() { 
   
    initializeFlutterFire(); 
    super.initState(); 
  }
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Recipe App',
       theme: ThemeData(
        primarySwatch: Colors.blue,
        textTheme: TextTheme(
        
        ), 
        buttonTheme: ButtonThemeData(
          buttonColor: Colors.purple, // Background color for buttons
          textTheme: ButtonTextTheme.primary,
        ),
        appBarTheme: AppBarTheme(
          color: Colors.purple,
        
        ),
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => LoginPage(),
        '/register':(context)=> RegisterPage(),
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
