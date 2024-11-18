// ignore_for_file: use_build_context_synchronously

import 'package:auth_firebase_app/services/auth_service.dart';
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthService authService = AuthService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Page'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            try {
              await authService.signOut(); // Call signOut from AuthService
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('You have been logged out')),
              );
              Navigator.pushReplacementNamed(
                  context, '/sign_in'); // Redirect to login page after logout
            } catch (e) {
              // Handle errors if sign-out fails
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Sign out failed: $e')),
              );
            }
          },
          child: const Text('Sign Out'),
        ),
      ),
    );
  }
}
