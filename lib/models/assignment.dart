import 'package:cloud_firestore/cloud_firestore.dart';

class AssignmentItem {
  final String id;
  final String title;
  final String? description;
  final DateTime dueDate;
  final String priority; // High/Medium/Low
  final bool notificationsEnabled;
  final DateTime createdAt;

  AssignmentItem({
    required this.id,
    required this.title,
    this.description,
    required this.dueDate,
    required this.priority,
    this.notificationsEnabled = true,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() => {
    'title': title,
    'description': description,
    'dueDate': Timestamp.fromDate(dueDate),
    'priority': priority,
    'notificationsEnabled': notificationsEnabled,
    'createdAt': Timestamp.fromDate(createdAt),
  };

  factory AssignmentItem.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    Timestamp due = data['dueDate'] as Timestamp;
    Timestamp ca = data['createdAt'] as Timestamp;
    return AssignmentItem(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'],
      dueDate: due.toDate(),
      priority: data['priority'] ?? 'Medium',
      notificationsEnabled: data['notificationsEnabled'] ?? true,
      createdAt: ca.toDate(),
    );
  }
}
