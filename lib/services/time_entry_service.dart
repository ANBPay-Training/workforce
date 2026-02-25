import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/breakSession.dart';
import '../models/timeEntry.dart';
import '../models/workSession.dart';

class TimeEntryService {
  final _db = FirebaseFirestore.instance;
// Helper to get today's date.
  String _today() {
    final now = DateTime.now();
    return "${now.year}-${now.month}-${now.day}";
  }

  Future<void> startWork({
    required String employeeId,
    required String companyId,
    required String branchId,
  }) async {
    final workDate = _today();
    // Each document is named in the format: userId_YYYY-M-D
    // Find today's document.
    final doc_TimeEntries =
        _db.collection('timeEntries').doc("${employeeId}_$workDate");

    final doc = await doc_TimeEntries.get();
    // if doc.exists, it means user has already started today.
    if (doc.exists) {
      final entry = TimeEntry.fromFirestore(
        doc.id,
        doc.data() as Map<String, dynamic>,
      );

      final sessions = List<WorkSession>.from(entry.sessions);

      // If the last session is not finished (endTime is not null):
      if (sessions.isNotEmpty && sessions.last.endWork == null) {
        return; // already running
      }

      sessions.add(
        WorkSession(
          startWork: DateTime.now(),
          breaks: [],
          totalWorkMinutes: 0,
        ),
      );
      // ✔ Set status to running
      // This allows multiple start/end cycles in a single day.
      await doc_TimeEntries.update({
        "sessions": sessions.map((e) => e.toMap()).toList(),
        "status": "running",
      });

      return;
    }
    // if doc.exists not exists, it means the user just start work today.
    final session = WorkSession(
      startWork: DateTime.now(),
      breaks: [],
      totalWorkMinutes: 0,
    );
// create a new TimeEntry
    final entry = TimeEntry(
      id: doc_TimeEntries.id,
      employeeId: employeeId,
      companyId: companyId,
      branchId: branchId,
      workDate: workDate,
      sessions: [session],
      totalWorkMinutes: 0,
      status: "running",
    );
// add new TimeEntry to firebase
    await doc_TimeEntries.set(entry.toFirestore());
    await _db.collection('employees').doc(employeeId).update({
      'isWorking': true,
      'activeCompanyId': companyId,
      'activeBranchId': branchId,
    });
  }

// Just a helper that returns the user's document for today.
  Future<DocumentReference> _doc(String userId) {
    final workDate = _today();
    return Future.value(
      _db.collection('timeEntries').doc("${userId}_$workDate"),
    );
  }

  Future<Map<String, dynamic>?> getActiveBranchForEmployee(
      String employeeId) async {
    final today = _today();

    final snapshot = await _db
        .collection('timeEntries')
        .where('employeeId', isEqualTo: employeeId)
        .where('workDate', isEqualTo: today)
        .where('status', isEqualTo: 'running')
        .get();

    if (snapshot.docs.isEmpty) return null;

    final doc = snapshot.docs.first;

    return {
      'companyId': doc['companyId'],
      'branchId': doc['branchId'],
    };
  }

  // 1. Get today's document
  // 2. Find the last session
  // 3. Add a new Break to the breaks list
  Future<void> startBreak(String userId) async {
    final docRef = await _doc(userId);
    final snap = await docRef.get();
    if (!snap.exists) return;

    final entry = TimeEntry.fromFirestore(
      snap.id,
      snap.data() as Map<String, dynamic>,
    );
    // Create a new list from entry.sessions
    final sessions = List<WorkSession>.from(entry.sessions);
    if (sessions.isEmpty) return;
    final lastSession = sessions.last;

    // for extra safety,
    // to prevent adding a break if the session is already closed.
    if (lastSession.endWork != null) return;
    // Prevent adding a new break if the previous break is still active.
    if (lastSession.breaks.isNotEmpty &&
        lastSession.breaks.last.endTime == null) return;
    // if any doc exists, add a new break session
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
    // - Get the document
    final docRef = await _doc(userId);
    final snap = await docRef.get();
    if (!snap.exists) return;

    final entry = TimeEntry.fromFirestore(
      snap.id,
      snap.data() as Map<String, dynamic>,
    );
    // - Find the last break
    final sessions = List<WorkSession>.from(entry.sessions);
    if (sessions.isEmpty) return;
    final lastSession = sessions.last;

    // End  if an active break exists.
    if (lastSession.breaks.isEmpty || lastSession.breaks.last.endTime != null)
      return;

    final lastBreak = lastSession.breaks.last;

    lastSession.breaks[lastSession.breaks.length - 1] = BreakSession(
      startTime: lastBreak.startTime,
      endTime: DateTime.now(),
      // Calculate the exact minutes.
      minutes: DateTime.now().difference(lastBreak.startTime).inMinutes,
    );

    sessions[sessions.length - 1] = WorkSession(
      startWork: lastSession.startWork,
      endWork: lastSession.endWork,
      breaks: lastSession.breaks,
      totalWorkMinutes: lastSession.totalWorkMinutes,
    );
    // After adding the new break, rebuild the sessions list as a Map
    // and update the entire "sessions" field in Firestore.
    await docRef.update({
      "sessions": sessions.map((e) => e.toMap()).toList(),
    });
  }

  Future<void> endWork(String userId) async {
    final docRef = await _doc(userId);
    final snap = await docRef.get();
    // If the document does not exist, return .
    // the end-work button do not allow ending work without an active session.
    if (!snap.exists) return;

    final entry = TimeEntry.fromFirestore(
      snap.id,
      snap.data() as Map<String, dynamic>,
    );
    // Map Firestore document data to a TimeEntry object.
    final sessions = List<WorkSession>.from(entry.sessions);
    if (sessions.isEmpty) return;
    final lastSession = sessions.last;

    // Only if the session is still active.
    if (lastSession.endWork != null) return;

    // Calculate the actual working minutes by subtracting break time.
    int breakMinutes = lastSession.breaks.fold(0, (sum, b) {
      if (b.endTime != null) {
        return sum + b.endTime!.difference(b.startTime).inMinutes;
      } else {
        //Active break: time difference so far.
        return sum + DateTime.now().difference(b.startTime).inMinutes;
      }
    });

    int totalMinutes =
        DateTime.now().difference(lastSession.startWork).inMinutes -
            breakMinutes;

    // Instead of modifying lastSession.endWork directly,
    // a new WorkSession instance is created and replaces the old one.
    sessions[sessions.length - 1] = WorkSession(
      startWork: lastSession.startWork,
      endWork: DateTime.now(),
      breaks: lastSession.breaks,
      totalWorkMinutes: totalMinutes,
    );
    // it means the session started earlier and is now completed.
    await docRef.update({
      "status": "completed",
      "sessions": sessions.map((e) => e.toMap()).toList(),
    });
    await _db.collection('employees').doc(userId).update({
      'isWorking': false,
      'activeCompanyId': null,
      'activeBranchId': null,
    });
  }

  Future<TimeEntry?> getTimeEntryForToday(
      String userId, String companyId, String branchId) async {
    final today = _today();
    final docRef = _db.collection('timeEntries').doc("${userId}_$today");
    final doc = await docRef.get();

    if (!doc.exists) return null;

    final entry = TimeEntry.fromFirestore(doc.id, doc.data()!);

    // Only the current branch and company
    if (entry.branchId != branchId || entry.companyId != companyId) return null;

    return entry;
  }

  Future<String> getEmployeeStatusToday(
    String employeeId,
    String companyId,
    String branchId,
  ) async {
    final today = _today();
    final docRef = _db.collection('timeEntries').doc("${employeeId}_$today");

    final doc = await docRef.get();

    if (!doc.exists) return "idle"; // gray

    final entry = TimeEntry.fromFirestore(doc.id, doc.data()!);

    if (entry.status == "completed") return "completed"; // red

    final lastSession = entry.sessions.isNotEmpty ? entry.sessions.last : null;

    if (lastSession == null) return "idle";

    final activeBreak = lastSession.breaks.any(
      (b) => b.endTime == null,
    );

    if (activeBreak) return "break"; // orange

    return "working"; // green
  }

  Future<Map<String, String>?> getRunningBranchForCompany(
      String companyId) async {
    final today = _today();

    final snapshot = await _db
        .collection('timeEntries')
        .where('companyId', isEqualTo: companyId)
        .where('workDate', isEqualTo: today)
        .where('status', isEqualTo: 'running')
        .get();

    if (snapshot.docs.isEmpty) return null;

    final doc = snapshot.docs.first;

    return {
      'branchId': doc['branchId'],
      'branchName': doc['branchId'], //
    };
  }
}
