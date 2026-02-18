import 'package:flutter/material.dart';
import 'package:workforce/services/user_branches_service.dart';
import '../services/time_entry_service.dart';
import 'package:intl/intl.dart';
import '../utils/code_dialog.dart';

class StartWorkPage extends StatefulWidget {
  final String userId;
  final String companyId;
  final String branchId;
  final String companyName;
  final String branchName;

  const StartWorkPage({
    super.key,
    required this.userId,
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

  DateTime? workStart;
  DateTime? breakStart;

  bool working = false;
  bool onBreak = false;

  Duration totalBreak = Duration.zero;
  Duration totalWork = Duration.zero;

  @override
  void initState() {
    super.initState();
    _loadTimeEntry();
  }

  Future<void> startWork() async {
    final ok = await CodeDialog.askForCode(
      context: context,
      userId: widget.userId,
      userBranchesService: userBranchesService,
      title: "Enter code to Start Work",
    );
    if (!ok) return;

    await timeEntryService.startWork(
      userId: widget.userId,
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
      userId: widget.userId,
      userBranchesService: userBranchesService,
      title: "Enter code to Start Break",
    );
    if (!ok) return;

    await timeEntryService.startBreak(widget.userId);

    setState(() {
      onBreak = true;
      breakStart = DateTime.now();
    });
  }

  Future<void> endBreak() async {
    final ok = await CodeDialog.askForCode(
      context: context,
      userId: widget.userId,
      userBranchesService: userBranchesService,
      title: "Enter code to End Break",
    );
    if (!ok) return;
    await timeEntryService.endBreak(widget.userId);

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
      userId: widget.userId,
      userBranchesService: userBranchesService,
      title: "Enter code to End Work",
    );
    if (!ok) return;
    await timeEntryService.endWork(widget.userId);

    final diff = DateTime.now().difference(workStart!);

    setState(() {
      totalWork += diff;
      working = false;
      workStart = null;
    });
  }

  String format(Duration d) {
    return "${d.inHours}:${(d.inMinutes % 60).toString().padLeft(2, '0')}";
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
      widget.userId,
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

      final workDuration = (lastSession.endTime ?? DateTime.now())
              .difference(lastSession.startTime) -
          totalBreakDuration;

      setState(() {
        // If the last session has not yet ended, workStart is active.
        workStart = lastSession.startTime;
        breakStart = activeBreakStart;
        totalBreak = totalBreakDuration;
        totalWork = workDuration;

        // Determine the exact status
        onBreak = activeBreakStart != null; // If the break is active.
        // Is job still in progress
        working = lastSession.endTime == null || onBreak;

        print("endTime: ${lastSession.endTime}");
        print("activeBreakStart: $activeBreakStart");
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Work Session")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(widget.companyName, style: const TextStyle(fontSize: 20)),
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
