import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nutriapp/providers/user_provider.dart';


class ProfilePage extends HookConsumerWidget {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _dietaryRestrictionsController = TextEditingController();
  final TextEditingController _goalsController = TextEditingController();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsyncValue = ref.watch(userProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
      ),
      body: userAsyncValue.when(
        data: (user) {
          if (user != null) {
            _nameController.text = user.displayName;
            // Load other user data if needed
            return Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(labelText: 'Name'),
                    validator: (value) => value!.isEmpty ? 'Enter your name' : null,
                  ),
                  TextFormField(
                    controller: _dietaryRestrictionsController,
                    decoration: InputDecoration(labelText: 'Dietary Restrictions'),
                    // Set initial value from user profile if needed
                  ),
                  TextFormField(
                    controller: _goalsController,
                    decoration: InputDecoration(labelText: 'Goals'),
                    // Set initial value from user profile if needed
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        // Save profile changes to Firestore
                        Navigator.pop(context);
                      }
                    },
                    child: Text('Save'),
                  ),
                ],
              ),
            );
          } else {
            return Center(child: Text('No user data available'));
          }
        },
        loading: () => Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
      ),
    );
  }
}
