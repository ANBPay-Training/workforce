import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/app_state.dart';
import '../models/employee.dart';
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
      final user = await _authService.signIn(
        email: email,
        password: password,
      );

      if (user == null) {
        return locale.errorUserNotFound;
      }

      final uid = user.uid;

      /// 1️⃣ Check companies collection
      final companyDoc = await _db.collection('companies').doc(uid).get();

      if (companyDoc.exists) {
        final data = companyDoc.data()!;

        AppState().setCompanyUser(
          authUserId: uid,
          role: data['role'],
          companyName: data['name'],
        );

        return null; // success
      }

      /// 2️⃣ Otherwise check employees collection
      final employeeDoc = await _db.collection('employees').doc(uid).get();
      print("EMPLOYEE DATA: ${employeeDoc.data()}");
      final data = employeeDoc.data()!;
      if (employeeDoc.exists) {
        final employee = Employee.fromFirestore(
          employeeDoc.id,
          data,
        );
        print("COMPANY IDS: ${employee.companyIds}");

        AppState().setEmployeeUser(
          authUserId: uid,
          role: employee.role,
          employeeName: employee.name,
          companyIds: employee.companyIds,
          isWorking: data['isWorking'] ?? false,
          activeCompanyId: data['activeCompanyId'],
          activeBranchId: data['activeBranchId'],
        );

        return null; // success
      }

      return locale.errorUserNotRegistered;
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
