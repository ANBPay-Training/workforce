import 'package:flutter/material.dart';
import '../models/app_state.dart';
import '../screens/AdminDashboard.dart';
import '../screens/Start_Work_Page.dart';
import '../screens/branch_list_page.dart';
import '../screens/user_branches_page.dart';

class LoginNavigation {
  static void handle(BuildContext context) {
    // Decide navigation based on role stored in AppState
    final appState = AppState();

    /// 🔵 ADMIN
    if (appState.isAdmin) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const AdminDashboard()),
      );

      /// 🟢 COMPANY
    } else if (appState.isCompany) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => BranchListPage(
            companyId: appState.userId!,
            companyName: appState.companyName!,
          ),
        ),
      );

      /// 🟣 EMPLOYEE
    } else if (appState.isEmployee) {
      if (appState.isWorking &&
          appState.activeCompanyId != null &&
          appState.activeBranchId != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => StartWorkPage(
              employeeId: appState.userId!,
              companyId: appState.activeCompanyId!,
              branchId: appState.activeBranchId!,
              companyName: '',
              branchName: '',
            ),
          ),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => UserBranchesPage(
              userId: appState.userId!,
            ),
          ),
        );
      }
    }
  }
}
