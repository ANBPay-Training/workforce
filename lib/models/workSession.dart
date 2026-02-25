import 'package:cloud_firestore/cloud_firestore.dart';

import 'breakSession.dart';

class WorkSession {
  final DateTime startWork;
  final DateTime? endWork;
  final List<BreakSession> breaks;
  final int totalWorkMinutes; // Total working hours in a session

  WorkSession({
    required this.startWork,
    this.endWork,
    required this.breaks,
    required this.totalWorkMinutes,
  });
// Factory constructor that converts raw Firestore data (Map<String, dynamic>)
// into a proper TimeEntry model object, since Firestore only returns a Map.
  factory WorkSession.fromMap(Map<String, dynamic> data) {
    // If endWork exists, convert it from Timestamp to DateTime.
    // If not, keep it null to indicate the work is still in progress.
    final breaksData = data['breaks'] as List<dynamic>? ?? [];
    // Firestore stores time as a Timestamp,
    // but in Dart we use DateTime.
    // .toDate() : convert the Firestore Timestamp into a Dart DateTime object.
    return WorkSession(
      startWork: (data['startWork'] as Timestamp).toDate(),
      endWork: data['endWork'] != null
          ? (data['endWork'] as Timestamp).toDate()
          : null,
      // List<Map> ➜ List<BreakSession>
      breaks: breaksData
          .map((e) => BreakSession.fromMap(e as Map<String, dynamic>))
          .toList(),
      totalWorkMinutes: data['totalWorkMinutes'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'startWork': Timestamp.fromDate(startWork),
      'endWork': endWork != null ? Timestamp.fromDate(endWork!) : null,
      'breaks': breaks.map((b) => b.toMap()).toList(),
      'totalWorkMinutes': totalWorkMinutes,
    };
  }
}
