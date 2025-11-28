import 'package:cloud_firestore/cloud_firestore.dart';

class AlertItem {
  final String id;
  final String title;
  final String body;
  final String category; // e.g., 'assignment', 'class', 'weather'
  final String severity; // low/medium/high
  final bool resolved;
  final DateTime createdAt;
  final String? relatedId; // id of assignment or schedule entry

  AlertItem({
    required this.id,
    required this.title,
    required this.body,
    required this.category,
    this.severity = 'low',
    this.resolved = false,
    DateTime? createdAt,
    this.relatedId,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() => {
    'title': title,
    'body': body,
    'category': category,
    'severity': severity,
    'resolved': resolved,
    'createdAt': Timestamp.fromDate(createdAt),
    'relatedId': relatedId,
  };

  factory AlertItem.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    Timestamp ca = data['createdAt'] as Timestamp;
    return AlertItem(
      id: doc.id,
      title: data['title'] ?? '',
      body: data['body'] ?? '',
      category: data['category'] ?? 'general',
      severity: data['severity'] ?? 'low',
      resolved: data['resolved'] ?? false,
      createdAt: ca.toDate(),
      relatedId: data['relatedId'],
    );
  }
}
