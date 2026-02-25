import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:workforce/models/workSession.dart';

class TimeEntry {
  final String id;
  final String employeeId;
  final String companyId;
  final String branchId;
  final String workDate; // YYYY-MM-DD
  final List<WorkSession> sessions;
  final int totalWorkMinutes; // Total working hours in a day
  final String status; // running | completed

  TimeEntry({
    required this.id,
    required this.employeeId,
    required this.companyId,
    required this.branchId,
    required this.workDate,
    required this.sessions,
    required this.totalWorkMinutes,
    required this.status,
  });
// Factory constructor that converts raw Firestore data (Map<String, dynamic>)
// into a proper TimeEntry model object, since Firestore only returns a Map.
  factory TimeEntry.fromFirestore(String id, Map<String, dynamic> data) {
    // Retrieve the "sessions" field from the Map.
    // If it is null, create an empty list.
    // This ensures sessionsData is always a list,
    // even if no sessions are stored.

    // TimeEntry
    //  ├── sessions (List)
    //  │     ├── WorkSession
    //  │     │      ├── breaks (List)
    //  │     │      │      └── BreakSession

    final sessionsData = data['sessions'] as List<dynamic>? ?? [];

    return TimeEntry(
      id: id,
      employeeId: data['employeeId'],
      companyId: data['companyId'],
      branchId: data['branchId'],
      workDate: data['workDate'],
      sessions: sessionsData
          .map((e) => WorkSession.fromMap(e as Map<String, dynamic>))
          .toList(),
      totalWorkMinutes: data['totalWorkMinutes'] ?? 0,
      status: data['status'] ?? 'completed',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'employeeId': employeeId,
      'companyId': companyId,
      'branchId': branchId,
      'workDate': workDate,
      'sessions': sessions.map((s) => s.toMap()).toList(),
      'totalWorkMinutes': totalWorkMinutes,
      'status': status,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}
