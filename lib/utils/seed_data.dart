import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SeedData {
  static Future<void> seed() async {
    final firestore = FirebaseFirestore.instance;
    final auth = FirebaseAuth.instance;

    final seedDoc = firestore.collection('config').doc('seed_v4');
    if ((await seedDoc.get()).exists) {
      print('Seed already executed');
      return;
    }

    final random = Random();

    /// ======================
    /// 🏢 Companies (named)
    /// ======================
    final companies = [
      {'id': 'company1', 'name': "McDonald's"},
      {'id': 'company2', 'name': 'Dalle Valle'},
      {'id': 'company3', 'name': 'Caffe A'},
    ];

    for (final company in companies) {
      await firestore.collection('companies').doc(company['id'] as String).set({
        'name': company['name'],
        'active': true,
        'userIds': [],
      });
    }

    /// ======================
    /// 🏬 Branch cities
    /// ======================
    final cities = [
      'Copenhagen',
      'Glostrup',
      'Valby',
      'Lyngby',
      'Nørrebro',
      'Østerbro',
      'Amager',
      'Frederiksberg',
    ];

    /// ======================
    /// 🏬 Random branches per company (1–4)
    /// ======================
    for (final company in companies) {
      final companyId = company['id'] as String;

      cities.shuffle();
      int branchCount = random.nextInt(4) + 1;

      for (int i = 0; i < branchCount; i++) {
        final city = cities[i];

        await firestore.collection('branches').add({
          'companyId': companyId,
          'name': city,
          'active': true,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
    }

    /// ======================
    /// 👤 USERS (Auth)
    /// ======================
    final admin1 = await auth.createUserWithEmailAndPassword(
      email: 'admin1@test.com',
      password: '123456',
    );

    final user1 = await auth.createUserWithEmailAndPassword(
      email: 'user1@test.com',
      password: '123456',
    );

    final user2 = await auth.createUserWithEmailAndPassword(
      email: 'user2@test.com',
      password: '123456',
    );

    final user3 = await auth.createUserWithEmailAndPassword(
      email: 'user3@test.com',
      password: '123456',
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

    await firestore.collection('users').doc(user1.user!.uid).set({
      'email': 'user1@test.com',
      'role': 'user',
      'companyIds': ['company1'],
      'active': true,
      'accessCode': "1111",
    });

    await firestore.collection('users').doc(user2.user!.uid).set({
      'email': 'user2@test.com',
      'role': 'user',
      'companyIds': ['company1', 'company2'],
      'active': true,
      'accessCode': "2222",
    });

    await firestore.collection('users').doc(user3.user!.uid).set({
      'email': 'user3@test.com',
      'role': 'user',
      'companyIds': ['company1', 'company2', 'company3'],
      'active': true,
      'accessCode': "3333",
    });

    await seedDoc.set({'done': true});
    print('Seed v4 inserted successfully');
  }
}
