import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:nutriapp/screens/Goal.dart';
import 'package:nutriapp/screens/analyze.dart';
// import 'package:nutriapp/screens/home_page.dart';
import 'firebase_options.dart';
import 'screens/auth_screen.dart';
import 'screens/calorie_tracking_page.dart';
import 'screens/home2.dart';
import 'screens/home_page.dart';
import 'screens/loadingScreen.dart';
import 'screens/profile.dart';
import 'screens/setgoalorpass.dart';
import 'screens/userdetailsScreen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _initialized = false;
  bool _error = false;

  void initializeFlutterFire() async {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      setState(() {
        _initialized = true;
      });
    } catch (e) {
      setState(() {
        _error = true;
      });
    }
  }

  @override
  void initState() {
    initializeFlutterFire();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'NutriApp',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        // accentColor: Colors.orangeAccent,
       textTheme: TextTheme(
          displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.black),
          displayMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black),
          displaySmall: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
          headlineLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.teal),
          headlineMedium: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.teal),
          headlineSmall: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.teal),
          titleLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.teal),
          titleMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.teal),
          titleSmall: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.teal),
          bodyLarge: TextStyle(fontSize: 16, color: Colors.grey[800]),
          bodyMedium: TextStyle(fontSize: 14, color: Colors.grey[600]),
          bodySmall: TextStyle(fontSize: 12, color: Colors.grey[600]),
          labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.teal),
        ),
        scaffoldBackgroundColor: Colors.white,
        useMaterial3: true,
        appBarTheme: AppBarTheme(
          elevation: 1,
          backgroundColor: Colors.white,
          iconTheme: IconThemeData(color: Colors.black)

        ),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
    
      initialRoute: '/',
      routes: {
        '/': (ctx) => _initialized
            ? StreamBuilder(
                stream: FirebaseAuth.instance.authStateChanges(),
                builder: (ctx, userSnapshot) {
                  if (userSnapshot.connectionState == ConnectionState.waiting) {
                    return LoadingScreen();
                  }
                  if (userSnapshot.hasData) {
                    return HomePage();
                  }
                  return LoginScreen();
                },
              )
            : LoadingScreen(),
        '/home': (ctx) => MyHomePage(),
        '/track':(ctx)=>HomePage(),
        '/login': (ctx) => LoginScreen(),
        '/loading': (ctx) => LoadingScreen(),
        '/goal': (ctx) => Goal(),
        '/calorie':(ctx)=>TrackingPage(),
        '/profile':(ctx)=>ProfilePage(),
        '/analyze':(ctx)=> AnalyzePage(),
        '/setorpass': (ctx) => Setgoalorpass(),
        '/PersonalDetailsPage':(ctx) => UserDetailsScreen(),
      },
    );
  }
}
