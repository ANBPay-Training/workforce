import 'package:flutter/material.dart';

class InputDecorations {
  static const Color _fillColor = Color(0xFFEAF2FD);
  static const Color _focusColor = Color(0xFF2F80ED);
  static InputDecoration authField({
    required String label,
  }) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: _fillColor,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(
          color: _focusColor,
          width: 2,
        ),
      ),
    );
  }
}
