import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:nutriapp/screens/Goal.dart';
// import 'package:nutriapp/screens/home_page.dart';
import 'firebase_options.dart';
import 'screens/auth_screen.dart';
import 'screens/home2.dart';
import 'screens/home_page.dart';
import 'screens/loadingScreen.dart';

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
      title: 'NutriApp',
      theme: ThemeData(
        primarySwatch: Colors.blue,
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
                    return MyHomePage();
                  }
                  return LoginScreen();
                },
              )
            : LoadingScreen(),
        '/home': (ctx) => MyHomePage(),
        '/login': (ctx) => LoginScreen(),
        '/loading': (ctx) => LoadingScreen(),
        '/goal': (ctx) => Goal(),
      },
    );
  }
}
