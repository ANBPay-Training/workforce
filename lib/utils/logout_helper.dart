import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/app_state.dart';
import '../screens/login_screen.dart';

class LogoutHelper {
  static Future<void> logout(BuildContext context) async {
    // Sign out from Firebase
    await FirebaseAuth.instance.signOut();

    // Clear in-memory app state
    AppState().clear();

    // Remove all previous pages and go to LoginScreen
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }
}
