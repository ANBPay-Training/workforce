import 'package:cloud_firestore/cloud_firestore.dart';

import 'breakSession.dart';

class WorkSession {
  final DateTime startTime;
  final DateTime? endTime;
  final List<BreakSession> breaks;
  final int totalWorkMinutes; // Total working hours in a session

  WorkSession({
    required this.startTime,
    this.endTime,
    required this.breaks,
    required this.totalWorkMinutes,
  });

  factory WorkSession.fromMap(Map<String, dynamic> data) {
    final breaksData = data['breaks'] as List<dynamic>? ?? [];

    return WorkSession(
      startTime: (data['startTime'] as Timestamp).toDate(),
      endTime: data['endTime'] != null
          ? (data['endTime'] as Timestamp).toDate()
          : null,
      breaks: breaksData
          .map((e) => BreakSession.fromMap(e as Map<String, dynamic>))
          .toList(),
      totalWorkMinutes: data['totalWorkMinutes'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'startTime': Timestamp.fromDate(startTime),
      'endTime': endTime != null ? Timestamp.fromDate(endTime!) : null,
      'breaks': breaks.map((b) => b.toMap()).toList(),
      'totalWorkMinutes': totalWorkMinutes,
    };
  }
}
