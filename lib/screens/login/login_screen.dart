import 'package:flutter/material.dart';
import 'package:workforce/screens/login/widgets/reset_password_dialog.dart';
import 'package:workforce/screens/user_branches_page.dart';
import 'package:workforce/screens/login/widgets/password_field_widget.dart';
import '../../../../controllers/login_controller.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../main.dart';
import '../../utils/input_decoration.dart';
import '../../utils/login_navigation.dart';
import 'widgets/login_Button_Widget.dart';

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
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error)));
      return;
    }
    LoginNavigation.handle(context);
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
                          decoration: InputDecorations.authField(
                            label: AppLocalizations.of(context)!.username,
                            fillColor: inputFillBlue,
                            focusColor: primaryBlue,
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
                            onPressed: () {
                              ResetPasswordDialog.show(context, _controller);
                            },
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
