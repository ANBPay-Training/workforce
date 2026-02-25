import 'package:flutter/material.dart';
import '../models/branch.dart';
import '../services/user_branches_service.dart';
import '../services/time_entry_service.dart';
import '../utils/logout_helper.dart';
import 'employee_list_page.dart';

class BranchListPage extends StatefulWidget {
  final String companyId;
  final String companyName;

  const BranchListPage({
    super.key,
    required this.companyId,
    required this.companyName,
  });

  @override
  State<BranchListPage> createState() => _BranchListPageState();
}

class _BranchListPageState extends State<BranchListPage> {
  final UserBranchesService service = UserBranchesService();
  final TimeEntryService timeService = TimeEntryService();

  List<Branch> branches = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadBranches();
  }

  Future<void> loadBranches() async {
    final list = await service.getBranchesByCompany(widget.companyId);

    /// 🔎 Checking if an employee is working in a branch

    setState(() {
      branches = list;
      loading = false;
    });
  }

  void _onBranchSelected(Branch branch) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EmployeeListPage(
          companyId: widget.companyId,
          companyName: widget.companyName,
          branchId: branch.id,
          branchName: branch.name,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.companyName),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => LogoutHelper.logout(context),
          ),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: branches.length,
              itemBuilder: (context, index) {
                final branch = branches[index];

                return ListTile(
                  title: Text(branch.name),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () => _onBranchSelected(branch),
                );
              },
            ),
    );
  }
}
