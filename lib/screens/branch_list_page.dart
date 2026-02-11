import 'package:flutter/material.dart';
import '../models/branch.dart';
import '../services/user_branches_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'Start_Work_Page.dart';

class BranchListPage extends StatefulWidget {
  final String userName;

  const BranchListPage({super.key, required this.userName});

  @override
  State<BranchListPage> createState() => _BranchListPageState();
}

class _BranchListPageState extends State<BranchListPage> {
  final UserBranchesService service = UserBranchesService();

  List<Branch> branches = [];
  Map<String, String> companyNames = {};
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadBranches();
  }

  Future<void> loadBranches() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    final companyIds = await service.getUserCompanies(uid);
    final branchList = await service.getUserBranches(uid);
    final companyMap = await service.getCompanyNames(companyIds);

    setState(() {
      branches = branchList;
      companyNames = companyMap;
      loading = false;
    });
  }

  void _onBranchSelected(BuildContext context, Branch branch) async {
    final ok = await _askForUserCode(context);

    if (ok == true) {
      final uid = FirebaseAuth.instance.currentUser!.uid;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => StartWorkPage(
            userId: uid,
            companyId: branch.companyId,
            branchId: branch.id,
            branchName: branch.name,
            companyName: companyNames[branch.companyId] ?? '',
          ),
        ),
      );
    }
  }

  Future<bool?> _askForUserCode(BuildContext context) {
    final controller = TextEditingController();
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Enter your code"),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: "Code"),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                final isValid = await service.verifyUserCode(
                  uid,
                  controller.text.trim(),
                );

                if (isValid) {
                  Navigator.pop(context, true);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Wrong code")),
                  );
                }
              },
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Select Branch"),
        centerTitle: true,
      ),
      backgroundColor: Colors.grey.shade100,
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Welcome ${widget.userName}",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView.builder(
                      itemCount: branches.length,
                      itemBuilder: (context, index) {
                        final branch = branches[index];

                        return Card(
                          elevation: 3,
                          margin: const EdgeInsets.only(bottom: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: ListTile(
                              contentPadding: const EdgeInsets.all(16),
                              subtitle: Text(
                                companyNames[branch.companyId] ?? '',
                              ),
                              leading: const Icon(
                                Icons.business,
                                color: Colors.indigo,
                              ),
                              title: Text(
                                branch.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              trailing: const Icon(Icons.arrow_forward_ios),
                              onTap: () {
                                final uid =
                                    FirebaseAuth.instance.currentUser!.uid;

                                _onBranchSelected(context, branch);
                              }),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
