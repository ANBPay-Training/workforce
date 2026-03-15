import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';
import '../../../utils/input_decoration.dart';

class EmailFieldWidget extends StatelessWidget {
  final TextEditingController controller;

  const EmailFieldWidget({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: InputDecorations.authField(
        label: AppLocalizations.of(context)!.username,
      ),
      validator: (v) => v == null || v.trim().isEmpty
          ? AppLocalizations.of(context)!.emailRequired
          : null,
    );
  }
}
