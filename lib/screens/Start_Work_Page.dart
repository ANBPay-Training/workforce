import 'package:flutter/material.dart';
import '../services/time_entry_service.dart';

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
  final service = TimeEntryService();

  DateTime? workStart;
  DateTime? breakStart;

  bool working = false;
  bool onBreak = false;

  Duration totalBreak = Duration.zero;
  Duration totalWork = Duration.zero;

  Future<void> startWork() async {
    await service.startWork(
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
    await service.startBreak(widget.userId);

    setState(() {
      onBreak = true;
      breakStart = DateTime.now();
    });
  }

  Future<void> endBreak() async {
    await service.endBreak(widget.userId);

    final diff = DateTime.now().difference(breakStart!);

    setState(() {
      totalBreak += diff;
      onBreak = false;
      breakStart = null;
    });
  }

  Future<void> endWork() async {
    await service.endWork(widget.userId);

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

  @override
  void initState() {
    super.initState();
    _loadTimeEntry();
  }

  Future<void> _loadTimeEntry() async {
    final entry = await service.getTimeEntryForToday(
      widget.userId,
      widget.companyId,
      widget.branchId,
    );

    if (entry == null) return;

    final lastSession = entry.sessions.isNotEmpty ? entry.sessions.last : null;

    setState(() {
      working = entry.status == "running";
      onBreak = lastSession != null &&
          lastSession.breaks.any((b) => b.endTime == null);
      workStart = lastSession?.startTime;
      totalWork = Duration(minutes: entry.totalWorkMinutes);
      totalBreak = Duration(
        minutes: lastSession?.breaks.fold(0, (sum, b) => sum! + b.minutes) ?? 0,
      );
    });
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
            if (workStart != null) Text("Last start: $workStart"),
            Text("Total break: ${format(totalBreak)}"),
            Text("Total work: ${format(totalWork)}"),
            const SizedBox(height: 30),
            if (!working) button("Start Work", startWork, Colors.green),
            if (working && !onBreak) ...[
              button("Start Break", startBreak, Colors.orange),
              const SizedBox(height: 10),
              button("End Work", endWork, Colors.red),
            ],
            if (onBreak) button("End Break", endBreak, Colors.orange),
          ],
        ),
      ),
    );
  }
}
