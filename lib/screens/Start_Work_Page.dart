import 'package:flutter/material.dart';
import 'package:workforce/services/user_branches_service.dart';
import '../services/time_entry_service.dart';
import 'package:intl/intl.dart';
import '../utils/baseScaffold.dart';
import '../utils/code_dialog.dart';
import 'dart:async';

class StartWorkPage extends StatefulWidget {
  final String employeeId;
  final String companyId;
  final String branchId;
  final String companyName;
  final String branchName;

  const StartWorkPage({
    super.key,
    required this.employeeId,
    required this.companyId,
    required this.branchId,
    required this.companyName,
    required this.branchName,
  });

  @override
  State<StartWorkPage> createState() => _StartWorkPageState();
}

class _StartWorkPageState extends State<StartWorkPage> {
  final timeEntryService = TimeEntryService();
  final userBranchesService = UserBranchesService();

  String? employeeName;
  DateTime nowTime = DateTime.now();

  DateTime? workStart;
  DateTime? breakStart;

  Timer? _timer;

  bool working = false;
  bool onBreak = false;

  Duration totalBreak = Duration.zero;
  Duration totalWork = Duration.zero;

  @override
  void initState() {
    super.initState();
    _loadTimeEntry();
    _startTimer();
    _loadEmployee();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _loadEmployee() async {
    final employee =
        await userBranchesService.getEmployeeById(widget.employeeId);

    setState(() {
      employeeName = employee.name;
    });
  }

  void _startTimer() {
    _timer?.cancel();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        nowTime = DateTime.now();

        if (working && !onBreak && workStart != null) {
          totalWork = DateTime.now().difference(workStart!) - totalBreak;
        }

        if (onBreak && breakStart != null) {
          totalBreak = DateTime.now().difference(breakStart!);
        }
      });
    });
  }

  Future<void> startWork() async {
    final doc = await userBranchesService.getEmployeeById(widget.employeeId);

    if (doc.isWorking && doc.activeBranchId != widget.branchId) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("You are already working in another branch."),
        ),
      );
      return;
    }
    final ok = await CodeDialog.askForCode(
      context: context,
      employeeId: widget.employeeId,
      userBranchesService: userBranchesService,
      title: "Enter code to Start Work",
    );
    if (!ok) return;

    await timeEntryService.startWork(
      employeeId: widget.employeeId,
      companyId: widget.companyId,
      branchId: widget.branchId,
    );

    setState(() {
      working = true;
      workStart = DateTime.now();
    });
  }

  Future<void> startBreak() async {
    final ok = await CodeDialog.askForCode(
      context: context,
      employeeId: widget.employeeId,
      userBranchesService: userBranchesService,
      title: "Enter code to Start Break",
    );
    if (!ok) return;

    await timeEntryService.startBreak(widget.employeeId);

    setState(() {
      onBreak = true;
      breakStart = DateTime.now();
    });
  }

  Future<void> endBreak() async {
    final ok = await CodeDialog.askForCode(
      context: context,
      employeeId: widget.employeeId,
      userBranchesService: userBranchesService,
      title: "Enter code to End Break",
    );
    if (!ok) return;
    await timeEntryService.endBreak(widget.employeeId);

    final diff = DateTime.now().difference(breakStart!);

    setState(() {
      totalBreak += diff;
      onBreak = false;
      breakStart = null;
    });
  }

  Future<void> endWork() async {
    final ok = await CodeDialog.askForCode(
      context: context,
      employeeId: widget.employeeId,
      userBranchesService: userBranchesService,
      title: "Enter code to End Work",
    );
    if (!ok) return;
    await timeEntryService.endWork(widget.employeeId);

    final diff = DateTime.now().difference(workStart!);

    setState(() {
      totalWork += diff;
      working = false;
      workStart = null;
    });
  }

  String format(Duration d) {
    final hours = d.inHours;
    final minutes = d.inMinutes % 60;
    final seconds = d.inSeconds % 60;

    return "${hours.toString().padLeft(2, '0')}:"
        "${minutes.toString().padLeft(2, '0')}:"
        "${seconds.toString().padLeft(2, '0')}";
  }

  Widget button(String text, VoidCallback onTap, Color color) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        onPressed: onTap,
        child: Text(text),
      ),
    );
  }

  Future<void> _loadTimeEntry() async {
    final entry = await timeEntryService.getTimeEntryForToday(
      widget.employeeId,
      widget.companyId,
      widget.branchId,
    );

    if (entry == null) return;

    final lastSession = entry.sessions.isNotEmpty ? entry.sessions.last : null;

    DateTime? activeBreakStart;
    Duration totalBreakDuration = Duration.zero;

    if (lastSession != null) {
      //  Check if break is active and calculate totalBreak.
      for (final b in lastSession.breaks) {
        if (b.endTime == null) {
          activeBreakStart = b.startTime;
        } else {
          totalBreakDuration += b.endTime!.difference(b.startTime);
        }
      }

      final workDuration = (lastSession.endWork ?? DateTime.now())
              .difference(lastSession.startWork) -
          totalBreakDuration;

      setState(() {
        // If the last session has not yet ended, workStart is active.
        workStart = lastSession.startWork;
        breakStart = activeBreakStart;
        totalBreak = totalBreakDuration;
        totalWork = workDuration;

        // Determine the exact status
        onBreak = activeBreakStart != null; // If the break is active.
        // Is job still in progress
        working = lastSession.endWork == null || onBreak;

        print("endTime: ${lastSession.endWork}");
        print("activeBreakStart: $activeBreakStart");
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      title: widget.branchName,
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 👇 اسم کارمند اینجا اضافه شود
            if (employeeName != null)
              Text(
                employeeName!,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),

            const SizedBox(height: 8),

            Text(
              widget.companyName,
              style: const TextStyle(fontSize: 20),
            ),

            Text(widget.branchName),

            const SizedBox(height: 20),
            if (workStart != null)
              Text(
                "Last start: ${DateFormat('yyyy-MM-dd HH:mm').format(workStart!)}",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            Text("Total break: ${format(totalBreak)}"),
            Text("Total work: ${format(totalWork)}"),
            const SizedBox(height: 30),
            if (!working && !onBreak)
              button("Start Work", startWork, Colors.green)
            else if (working && !onBreak) ...[
              button("Start Break", startBreak, Colors.orange),
              const SizedBox(height: 10),
              button("End Work", endWork, Colors.red),
            ] else if (working && onBreak)
              button("End Break", endBreak, Colors.orange)
            else
              const Text("Status unknown"),
          ],
        ),
      ),
    );
  }
}
