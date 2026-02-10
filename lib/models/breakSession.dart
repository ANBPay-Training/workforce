import 'package:cloud_firestore/cloud_firestore.dart';

class BreakSession {
  final DateTime startTime;
  final DateTime? endTime;
  final int minutes;

  BreakSession({
    required this.startTime,
    this.endTime,
    required this.minutes,
  });

  factory BreakSession.fromMap(Map<String, dynamic> data) {
    return BreakSession(
      startTime: (data['startTime'] as Timestamp).toDate(),
      endTime: data['endTime'] != null
          ? (data['endTime'] as Timestamp).toDate()
          : null,
      minutes: data['minutes'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'startTime': Timestamp.fromDate(startTime),
      'endTime': endTime != null ? Timestamp.fromDate(endTime!) : null,
      'minutes': minutes,
    };
  }
}
