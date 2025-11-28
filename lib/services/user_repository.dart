import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/schedule_entry.dart';
import '../models/assignment.dart';
import '../models/alert_item.dart';

class UserRepository {
  final FirebaseFirestore _db;
  UserRepository._(this._db);

  static final UserRepository instance = UserRepository._(
    FirebaseFirestore.instance,
  );

  String _userPath(String uid) => 'users/$uid';

  CollectionReference _scheduleCol(String uid) =>
      _db.collection('${_userPath(uid)}/schedule');
  CollectionReference _assignCol(String uid) =>
      _db.collection('${_userPath(uid)}/assignments');
  CollectionReference _alertsCol(String uid) =>
      _db.collection('${_userPath(uid)}/alerts');

  Future<void> addScheduleEntry(String uid, ScheduleEntry entry) async {
    await _scheduleCol(uid).add(entry.toMap());
    // Optionally create an alert for the class start
    await addAlert(
      uid,
      AlertItem(
        id: '',
        title: 'Class added: ${entry.title}',
        body: '${entry.title} at ${entry.startTime} in ${entry.location}',
        category: 'class',
        severity: 'low',
        relatedId: null,
      ),
    );
  }

  Future<void> addAssignment(String uid, AssignmentItem a) async {
    final docRef = await _assignCol(uid).add(a.toMap());
    // Create an alert for the assignment due
    await addAlert(
      uid,
      AlertItem(
        id: '',
        title: 'Assignment: ${a.title} due',
        body: 'Due ${a.dueDate.toLocal().toString()}',
        category: 'assignment',
        severity: a.priority.toLowerCase(),
        relatedId: docRef.id,
      ),
    );
  }

  Future<void> addAlert(String uid, AlertItem alert) async {
    await _alertsCol(uid).add(alert.toMap());
  }

  Stream<List<ScheduleEntry>> streamSchedule(String uid) {
    return _scheduleCol(uid)
        .orderBy('startDate')
        .snapshots()
        .map((snap) => snap.docs.map((d) => ScheduleEntry.fromDoc(d)).toList());
  }

  Stream<List<AssignmentItem>> streamAssignments(String uid) {
    return _assignCol(uid)
        .orderBy('dueDate')
        .snapshots()
        .map(
          (snap) => snap.docs.map((d) => AssignmentItem.fromDoc(d)).toList(),
        );
  }

  Stream<List<AlertItem>> streamAlerts(String uid) {
    return _alertsCol(uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) => AlertItem.fromDoc(d)).toList());
  }
}
