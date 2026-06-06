import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthHelper {
  static bool isLoggedIn() {
    return FirebaseAuth.instance.currentUser != null;
  }

  static void requireLogin(BuildContext context, VoidCallback onLoggedIn) {
    if (isLoggedIn()) {
      onLoggedIn();
    } else {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Login Diperlukan'),
          content: const Text('Kamu harus login untuk menggunakan fitur ini.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.pushNamed(context, '/login');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
              ),
              child: const Text('Login', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
    }
  }
}