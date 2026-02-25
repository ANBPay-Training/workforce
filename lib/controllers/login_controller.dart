import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/app_state.dart';
import '../services/auth_service.dart';
import '../l10n/app_localizations.dart';

class LoginController {
  final AuthService _authService = AuthService();
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  ValueNotifier<bool> isLoading = ValueNotifier(false);

  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    isLoading.dispose();
  }

  Future<String?> login(BuildContext context) async {
    final email = emailController.text.trim();
    final password = passwordController.text;
    isLoading.value = true;

    final locale = AppLocalizations.of(context)!;

    try {
      /// 1️⃣ Firebase Auth login
      final user = await _authService.signIn(
        email: email,
        password: password,
      );

      if (user == null) {
        return locale.errorUserNotFound;
      }

      final uid = user.uid;

      /// 2️⃣ Read from companies collection (Company = User)
      final companyDoc = await _db.collection('companies').doc(uid).get();

      if (!companyDoc.exists) {
        return locale.errorUserNotRegistered;
      }

      final data = companyDoc.data()!;

      final role = data['role'];
      final companyName = data['name'];
      final active = data['active'] ?? true;

      if (!active) {
        return locale.errorUserNotRegistered;
      }

      /// 3️⃣ Save to AppState
      AppState().setCompanyUser(
        authUserId: uid,
        role: role,
        companyName: companyName,
      );

      return null; // ✅ Success
    } catch (_) {
      return locale.errorLoginFailed;
    } finally {
      isLoading.value = false;
    }
  }

  Future<String?> resetPassword(BuildContext context, String email) async {
    final locale = AppLocalizations.of(context)!;

    if (email.isEmpty || !email.contains('@')) {
      return locale.invalidEmail;
    }

    try {
      await _authService.sendPasswordReset(email);
      return locale.resetPasswordSent;
    } catch (e) {
      return '${locale.errorGeneric} (${e.toString()})';
    }
  }
}
