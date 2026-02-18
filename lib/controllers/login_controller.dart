import 'package:flutter/material.dart';
import '../models/app_state.dart';
import '../services/auth_service.dart';
import '../l10n/app_localizations.dart';

class LoginController {
  final AuthService _authService = AuthService();
  // Controls the value of the email input field in the UI
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  // Keeps track of whether login is in progress
  ValueNotifier<bool> isLoading = ValueNotifier(false);

  // Called when the controller is no longer in use
  // Used to clean up memory to
  // prevent the app from slowing down
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    // Stops ValueNotifier and releases listeners
    isLoading.dispose();
  }

  Future<String?> login(BuildContext context) async {
    final email = emailController.text.trim();
    final password = passwordController.text;
    // Activates loading state
    isLoading.value = true;

    final locale = AppLocalizations.of(context)!;

    try {
      // Sign in with Firebase Auth
      final user = await _authService.signIn(
        email: email,
        password: password,
      );

      if (user == null) {
        return locale.errorUserNotFound;
      }
      // gets the role from Firestore
      final actualRole = await _authService.getUserRole();
      // Here we ensure that the user is actually registered in our system, and
      // that their role is specified.
      if (actualRole == null) {
        return locale.errorUserNotRegistered;
      }
      // Stores form values in the AppState class,
      // making them available across the entire application.
      AppState().setUserRole(actualRole);
      return null; // ✅ Success
    } catch (_) {
      // Unexpected error (network, Firebase, etc.)
      return locale.errorLoginFailed;
    } finally {
      // Stops loading regardless of success or error.”
      isLoading.value = false;
    }
  }

  /// Reset password
  /// Returns null if successful, otherwise an error message.
  Future<String?> resetPassword(BuildContext context, String email) async {
    final locale = AppLocalizations.of(context)!;
    // If the email is empty or has an invalid format.
    if (email.isEmpty || !email.contains('@')) {
      return locale.invalidEmail;
    }

    try {
      // Responsible for sending emails.
      await _authService.sendPasswordReset(email);
      return locale.resetPasswordSent;
    } catch (e) {
      return '${locale.errorGeneric} (${e.toString()})';
    }
  }
}
