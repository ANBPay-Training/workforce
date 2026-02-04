import 'package:flutter/material.dart';

class PasswordFieldWidget extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? Function(String?) validator;

  const PasswordFieldWidget(
      {super.key,
      required this.controller,
      required this.label,
      required this.validator});
  @override
  Widget build(BuildContext context) {
    return TextFormField(
        controller: controller,
        // Holder adgangskoden hemmelig.
        obscureText: true,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        validator: validator);
  }
}
