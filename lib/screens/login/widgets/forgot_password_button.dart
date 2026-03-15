import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';

class ForgotPasswordButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Color color;

  const ForgotPasswordButton({
    super.key,
    required this.onPressed,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: onPressed,
        child: Text(
          AppLocalizations.of(context)!.forgotPassword,
          style: TextStyle(color: color),
        ),
      ),
    );
  }
}
