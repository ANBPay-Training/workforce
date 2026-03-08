import 'package:flutter/material.dart';
import 'package:workforce/screens/user_branches_page.dart';
import 'package:workforce/widgets/login/password_field_widget.dart';
import '../controllers/login_controller.dart';
import '../l10n/app_localizations.dart';
import '../main.dart';
import '../models/app_state.dart';
import '../utils/logout_helper.dart';
import '../widgets/login/login_Button_Widget.dart';
import 'AdminDashboard.dart';
import 'Start_Work_Page.dart';
import 'branch_list_page.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

// State-class so that it can contain dynamic variables and changes in the UI.
class _LoginScreenState extends State<LoginScreen> {
  // Creates a unique key for the form and is used for checking and
  // validating the form.
  final _formKey = GlobalKey<FormState>();
  final LoginController _controller = LoginController();
// Contains the current user interface language which is Danish
  String _language = 'DA';

  final Color primaryBlue = const Color(0xFF2F80ED);
  final Color inputFillBlue = const Color(0xFFEAF2FD);

  @override
  void dispose() {
    _controller.dispose();
    // To free up all resources, safecleanup
    super.dispose();
  }

  // A method to display a small message at the bottom of the screen
  void _showMessage(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  Future<void> _handleLogin(BuildContext context) async {
    // First, it checks whether the form is valid or not.
    // If any of the fields are invalid, the method stops before continuing.
    if (!_formKey.currentState!.validate()) return;
    // Returned an error if login failed
    final error = await _controller.login(context);
    // Displays an error message and stops
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error)),
      );
      return;
    }
    // Decide navigation based on role stored in AppState
    final appState = AppState();

    /// 🔵 ADMIN
    if (appState.isAdmin) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const AdminDashboard()),
      );
    }

    /// 🟢 COMPANY
    else if (appState.isCompany) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => BranchListPage(
            companyId: appState.userId!,
            companyName: appState.companyName!,
          ),
        ),
      );
    }

    /// 🟣 EMPLOYEE
    else if (appState.isEmployee) {
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

  void _showResetPasswordDialog() {
    // Read the email address entered by the user.
    final resetEmailController = TextEditingController();
    // Display a popup on the screen.
    showDialog(
      // BuildContext is required to display the dialog on the current screen.
      context: context,
      // Uses Flutter’s standard dialog with a title, content, and action buttons.
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.resetPasswordTitle),
        // Text field for entering the user's email address.
        content: TextField(
          controller: resetEmailController,
          // Opens the appropriate email keyboard.
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(
              labelText: 'Email', hintText: 'user@company.com'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => LogoutHelper.logout(context),
          ),
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              // If the email is empty or invalid, an error message is displayed
              // and the process does not continue.
              final email = resetEmailController.text.trim();
              if (email.isEmpty || !email.contains('@')) {
                _showMessage(AppLocalizations.of(context)!.invalidEmail);
                return;
              }
              // Calls the resetPassword method in the controller.

              final error = await _controller.resetPassword(context, email);
              Navigator.pop(context);
              if (error != null)
                _showMessage(error);
              else
                _showMessage(
                  // Provides context to access translations
                  AppLocalizations.of(context)!.resetPasswordSent,
                );
            },
            child: const Text('Send'),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: inputFillBlue,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: primaryBlue, width: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: Center(
        child: Card(
          elevation: 4,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: SizedBox(
              width: 350,
              child: Form(
                key: _formKey,
                // Listens to isLoading inside the controller.
                child: ValueListenableBuilder<bool>(
                  valueListenable: _controller.isLoading,
                  // A clean and lightweight alternative to setState.
                  builder: (context, loading, _) {
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(AppLocalizations.of(context)!.signInTitle,
                            style: const TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 20),
                        DropdownButtonFormField<String>(
                          value: _language,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                          ),
                          items: [
                            DropdownMenuItem(
                              value: 'DA',
                              child: Text(
                                '${AppLocalizations.of(context)!.language}: Dansk',
                              ),
                            ),
                            DropdownMenuItem(
                              value: 'EN',
                              child: Text(
                                '${AppLocalizations.of(context)!.language}: English',
                              ),
                            ),
                          ],
                          onChanged: (value) {
                            if (value == null) return;

                            setState(() => _language = value);

                            MyApp.of(context).setLocale(
                              value == 'DA'
                                  ? const Locale('da')
                                  : const Locale('en'),
                            );
                          },
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: _controller.emailController,
                          decoration: _inputDecoration(
                            AppLocalizations.of(context)!.username,
                          ),
                          validator: (v) => v == null || v.trim().isEmpty
                              ? AppLocalizations.of(context)!.emailRequired
                              : null,
                        ),
                        const SizedBox(height: 12),
                        PasswordFieldWidget(
                          controller: _controller.passwordController,
                          label: AppLocalizations.of(context)!.password,
                          validator: (v) => v == null || v.isEmpty
                              ? AppLocalizations.of(context)!.passwordRequired
                              : null,
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: _showResetPasswordDialog,
                            child: Text(
                              AppLocalizations.of(context)!.forgotPassword,
                              style: TextStyle(color: primaryBlue),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        LoginButtonWidget(
                          isLoading: loading,
                          text: AppLocalizations.of(context)!.signIn,
                          color: primaryBlue,
                          onPressed: () => _handleLogin(context),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
