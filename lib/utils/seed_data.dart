import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SeedData {
  // Future<void> → async because it works with Firebase
  // static : You can call it without creating an object.

  static Future<void> seed() async {
    // Auth just says “who are you”
    // Firestore says “what are you and what do you do”
    final firestore = FirebaseFirestore.instance;
    final auth = FirebaseAuth.instance;

    ///  Prevent multiple executions
    final seedDoc = firestore.collection('config').doc('seed_v3');
    if ((await seedDoc.get()).exists) {
      print('Seed already executed');
      return;
    }

    /// ======================
    /// 🏢 Companies (5)
    /// ======================
    for (int i = 1; i <= 5; i++) {
      await firestore.collection('companies').doc('company$i').set({
        'name': 'Company $i',
        'active': true,
        'userIds': [],
      });
    }

    /// ======================
    /// 🏬 Branches (2 per company)
    /// ======================
    for (int i = 1; i <= 5; i++) {
      for (int b = 1; b <= 2; b++) {
        await firestore.collection('branches').doc('company${i}_branch$b').set({
          'companyId': 'company$i',
          'name': 'Branch $b - Company $i',
          'active': true,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
    }

    /// ======================
    /// 👤 USERS (Auth)
    /// ======================

    // ADMIN 1
    final admin1 = await auth.createUserWithEmailAndPassword(
      email: 'admin1@test.com',
      password: '123456',
    );

    // ADMIN 2
    final admin2 = await auth.createUserWithEmailAndPassword(
      email: 'admin2@test.com',
      password: '234567',
    );

    // USER 1 → 1 company
    final user1 = await auth.createUserWithEmailAndPassword(
      email: 'user1@test.com',
      password: '123456',
    );

    // USER 2 → 2 companies
    final user2 = await auth.createUserWithEmailAndPassword(
      email: 'user2@test.com',
      password: '234567',
    );

    // USER 3 → 3 companies
    final user3 = await auth.createUserWithEmailAndPassword(
      email: 'user3@test.com',
      password: '345678',
    );

    /// ======================
    /// 🗂 USERS (Firestore)
    /// ======================

    await firestore.collection('users').doc(admin1.user!.uid).set({
      'email': 'admin1@test.com',
      'role': 'admin',
      'companyIds': [],
      'active': true,
    });

    await firestore.collection('users').doc(admin2.user!.uid).set({
      'email': 'admin2@test.com',
      'role': 'admin',
      'companyIds': [],
      'active': true,
    });

    await firestore.collection('users').doc(user1.user!.uid).set({
      'email': 'user1@test.com',
      'role': 'user',
      'companyIds': ['company1'],
      'active': true,
    });

    await firestore.collection('users').doc(user2.user!.uid).set({
      'email': 'user2@test.com',
      'role': 'user',
      'companyIds': ['company1', 'company2'],
      'active': true,
    });

    await firestore.collection('users').doc(user3.user!.uid).set({
      'email': 'user3@test.com',
      'role': 'user',
      'companyIds': ['company1', 'company2', 'company3'],
      'active': true,
    });
    await seedDoc.set({'done': true});
    print('Seed v3 inserted successfully');
  }
}
