import 'package:flutter/material.dart';
import '../models/employee.dart';
import '../services/time_entry_service.dart';
import '../services/user_branches_service.dart';
import '../utils/baseScaffold.dart';
import 'Start_Work_Page.dart';

class EmployeeListPage extends StatefulWidget {
  final String companyId;
  final String branchId;
  final String branchName;
  final String companyName;

  const EmployeeListPage({
    super.key,
    required this.companyId,
    required this.branchId,
    required this.branchName,
    required this.companyName,
  });

  @override
  State<EmployeeListPage> createState() => _EmployeeListPageState();
}

class _EmployeeListPageState extends State<EmployeeListPage> {
  final service = UserBranchesService();
  final timeService = TimeEntryService();

  List<Employee> employees = [];
  Map<String, String> employeeStatuses = {};
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadEmployees();
  }

  Future<void> loadEmployees() async {
    final list =
        await service.getEmployeesByBranch(widget.companyId, widget.branchId);

    Map<String, String> statuses = {};

    for (final e in list) {
      final status = await timeService.getEmployeeStatusToday(
        e.id,
        widget.companyId,
        widget.branchId,
      );
      statuses[e.id] = status;
    }

    setState(() {
      employees = list;
      employeeStatuses = statuses;
      loading = false;
    });
  }

  Color _statusColor(String status) {
    switch (status) {
      case "working":
        return Colors.green;
      case "break":
        return Colors.orange;
      case "completed":
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void _onEmployeeSelected(Employee employee) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => StartWorkPage(
          employeeId: employee.id,
          companyId: widget.companyId,
          branchId: widget.branchId,
          branchName: widget.branchName,
          companyName: widget.companyName,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      title: widget.branchName,
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: employees.length,
              itemBuilder: (_, index) {
                final e = employees[index];
                final status = employeeStatuses[e.id] ?? "idle";

                final isWorkingElsewhere =
                    e.isWorking && e.activeBranchId != widget.branchId;

                return Opacity(
                  opacity: isWorkingElsewhere ? 0.4 : 1,
                  child: ListTile(
                    leading: CircleAvatar(
                      radius: 8,
                      backgroundColor: _statusColor(status),
                    ),
                    title: Text(e.name),
                    onTap: () {
                      if (isWorkingElsewhere) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              "${e.name} is working in another branch.",
                            ),
                          ),
                        );
                        return;
                      }

                      _onEmployeeSelected(e);
                    },
                  ),
                );
              },
            ),
    );
  }
}
