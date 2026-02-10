import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:workforce/models/workSession.dart';

class TimeEntry {
  final String id;
  final String userId;
  final String companyId;
  final String branchId;
  final String workDate; // YYYY-MM-DD
  final List<WorkSession> sessions;
  final int totalWorkMinutes; // ⬅️Total working hours in a day
  final String status; // running | completed

  TimeEntry({
    required this.id,
    required this.userId,
    required this.companyId,
    required this.branchId,
    required this.workDate,
    required this.sessions,
    required this.totalWorkMinutes,
    required this.status,
  });

  factory TimeEntry.fromFirestore(String id, Map<String, dynamic> data) {
    final sessionsData = data['sessions'] as List<dynamic>? ?? [];

    return TimeEntry(
      id: id,
      userId: data['userId'],
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
      'userId': userId,
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
