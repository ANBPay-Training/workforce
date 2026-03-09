import 'package:flutter/material.dart';

class InputDecorations {
  static InputDecoration authField({
    required String label,
    required Color fillColor,
    required Color focusColor,
  }) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: fillColor,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(
          color: focusColor,
          width: 2,
        ),
      ),
    );
  }
}
