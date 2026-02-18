import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/breakSession.dart';
import '../models/timeEntry.dart';
import '../models/workSession.dart';

class TimeEntryService {
  final _db = FirebaseFirestore.instance;

  String _today() {
    final now = DateTime.now();
    return "${now.year}-${now.month}-${now.day}";
  }

  Future<void> startWork({
    required String userId,
    required String companyId,
    required String branchId,
  }) async {
    final workDate = _today();

    final docRef = _db.collection('timeEntries').doc("${userId}_$workDate");

    final doc = await docRef.get();

    if (doc.exists) {
      final entry = TimeEntry.fromFirestore(
        doc.id,
        doc.data() as Map<String, dynamic>,
      );

      final sessions = List<WorkSession>.from(entry.sessions);

      // If the last session has expired, create a new session.
      if (sessions.isNotEmpty && sessions.last.endTime != null) {
        sessions.add(
          WorkSession(
            startTime: DateTime.now(),
            breaks: [],
            totalWorkMinutes: 0,
          ),
        );

        await docRef.update({
          "sessions": sessions.map((e) => e.toMap()).toList(),
          "status": "running",
        });
      }

      return;
    }

    final session = WorkSession(
      startTime: DateTime.now(),
      breaks: [],
      totalWorkMinutes: 0,
    );

    final entry = TimeEntry(
      id: docRef.id,
      userId: userId,
      companyId: companyId,
      branchId: branchId,
      workDate: workDate,
      sessions: [session],
      totalWorkMinutes: 0,
      status: "running",
    );

    await docRef.set(entry.toFirestore());
  }

  Future<DocumentReference> _doc(String userId) {
    final workDate = _today();
    return Future.value(
      _db.collection('timeEntries').doc("${userId}_$workDate"),
    );
  }

  Future<void> startBreak(String userId) async {
    final docRef = await _doc(userId);
    final snap = await docRef.get();
    if (!snap.exists) return;

    final entry = TimeEntry.fromFirestore(
      snap.id,
      snap.data() as Map<String, dynamic>,
    );

    final sessions = List<WorkSession>.from(entry.sessions);
    final lastSession = sessions.last;

    lastSession.breaks.add(
      BreakSession(
        startTime: DateTime.now(),
        minutes: 0,
      ),
    );

    await docRef.update({
      "sessions": sessions.map((e) => e.toMap()).toList(),
    });
  }

  Future<void> endBreak(String userId) async {
    final docRef = await _doc(userId);
    final snap = await docRef.get();
    if (!snap.exists) return;

    final entry = TimeEntry.fromFirestore(
      snap.id,
      snap.data() as Map<String, dynamic>,
    );

    final sessions = List<WorkSession>.from(entry.sessions);
    final lastSession = sessions.last;

    final breaks = List<BreakSession>.from(lastSession.breaks);
    final lastBreak = breaks.last;

    breaks[breaks.length - 1] = BreakSession(
      startTime: lastBreak.startTime,
      endTime: DateTime.now(),
      minutes: lastBreak.minutes,
    );

    sessions[sessions.length - 1] = WorkSession(
      startTime: lastSession.startTime,
      endTime: lastSession.endTime,
      breaks: breaks,
      totalWorkMinutes: lastSession.totalWorkMinutes,
    );

    await docRef.update({
      "sessions": sessions.map((e) => e.toMap()).toList(),
    });
  }

  Future<void> endWork(String userId) async {
    final docRef = await _doc(userId);
    final snap = await docRef.get();
    if (!snap.exists) return;

    final entry = TimeEntry.fromFirestore(
      snap.id,
      snap.data() as Map<String, dynamic>,
    );

    final sessions = List<WorkSession>.from(entry.sessions);
    final lastSession = sessions.last;

    sessions[sessions.length - 1] = WorkSession(
      startTime: lastSession.startTime,
      endTime: DateTime.now(),
      breaks: lastSession.breaks,
      totalWorkMinutes: lastSession.totalWorkMinutes,
    );

    await docRef.update({
      "status": "completed",
      "sessions": sessions.map((e) => e.toMap()).toList(),
    });
  }

  Future<TimeEntry?> getTimeEntryForToday(
      String userId, String companyId, String branchId) async {
    final today =
        "${DateTime.now().year}-${DateTime.now().month}-${DateTime.now().day}";
    final docRef = _db.collection('timeEntries').doc("${userId}_$today");
    final doc = await docRef.get();

    if (!doc.exists) return null;

    final entry = TimeEntry.fromFirestore(doc.id, doc.data()!);

    // Only the current branch and company
    if (entry.branchId != branchId || entry.companyId != companyId) return null;

    return entry;
  }
}
