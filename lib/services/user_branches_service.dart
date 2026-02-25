import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/branch.dart';
import '../models/employee.dart';

class UserBranchesService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<List<Branch>> getBranchesByCompany(String companyId) async {
    final snapshot = await _db
        .collection('branches')
        .where('companyId', isEqualTo: companyId)
        .where('active', isEqualTo: true)
        .get();

    return snapshot.docs
        .map((doc) => Branch.fromFirestore(doc.id, doc.data()))
        .toList();
  }

  Future<Employee> getEmployeeById(String employeeId) async {
    final doc = await _db.collection('employees').doc(employeeId).get();

    if (!doc.exists) {
      throw Exception("Employee not found");
    }

    return Employee.fromFirestore(doc.id, doc.data()!);
  }

  Future<List<Employee>> getEmployeesByBranch(
      String companyId, String branchId) async {
    final snapshot = await _db
        .collection('employees')
        .where('companyIds', arrayContains: companyId)
        .where('active', isEqualTo: true)
        .get();

    return snapshot.docs
        .map((doc) => Employee.fromFirestore(doc.id, doc.data()))
        .toList();
  }

  Future<bool> verifyEmployeePin(String employeeId, String pin) async {
    final doc = await _db.collection('employees').doc(employeeId).get();

    return doc.data()?['accessCode'] == pin;
  }
}
