import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  // bruges til login, logout, reset password og
  final FirebaseAuth _auth = FirebaseAuth.instance;
  // bruges som database til at gemme og hente brugerdata
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
// En asynkron funktion, der logger en bruger ind og returnerer User eller null.
  Future<User?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return cred.user;
    } on FirebaseAuthException catch (e) {
      // Oversætter Firebase-fejlen til din egen fejl
      throw _mapAuthError(e);
    }
  }

  Future<String?> getUserRole() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    if (!doc.exists) return null;

    return doc.data()?['role'] as String?;
  }

  String _mapAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'errorUserNotFound';
      case 'wrong-password':
        return 'errorWrongPassword';
      case 'invalid-email':
        return 'invalidEmail';
      case 'too-many-requests':
        return 'errorTooManyRequests';
      default:
        return 'errorLoginFailed';
    }
  }

  Future<void> sendPasswordReset(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }
}
