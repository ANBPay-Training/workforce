import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SeedData {
  static Future<void> seed() async {
    final firestore = FirebaseFirestore.instance;
    final auth = FirebaseAuth.instance;

    ///  Prevent multiple executions
    final seedDoc = firestore.collection('config').doc('seed');
    final seedSnap = await seedDoc.get();

    if (seedSnap.exists) {
      print('Seed already executed');
      return;
    }

    /// ======================
    /// 🏢 Companies
    /// ======================
    await firestore.collection('companies').doc('company1').set({
      'name': 'Alpha Company',
      'active': true,
    });

    await firestore.collection('companies').doc('company2').set({
      'name': 'Beta Company',
      'active': true,
    });

    /// ======================
    /// 👤 Users (Auth + Firestore)
    /// ======================

    // Admin
    final admin = await auth.createUserWithEmailAndPassword(
      email: 'admin@alpha.com',
      password: 'Admin123!',
    );

    await firestore.collection('users').doc(admin.user!.uid).set({
      'email': 'admin@alpha.com',
      'role': 'admin',
      'companyId': 'company1',
      'active': true,
    });

    // Workforce user 1
    final user1 = await auth.createUserWithEmailAndPassword(
      email: 'user1@alpha.com',
      password: 'User123!',
    );

    await firestore.collection('users').doc(user1.user!.uid).set({
      'email': 'user1@alpha.com',
      'role': 'workforce',
      'companyId': 'company1',
      'active': true,
    });

    // Workforce user 2
    final user2 = await auth.createUserWithEmailAndPassword(
      email: 'user2@beta.com',
      password: 'User123!',
    );

    await firestore.collection('users').doc(user2.user!.uid).set({
      'email': 'user2@beta.com',
      'role': 'workforce',
      'companyId': 'company2',
      'active': true,
    });

    /// Register that the seed has been done
    await seedDoc.set({'done': true});

    print('Seed data inserted successfully');
  }
}
