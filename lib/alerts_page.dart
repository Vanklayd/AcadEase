import 'package:flutter/material.dart';
import 'package:appdev_project/main.dart';
import 'package:appdev_project/schedule_page.dart';
import 'package:appdev_project/weather_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'services/user_repository.dart';
import 'models/alert_item.dart' as models_alert;
import 'package:intl/intl.dart';

class AlertsPage extends StatefulWidget {
  const AlertsPage({super.key});

  @override
  State<AlertsPage> createState() => _AlertsPageState();
}

class _AlertsPageState extends State<AlertsPage> {
  String selectedTab = 'Today';
  List<String> completedAlerts = [];
  List<String> snoozedAlerts = [];

  void _markAsDone(String alertId) {
    setState(() {
      completedAlerts.add(alertId);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Task marked as complete!'),
        duration: Duration(seconds: 2),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _snoozeAlert(String alertId) {
    setState(() {
      snoozedAlerts.add(alertId);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Alert snoozed for 1 hour'),
        duration: Duration(seconds: 2),
        backgroundColor: Colors.orange,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Status bar
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '9:41',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                  Row(
                    children: [
                      Icon(Icons.signal_cellular_4_bar, size: 16),
                      SizedBox(width: 4),
                      Icon(Icons.wifi, size: 16),
                      SizedBox(width: 4),
                      Icon(Icons.battery_full, size: 16),
                    ],
                  ),
                ],
              ),
            ),
            // Title
            Container(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Text(
                'Alerts',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              ),
            ),
            // Divider
            Container(height: 1, color: Colors.grey[300]),
            // Tabs
            Padding(
              padding: EdgeInsets.all(20),
              child: Row(
                children: [
                  _buildTab('Today'),
                  SizedBox(width: 12),
                  _buildTab('This Week'),
                  SizedBox(width: 12),
                  _buildTab('Missed Tasks'),
                ],
              ),
            ),
            // Alerts List (real-time from Firestore)
            Expanded(
              child: StreamBuilder<List<models_alert.AlertItem>>(
                stream: (() {
                  final user = FirebaseAuth.instance.currentUser;
                  if (user == null)
                    return Stream<List<models_alert.AlertItem>>.empty();
                  return UserRepository.instance.streamAlerts(user.uid);
                })(),
                builder: (context, snap) {
                  final alerts = snap.data ?? [];
                  if (alerts.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: EdgeInsets.all(40),
                        child: Text('No alerts'),
                      ),
                    );
                  }

                  return SingleChildScrollView(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: alerts.map((a) {
                        return Column(
                          children: [
                            _buildAlertItem(
                              alertId: a.id,
                              icon: a.category == 'assignment'
                                  ? Icons.assignment
                                  : Icons.list_alt,
                              title: a.title,
                              subtitle: a.body,
                              time: DateFormat(
                                'MMM d • h:mm a',
                              ).format(a.createdAt),
                              type: a.category,
                              isOverdue:
                                  a.category == 'assignment' &&
                                  a.severity == 'high',
                            ),
                            SizedBox(height: 16),
                          ],
                        );
                      }).toList(),
                    ),
                  );
                },
              ),
            ),
            // Bottom Navigation
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 12,
                    offset: Offset(0, -2),
                  ),
                ],
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8.0,
                    vertical: 8.0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildNavItem(context, Icons.home, "Home", false),
                      _buildNavItem(
                        context,
                        Icons.calendar_today_outlined,
                        "Schedule",
                        false,
                      ),
                      _buildNavItem(
                        context,
                        Icons.notifications_outlined,
                        "Alerts",
                        true,
                      ),
                      _buildNavItem(
                        context,
                        Icons.cloud_outlined,
                        "Weather",
                        false,
                      ),
                      _buildNavItem(
                        context,
                        Icons.settings_outlined,
                        "Settings",
                        false,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTab(String label) {
    bool isSelected = selectedTab == label;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedTab = label;
          });
        },
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            border: Border.all(
              color: isSelected ? Color(0xFF03A9F4) : Colors.grey[300]!,
              width: isSelected ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(8),
            color: isSelected
                ? Color(0xFF03A9F4).withOpacity(0.05)
                : Colors.white,
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: isSelected ? Color(0xFF03A9F4) : Colors.grey[600],
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildAlertsForTab() {
    if (selectedTab == 'Today') {
      List<Widget> alerts = [];
      if (!completedAlerts.contains('today_lecture') &&
          !snoozedAlerts.contains('today_lecture')) {
        alerts.add(
          _buildAlertItem(
            alertId: 'today_lecture',
            icon: Icons.list_alt,
            title: 'Intro to AI - Lecture',
            subtitle:
                'Lecture on Machine Learning basics. Don\'t forget your notes.',
            time: '10:00 AM',
            type: 'Class Reminder',
          ),
        );
        alerts.add(SizedBox(height: 16));
      }
      if (!completedAlerts.contains('today_assignment') &&
          !snoozedAlerts.contains('today_assignment')) {
        alerts.add(
          _buildAlertItem(
            alertId: 'today_assignment',
            icon: Icons.assignment,
            title: 'AI Project Proposal',
            subtitle:
                'Submit your project proposal by 11:59 PM. Review guidelines carefully.',
            time: '04:00 PM',
            type: 'Assignment Due',
          ),
        );
      }
      return alerts.isEmpty
          ? [
              Center(
                child: Padding(
                  padding: EdgeInsets.all(40),
                  child: Text(
                    'No alerts for today',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ),
              ),
            ]
          : alerts;
    } else if (selectedTab == 'This Week') {
      List<Widget> alerts = [];
      if (!completedAlerts.contains('week_quiz') &&
          !snoozedAlerts.contains('week_quiz')) {
        alerts.add(
          _buildAlertItem(
            alertId: 'week_quiz',
            icon: Icons.list_alt,
            title: 'Intro to AI - Quiz',
            subtitle:
                'Quiz on Machine Learning basics. Don\'t forget to review your notes.',
            time: 'Wednesday\n10:00 AM',
            type: 'Class Reminder',
          ),
        );
        alerts.add(SizedBox(height: 16));
      }
      if (!completedAlerts.contains('week_prototype') &&
          !snoozedAlerts.contains('week_prototype')) {
        alerts.add(
          _buildAlertItem(
            alertId: 'week_prototype',
            icon: Icons.assignment,
            title: 'Web App Prototype',
            subtitle:
                'Submit your project prototype by 11:59 PM. Review guidelines carefully.',
            time: 'Monday\n11:59 PM',
            type: 'Assignment Due',
          ),
        );
        alerts.add(SizedBox(height: 16));
      }
      if (!completedAlerts.contains('week_ann_quiz') &&
          !snoozedAlerts.contains('week_ann_quiz')) {
        alerts.add(
          _buildAlertItem(
            alertId: 'week_ann_quiz',
            icon: Icons.list_alt,
            title: 'Artificial Neural Networks Quiz',
            subtitle:
                'Quiz on Artificial Neural Networks Unit 3. Don\'t forget to review your notes.',
            time: 'Thursday\n04:00 PM',
            type: 'Class Reminder',
          ),
        );
      }
      return alerts.isEmpty
          ? [
              Center(
                child: Padding(
                  padding: EdgeInsets.all(40),
                  child: Text(
                    'No alerts this week',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ),
              ),
            ]
          : alerts;
    } else {
      List<Widget> alerts = [];
      if (!completedAlerts.contains('missed_proposal') &&
          !snoozedAlerts.contains('missed_proposal')) {
        alerts.add(
          _buildAlertItem(
            alertId: 'missed_proposal',
            icon: Icons.assignment,
            title: 'AI Project Proposal',
            subtitle:
                'Submit your project proposal by 11:59 PM. Review guidelines carefully.',
            time: 'Monday\n11:59 PM',
            type: 'Assignment Overdue',
            isOverdue: true,
          ),
        );
        alerts.add(SizedBox(height: 16));
      }
      if (!completedAlerts.contains('missed_activity') &&
          !snoozedAlerts.contains('missed_activity')) {
        alerts.add(
          _buildAlertItem(
            alertId: 'missed_activity',
            icon: Icons.assignment,
            title: 'Software Engineering Activity',
            subtitle:
                'Submit your project proposal by 11:59 PM. Review guidelines carefully.',
            time: 'Friday\n11:59 PM',
            type: 'Assignment Overdue',
            isOverdue: true,
          ),
        );
      }
      return alerts.isEmpty
          ? [
              Center(
                child: Padding(
                  padding: EdgeInsets.all(40),
                  child: Text(
                    'No missed tasks',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ),
              ),
            ]
          : alerts;
    }
  }

  Widget _buildAlertItem({
    required String alertId,
    required IconData icon,
    required String title,
    required String subtitle,
    required String time,
    required String type,
    bool isOverdue = false,
  }) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: Colors.grey[700]),
              SizedBox(width: 8),
              Text(
                type,
                style: TextStyle(
                  fontSize: 14,
                  color: isOverdue ? Colors.red : Colors.grey[700],
                  fontWeight: isOverdue ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
              Spacer(),
              Text(
                time,
                textAlign: TextAlign.right,
                style: TextStyle(fontSize: 13, color: Colors.grey[600]),
              ),
            ],
          ),
          SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isOverdue ? Colors.red : Colors.black,
            ),
          ),
          SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
              height: 1.4,
            ),
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _markAsDone(alertId),
                  icon: Icon(Icons.check_circle_outline, size: 18),
                  label: Text('Mark as Done'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF03A9F4),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _snoozeAlert(alertId),
                  icon: Icon(Icons.access_time, size: 18),
                  label: Text('Snooze'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.grey[700],
                    padding: EdgeInsets.symmetric(vertical: 12),
                    side: BorderSide(color: Colors.grey[300]!),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context,
    IconData icon,
    String label,
    bool isActive,
  ) {
    return Expanded(
      child: InkWell(
        onTap: () {
          if (label == "Schedule" && !isActive) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => SchedulePage()),
            );
          } else if (label == "Weather" && !isActive) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => WeatherPage()),
            );
          } else if (label == "Home" && !isActive) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => AcadEaseHome()),
            );
          }
        },
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: isActive ? Color(0xFF1976D2) : Colors.grey[600],
                size: 26,
              ),
              SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: isActive ? Color(0xFF1976D2) : Colors.grey[600],
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
