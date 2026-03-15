import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';
import '../../../main.dart';

class LanguageDropdownWidget extends StatelessWidget {
  final String language;
  final Function(String) onChanged;

  const LanguageDropdownWidget({
    super.key,
    required this.language,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: language,
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

        onChanged(value);

        MyApp.of(context).setLocale(
          value == 'DA' ? const Locale('da') : const Locale('en'),
        );
      },
    );
  }
}
