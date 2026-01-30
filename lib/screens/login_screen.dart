import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/app_state.dart';

enum Role { workforce, admin }

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _companyIdController = TextEditingController();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  String _language = 'DA';
  Role _selectedRole = Role.workforce;

  void _showFriendlyError(FirebaseAuthException e) {
    String message;

    switch (e.code) {
      case 'user-not-found':
      case 'wrong-password':
        message = 'Ugyldigt login';
        break;
      case 'invalid-email':
        message = 'Ugyldig email';
        break;
      case 'too-many-requests':
        message = 'For mange forsøg. Prøv senere.';
        break;
      default:
        message = 'Login fejlede. Prøv igen.';
    }

    _showMessage(message);
  }

  void _showMessage(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final companyId = _companyIdController.text.trim();
    final role = _selectedRole == Role.admin ? 'Admin' : 'Workforce';

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      AppState().setUserData(companyId: companyId, role: role);

      // TODO: Navigate to next screen
    } on FirebaseAuthException catch (e) {
      _showFriendlyError(e);
    } catch (_) {
      _showMessage('Noget gik galt. Prøv igen.');
    }
  }

  Future<void> _resetPassword() async {
    await FirebaseAuth.instance.sendPasswordResetEmail(
      email: _emailController.text.trim(),
    );
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Password reset email sent')));
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _companyIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: Center(
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: SizedBox(
              width: 350,
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Sign in to workforce',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Role',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),

                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () {
                              setState(() => _selectedRole = Role.workforce);
                            },
                            child: Row(
                              children: [
                                Radio<Role>(
                                  value: Role.workforce,
                                  groupValue: _selectedRole,
                                  onChanged: (value) {
                                    setState(() => _selectedRole = value!);
                                  },
                                  visualDensity: VisualDensity.compact,
                                ),
                                const Text(
                                  'Workforce',
                                  style: TextStyle(fontSize: 14),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                          child: InkWell(
                            onTap: () {
                              setState(() => _selectedRole = Role.admin);
                            },
                            child: Row(
                              children: [
                                Radio<Role>(
                                  value: Role.admin,
                                  groupValue: _selectedRole,
                                  onChanged: (value) {
                                    setState(() => _selectedRole = value!);
                                  },
                                  visualDensity: VisualDensity.compact,
                                ),
                                const Text(
                                  'Admin',
                                  style: TextStyle(fontSize: 14),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: 'Username (Email)',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Username is required';
                        }
                        if (!value.contains('@')) {
                          return 'Enter a valid email';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 12),

                    TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Password',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Password is required';
                        }
                        return null;
                      },
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: _resetPassword,
                        child: const Text('Forgot Password?'),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _companyIdController,
                      decoration: const InputDecoration(
                        labelText: 'Company ID',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Company ID is required';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 12),

                    DropdownButtonFormField(
                      value: _language,
                      items: const [
                        DropdownMenuItem(value: 'DA', child: Text('Dansk')),
                        DropdownMenuItem(value: 'EN', child: Text('English')),
                      ],
                      onChanged: (value) {
                        setState(() => _language = value!);
                      },
                      decoration: const InputDecoration(
                        labelText: 'Language',
                        border: OutlineInputBorder(),
                      ),
                    ),

                    const SizedBox(height: 20),

                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            _login();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1E88FF),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Sign In',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
