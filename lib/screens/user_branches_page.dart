import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/app_state.dart';
import '../models/employee.dart';
import '../screens/start_Work_Page.dart';

class UserBranchesPage extends StatefulWidget {
  final String userId;

  const UserBranchesPage({super.key, required this.userId});

  @override
  State<UserBranchesPage> createState() => _UserBranchesPageState();
}

class _UserBranchesPageState extends State<UserBranchesPage> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  late Future<List<_BranchItem>> _branchesFuture;

  @override
  void initState() {
    super.initState();
    _branchesFuture = _loadBranches();
  }

  Future<List<_BranchItem>> _loadBranches() async {
    final companyIds = AppState().companyIds ?? [];

    List<_BranchItem> allBranches = [];

    for (final companyId in companyIds) {
      /// get company name
      final companyDoc = await _db.collection('companies').doc(companyId).get();

      final companyName = companyDoc.data()?['name'] ?? '';

      /// get branches of this company
      final branchesSnap = await _db
          .collection('branches')
          .where('companyId', isEqualTo: companyId)
          .get();

      for (final doc in branchesSnap.docs) {
        allBranches.add(
          _BranchItem(
            companyId: companyId,
            companyName: companyName,
            branchId: doc.id,
            branchName: doc['name'] ?? '',
          ),
        );
      }
    }

    return allBranches;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Select Branch")),
      body: FutureBuilder<List<_BranchItem>>(
        future: _branchesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final branches = snapshot.data ?? [];

          if (branches.isEmpty) {
            return const Center(child: Text("No branches available"));
          }

          return ListView.builder(
            itemCount: branches.length,
            itemBuilder: (context, index) {
              final branch = branches[index];

              return ListTile(
                title: Text(branch.branchName),
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => StartWorkPage(
                        employeeId: widget.userId,
                        companyId: branch.companyId,
                        branchId: branch.branchId,
                        companyName: branch.companyName,
                        branchName: branch.branchName,
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

/// Simple internal model for UI
class _BranchItem {
  final String companyId;
  final String companyName;
  final String branchId;
  final String branchName;

  _BranchItem({
    required this.companyId,
    required this.companyName,
    required this.branchId,
    required this.branchName,
  });
}
