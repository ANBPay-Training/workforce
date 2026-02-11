import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/branch.dart';

class UserBranchesService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<List<String>> getUserCompanies(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    final data = doc.data()!;
    return List<String>.from(data['companyIds'] ?? []);
  }

  Future<Map<String, String>> getCompanyNames(List<String> companyIds) async {
    final snapshot = await _db
        .collection('companies')
        .where(FieldPath.documentId, whereIn: companyIds)
        .get();

    return {for (var doc in snapshot.docs) doc.id: doc['name'] as String};
  }

  Future<bool> verifyUserCode(String userId, String code) async {
    final doc =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();

    return doc['accessCode'] == code; // ← accessCode from user
  }

  Future<List<Branch>> getUserBranches(String uid) async {
    final companyIds = await getUserCompanies(uid);

    if (companyIds.isEmpty) return [];

    final snapshot = await _db
        .collection('branches')
        .where('companyId', whereIn: companyIds)
        .where('active', isEqualTo: true)
        .get();

    return snapshot.docs.map((doc) {
      return Branch.fromFirestore(doc.id, doc.data());
    }).toList();
  }
}
