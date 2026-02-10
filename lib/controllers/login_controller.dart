import 'package:flutter/material.dart';
import '../models/app_state.dart';
import '../services/auth_service.dart';
import '../l10n/app_localizations.dart';

class LoginController {
  final AuthService _authService = AuthService();
// Styrer værdien af email-inputfeltet i UI
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

// Holder styr på om login er i gang
  ValueNotifier<bool> isLoading = ValueNotifier(false);

// 🔹 Kaldes når controlleren ikke længere bruges
// 🔹 Bruges til at rydde op i hukommelsen for
// at forhindre at appen bliver langsommere
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    // Stopper ValueNotifier og frigør lyttere
    isLoading.dispose();
  }

  Future<String?> login(BuildContext context) async {
    final email = emailController.text.trim();
    final password = passwordController.text;
    // Aktiverer loading-state
    isLoading.value = true;

    final locale = AppLocalizations.of(context)!;

    try {
      // Sign in med Firebase Auth
      final user = await _authService.signIn(
        email: email,
        password: password,
      );

      if (user == null) {
        return locale.errorUserNotFound;
      }
// får rolen fra Firestore
      final actualRole = await _authService.getUserRole();
// sikrer vi os, at brugeren rent faktisk er registreret i vores system, og
// at deres rolle er angivet.
      if (actualRole == null) {
        return locale.errorUserNotRegistered;
      }
      // Gemmer formularværdier i AppState-classe,
      // så de er tilgængelige i hele applikationen.
      AppState().setUserRole(actualRole);
      return null; // ✅ Success
    } catch (_) {
      // Uventet fejl (netværk, Firebase osv.)
      return locale.errorLoginFailed;
    } finally {
      // Stopper loading uanset succes eller fejl
      isLoading.value = false;
    }
  }

  /// Nulstil adgangskode
  /// Returnerer null hvis det lykkedes, ellers fejlmeddelelse
  Future<String?> resetPassword(BuildContext context, String email) async {
    final locale = AppLocalizations.of(context)!;
// hvis e-mailen er tom, eller e-mailstrukturen er forkert.
    if (email.isEmpty || !email.contains('@')) {
      return locale.invalidEmail;
    }

    try {
      // Ansvarlig for at sende e-mails
      await _authService.sendPasswordReset(email);
      return locale.resetPasswordSent;
    } catch (e) {
      return '${locale.errorGeneric} (${e.toString()})';
    }
  }
}
