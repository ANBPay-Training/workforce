import 'package:flutter/material.dart';
import '../services/user_branches_service.dart';

class CodeDialog {
  static Future<bool> askForCode({
    required BuildContext context,
    required String userId,
    required UserBranchesService userBranchesService,
    String title = "Enter your 4-digit code",
  }) async {
    final controller = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          maxLength: 4,
          obscureText: true, // Hide the code using asterisks.
          decoration: const InputDecoration(
            labelText: "Code",
            counterText: "",
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              final code = controller.text.trim();
              if (code.length != 4) return;

              final valid =
                  await userBranchesService.verifyUserCode(userId, code);
              if (valid) {
                Navigator.pop(context, true);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Wrong code")),
                );
              }
            },
            child: const Text("OK"),
          ),
        ],
      ),
    );

    return result ?? false;
  }
}
