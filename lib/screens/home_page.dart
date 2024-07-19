import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nutriapp/providers/user_provider.dart';

class HomePage extends HookConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsyncValue = ref.watch(userProvider);

    return Scaffold(
      
      appBar: AppBar(
        title: Text('Home'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              final authService = ref.read(authServiceProvider);
              await authService.signOut();
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      body: userAsyncValue.when(
        data: (user) {
          if (user != null) {
            return Center(child: Text('Welcome ${user.displayName}!'));
          } else {
            return Center(child: Text('Not logged in'));
          }
        },
        loading: () => Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
      ),
      bottomNavigationBar: BottomNavigationBar(
        
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          BottomNavigationBarItem(icon: Icon(Icons.menu_book), label: 'Recipes'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: 'Meal Plans'),
          BottomNavigationBarItem(icon: Icon(Icons.fastfood), label: 'Calories'),
        ],
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.pushNamed(context, '/profile');
              break;
            case 1:
              Navigator.pushNamed(context, '/recipes');
              break;
            case 2:
              Navigator.pushNamed(context, '/mealplans');
              break;
            case 3:
              Navigator.pushNamed(context, '/calories');
              break;
          }
        },
      
       backgroundColor: Colors.blue, // Background color of the bar
  selectedItemColor: Colors.white, // Color of the selected item
  unselectedItemColor: Colors.grey[400], // Color of unselected items
      ),
    );
  }
}
