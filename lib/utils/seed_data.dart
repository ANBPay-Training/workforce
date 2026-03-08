import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SeedData {
  static Future<void> seed() async {
    final firestore = FirebaseFirestore.instance;
    final auth = FirebaseAuth.instance;

    final seedDoc = firestore.collection('config').doc('seed_v9');

    if ((await seedDoc.get()).exists) {
      print('Seed already executed');
      return;
    }

    /// ======================
    /// ADMIN
    /// ======================
    final adminAuth = await auth.createUserWithEmailAndPassword(
      email: 'admin@test.com',
      password: '123456',
    );

    await firestore.collection('companies').doc(adminAuth.user!.uid).set({
      'name': 'System Admin',
      'email': 'admin@test.com',
      'role': 'admin',
      'active': true,
    });

    /// ======================
    /// COMPANY 1
    /// ======================
    final company1Auth = await auth.createUserWithEmailAndPassword(
      email: 'company1@test.com',
      password: '123456',
    );

    await firestore.collection('companies').doc(company1Auth.user!.uid).set({
      'name': 'Company 1',
      'email': 'company1@test.com',
      'role': 'company',
      'active': true,
    });

    await firestore.collection('branches').add({
      'companyId': company1Auth.user!.uid,
      'name': 'Branch A',
      'active': true,
    });

    await firestore.collection('branches').add({
      'companyId': company1Auth.user!.uid,
      'name': 'Branch B',
      'active': true,
    });

    /// ======================
    /// COMPANY 2
    /// ======================
    final company2Auth = await auth.createUserWithEmailAndPassword(
      email: 'company2@test.com',
      password: '123456',
    );

    await firestore.collection('companies').doc(company2Auth.user!.uid).set({
      'name': 'Company 2',
      'email': 'company2@test.com',
      'role': 'company',
      'active': true,
    });

    await firestore.collection('branches').add({
      'companyId': company2Auth.user!.uid,
      'name': 'Branch C',
      'active': true,
    });

    await firestore.collection('branches').add({
      'companyId': company2Auth.user!.uid,
      'name': 'Branch D',
      'active': true,
    });

    await firestore.collection('branches').add({
      'companyId': company2Auth.user!.uid,
      'name': 'Branch E',
      'active': true,
    });

    /// ======================
    /// COMPANY 3
    /// ======================
    final company3Auth = await auth.createUserWithEmailAndPassword(
      email: 'company3@test.com',
      password: '123456',
    );

    await firestore.collection('companies').doc(company3Auth.user!.uid).set({
      'name': 'Company 3',
      'email': 'company3@test.com',
      'role': 'company',
      'active': true,
    });

    await firestore.collection('branches').add({
      'companyId': company3Auth.user!.uid,
      'name': 'Branch F',
      'active': true,
    });

    /// ======================
    /// EMPLOYEE 1
    /// ======================
    final emp1Auth = await auth.createUserWithEmailAndPassword(
      email: 'emp1@test.com',
      password: '123456',
    );

    await firestore.collection('employees').doc(emp1Auth.user!.uid).set({
      'name': 'Employee 1',
      'email': 'emp1@test.com',
      'role': 'employee',
      'accessCode': '1111',
      'active': true,
      'companyIds': [company1Auth.user!.uid],
      'isWorking': false,
      'activeCompanyId': null,
      'activeBranchId': null,
    });

    /// ======================
    /// EMPLOYEE 2
    /// ======================
    final emp2Auth = await auth.createUserWithEmailAndPassword(
      email: 'emp2@test.com',
      password: '123456',
    );

    await firestore.collection('employees').doc(emp2Auth.user!.uid).set({
      'name': 'Employee 2',
      'email': 'emp2@test.com',
      'role': 'employee',
      'accessCode': '2222',
      'active': true,
      'companyIds': [company2Auth.user!.uid],
      'isWorking': false,
      'activeCompanyId': null,
      'activeBranchId': null,
    });

    /// ======================
    /// EMPLOYEE 3 (MULTI COMPANY)
    /// ======================
    final emp3Auth = await auth.createUserWithEmailAndPassword(
      email: 'emp3@test.com',
      password: '123456',
    );

    await firestore.collection('employees').doc(emp3Auth.user!.uid).set({
      'name': 'Employee 3',
      'email': 'emp3@test.com',
      'role': 'employee',
      'accessCode': '3333',
      'active': true,
      'companyIds': [
        company1Auth.user!.uid,
        company2Auth.user!.uid,
      ],
      'isWorking': false,
      'activeCompanyId': null,
      'activeBranchId': null,
    });

    /// ======================
    /// EMPLOYEE 4
    /// ======================
    final emp4Auth = await auth.createUserWithEmailAndPassword(
      email: 'emp4@test.com',
      password: '123456',
    );

    await firestore.collection('employees').doc(emp4Auth.user!.uid).set({
      'name': 'Employee 4',
      'email': 'emp4@test.com',
      'role': 'employee',
      'accessCode': '4444',
      'active': true,
      'companyIds': [company3Auth.user!.uid],
      'isWorking': false,
      'activeCompanyId': null,
      'activeBranchId': null,
    });

    /// ======================
    /// SEED FLAG
    /// ======================
    await seedDoc.set({'done': true});

    print('Seed v9 inserted successfully');
  }
}
