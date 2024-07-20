import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:animations/animations.dart';
import 'package:nutriapp/screens/loadingScreen.dart';
import 'calorie_tracking_page.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Fancy Recipe App'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset('assets/chef.json', width: 200, height: 200),
            SizedBox(height: 20),
            OpenContainer(
              closedBuilder: (context, action) => ElevatedButton(
                onPressed: action,
                child: Text('Track Calories'),
              ),
              openBuilder: (context, action) => LoadingScreen(),
              transitionType: ContainerTransitionType.fade,
              closedElevation: 0.0,
              openElevation: 0.0,
              closedShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              openShape: RoundedRectangleBorder(),
            ),
          ],
        ),
      ),
    );
  }
}
