import 'package:cloud_firestore/cloud_firestore.dart';

class ScheduleEntry {
  final String id;
  final String title;
  final String instructor;
  final String location;
  final DateTime startDate;
  final DateTime endDate;
  final String startTime; // e.g. "9:00 AM"
  final String endTime; // e.g. "10:30 AM"
  final List<String> days; // ['M','W','F']
  final String? tag;
  final String? note;
  final DateTime createdAt;

  ScheduleEntry({
    required this.id,
    required this.title,
    required this.instructor,
    required this.location,
    required this.startDate,
    required this.endDate,
    required this.startTime,
    required this.endTime,
    required this.days,
    this.tag,
    this.note,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() => {
    'title': title,
    'instructor': instructor,
    'location': location,
    'startDate': Timestamp.fromDate(startDate),
    'endDate': Timestamp.fromDate(endDate),
    'startTime': startTime,
    'endTime': endTime,
    'days': days,
    'tag': tag,
    'note': note,
    'createdAt': Timestamp.fromDate(createdAt),
  };

  factory ScheduleEntry.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    Timestamp sd = data['startDate'] as Timestamp;
    Timestamp ed = data['endDate'] as Timestamp;
    Timestamp ca = data['createdAt'] as Timestamp;

    return ScheduleEntry(
      id: doc.id,
      title: data['title'] ?? '',
      instructor: data['instructor'] ?? '',
      location: data['location'] ?? '',
      startDate: sd.toDate(),
      endDate: ed.toDate(),
      startTime: data['startTime'] ?? '',
      endTime: data['endTime'] ?? '',
      days: List<String>.from(data['days'] ?? []),
      tag: data['tag'],
      note: data['note'],
      createdAt: ca.toDate(),
    );
  }
}
