import 'package:flutter/material.dart';

import '../../../controllers/login_controller.dart';
import '../../../l10n/app_localizations.dart';

class ResetPasswordDialog {
  static Future<void> show(
    BuildContext context,
    LoginController controller,
  ) async {
    // Read the email address entered by the user.
    final emailController = TextEditingController();
    // Display a popup on the screen.
    showDialog(
      // BuildContext is required to display the dialog on the current screen.
      context: context,
      // Uses Flutter’s standard dialog with a title, content, and action buttons.
      builder: (_) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.resetPasswordTitle),
          // Text field for entering the user's email address.
          content: TextField(
            controller: emailController,
            // Opens the appropriate email keyboard.
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: 'Email',
              hintText: 'user@company.com',
            ),
          ),

          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                // If the email is empty or invalid, an error message is displayed
                // and the process does not continue.
                final email = emailController.text.trim();
// Calls the resetPassword method in the controller.
                final result = await controller.resetPassword(context, email);

                Navigator.pop(context);
// Provides context to access translations
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(result ?? 'Done')),
                );
              },
              child: const Text('Send'),
            )
          ],
        );
      },
    );
  }
}
