import 'package:flutter/material.dart';

class LoginButtonWidget extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onPressed;
  final String text;
  final Color color;
  const LoginButtonWidget({
    super.key,
    required this.isLoading,
    required this.onPressed,
    required this.text,
    required this.color,
  });
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          disabledBackgroundColor: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        onPressed: isLoading ? null : onPressed,
        // Shows the spinner during login.
        child: isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : Text(
                text,
                style: const TextStyle(color: Colors.white),
              ),
      ),
    );
  }
}
