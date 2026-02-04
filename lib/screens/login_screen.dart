import 'package:flutter/material.dart';
import 'package:workforce/widgets/login/password_field_widget.dart';
import '../controllers/login_controller.dart';
import '../l10n/app_localizations.dart';
import '../main.dart';
import '../models/app_state.dart';
import '../widgets/login/login_Button_Widget.dart';
import 'AdminDashboard.dart';
import 'QuickShiftPage.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

// State-klasse for at den kan indeholde dynamiske variabler og ændringer i UI.
class _LoginScreenState extends State<LoginScreen> {
  // Opretter en unik nøgle til formularen  ogbruges til kontrol og
  // validering af formularen.
  final _formKey = GlobalKey<FormState>();
  final LoginController _controller = LoginController();
// indeholder det aktuelle brugergrænsefladesprog som er dansk
  String _language = 'DA';

  final Color primaryBlue = const Color(0xFF2F80ED);
  final Color inputFillBlue = const Color(0xFFEAF2FD);

  @override
  void dispose() {
    _controller.dispose();
    // at frigøre alle ressourcer, safecleanup
    super.dispose();
  }

  // en methode for at vise en lille besked nederst på skærmen
  void _showMessage(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  Future<void> _handleLogin(BuildContext context) async {
    // Først kontrolleres det, om formularen er gyldig eller ej.
    // Hvis et af felterne er ugyldigt, stopper metoden, før den fortsætter.
    if (!_formKey.currentState!.validate()) return;
    // Returnerede en fejl hvis login mislykkede
    final error = await _controller.login(context);
    // Viser en fejlmeddelelse og stopper
    if (error != null) {
      _showMessage(error);
      return;
    }

    final userName = _controller.emailController.text.trim();
    // Gemmer formularværdier i AppState-classe,
    // så de er tilgængelige i hele applikationen.
    AppState().setUserData(
      companyId: _controller.companyIdController.text.trim(),
      role: _controller.selectedRole == Role.admin ? 'Admin' : 'Workforce',
    );
    // Afhængigt af den rolle, brugeren har valgt,
    // vil de blive omdirigeret til den relevante side.

    if (_controller.selectedRole == Role.admin) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const AdminDashboard()),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => QuickShiftPage(userName: userName)),
      );
    }
  }

  void _showResetPasswordDialog() {
    // aflæse den mail-værdi, som brugeren har indtastet.
    final resetEmailController = TextEditingController();
    // (popup) på skærmen.
    showDialog(
      // Kontekst er påkrævet for at vise dialogen på den aktuelle side
      context: context,
      // standard Flutter-vinduet med titel, indhold og knapper.
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.resetPasswordTitle),
        // For at indtaste brugerens e-mail
        content: TextField(
          controller: resetEmailController,
          // Åbner det relevante e-mail-tastatur.
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(
              labelText: 'Email', hintText: 'user@company.com'),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              // Hvis e-mailen er tom eller forkert, vises en fejlmeddelelse,
              // og processen fortsætter ikke.
              final email = resetEmailController.text.trim();
              if (email.isEmpty || !email.contains('@')) {
                _showMessage(AppLocalizations.of(context)!.invalidEmail);
                return;
              }
              // Metoden resetPassword kaldes i controlleren.
              // context gives for at accesseres oversættelserne
              final error = await _controller.resetPassword(context, email);
              Navigator.pop(context);
              if (error != null)
                _showMessage(error);
              else
                _showMessage(
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
                // Lytter til isLoading inde i Controlleren
                // Rent og let alternativ til setState
                child: ValueListenableBuilder<bool>(
                  valueListenable: _controller.isLoading,
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
                        const SizedBox(height: 30),
                        // Role Selection
                        Row(
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  Radio<Role>(
                                    value: Role.workforce,
                                    groupValue: _controller.selectedRole,
                                    onChanged: (v) => setState(
                                        () => _controller.selectedRole = v!),
                                  ),
                                  Text(AppLocalizations.of(context)!.workforce),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Row(
                                children: [
                                  Radio<Role>(
                                    value: Role.admin,
                                    groupValue: _controller.selectedRole,
                                    onChanged: (v) => setState(
                                        // Den valgte værdi går direkte ind i rol
                                        () => _controller.selectedRole = v!),
                                  ),
                                  Text(AppLocalizations.of(context)!.admin),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        TextFormField(
                          controller: _controller.companyIdController,
                          decoration: _inputDecoration(
                            AppLocalizations.of(context)!.companyId,
                          ),
                          validator: (v) => v == null || v.trim().isEmpty
                              ? AppLocalizations.of(context)!.companyIdRequired
                              : null,
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
