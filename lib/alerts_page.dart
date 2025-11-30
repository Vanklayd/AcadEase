import 'package:flutter/material.dart';
import 'dart:async';
import 'package:appdev_project/main.dart';
import 'package:appdev_project/schedule_page.dart';
import 'package:appdev_project/weather_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'services/user_repository.dart';
import 'models/alert_item.dart' as models_alert;
import 'package:intl/intl.dart';
import 'settings_page.dart';

class AlertsPage extends StatefulWidget {
  const AlertsPage({super.key});

  @override
  State<AlertsPage> createState() => _AlertsPageState();
}

class _AlertsPageState extends State<AlertsPage> {
  String selectedTab = 'Today';
  List<String> completedAlerts = [];
  List<String> snoozedAlerts = [];
  late String _currentTime;
  Timer? _clockTimer;

  Future<void> _markAsDone(String alertId) async {
    setState(() {
      completedAlerts.add(alertId);
    });
    await Future.delayed(const Duration(milliseconds: 250));
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      try {
        await UserRepository.instance.deleteAlert(uid, alertId);
      } catch (e) {
        // If deletion fails, revert fade state
        completedAlerts.remove(alertId);
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Failed to remove alert: $e')));
        }
        return;
      }
    }
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Task marked as complete!'),
          duration: Duration(seconds: 2),
          backgroundColor: Colors.green,
        ),
      );
    }
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
    final theme = Theme.of(context);
    final onSurface = theme.colorScheme.onSurface;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor, // themed
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
                    _currentTime,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: onSurface,
                    ),
                  ),
                  Row(
                    children: [
                      Icon(
                        Icons.signal_cellular_4_bar,
                        size: 16,
                        color: onSurface,
                      ),
                      SizedBox(width: 4),
                      Icon(Icons.wifi, size: 16, color: onSurface),
                      SizedBox(width: 4),
                      Icon(Icons.battery_full, size: 16, color: onSurface),
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
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: onSurface,
                ),
              ),
            ),
            // Divider
            Container(height: 1, color: theme.dividerColor),
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

                  DateTime now = DateTime.now();
                  DateTime startOfWeek = now.subtract(
                    Duration(days: now.weekday % 7),
                  );
                  DateTime endOfWeek = startOfWeek.add(const Duration(days: 6));
                  bool isSameDay(DateTime a, DateTime b) =>
                      a.year == b.year && a.month == b.month && a.day == b.day;

                  final filtered =
                      alerts.where((a) {
                        final d = a.createdAt;
                        switch (selectedTab) {
                          case 'Today':
                            return isSameDay(d, now);
                          case 'This Week':
                            return d.isAfter(
                                  startOfWeek.subtract(
                                    const Duration(seconds: 1),
                                  ),
                                ) &&
                                d.isBefore(
                                  endOfWeek.add(const Duration(days: 1)),
                                );
                          case 'Missed Tasks':
                            // Treat high severity or past assignment as missed
                            final past = d.isBefore(
                              DateTime(now.year, now.month, now.day),
                            );
                            final isAssignment = a.category == 'assignment';
                            final severe = (a.severity == 'high');
                            return severe || (isAssignment && past);
                          default:
                            return true;
                        }
                      }).toList()..sort(
                        (a, b) => b.createdAt.compareTo(a.createdAt),
                      );

                  if (filtered.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(40),
                        child: Text(
                          selectedTab == 'Missed Tasks'
                              ? 'No missed tasks'
                              : selectedTab == 'This Week'
                              ? 'No alerts this week'
                              : 'No alerts',
                          style: TextStyle(color: onSurface.withOpacity(0.7)),
                        ),
                      ),
                    );
                  }

                  return SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: filtered.map((a) {
                        final faded = completedAlerts.contains(a.id);
                        return AnimatedOpacity(
                          duration: const Duration(milliseconds: 250),
                          opacity: faded ? 0.0 : 1.0,
                          child: Column(
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
                              const SizedBox(height: 16),
                            ],
                          ),
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
                color: theme
                    .colorScheme
                    .background, // avoid seed-tinted blue overlay
                boxShadow: isDark
                    ? [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.4),
                          blurRadius: 10,
                          offset: Offset(0, -2),
                        ),
                      ]
                    : [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 12,
                          offset: Offset(0, -2),
                        ),
                      ],
                border: Border(
                  top: BorderSide(
                    color: theme.dividerColor.withOpacity(0.5),
                    width: 0.5,
                  ),
                ),
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

  @override
  void initState() {
    super.initState();
    _currentTime = DateFormat('h:mm').format(DateTime.now());
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {
        _currentTime = DateFormat('h:mm').format(DateTime.now());
      });
    });
  }

  @override
  void dispose() {
    _clockTimer?.cancel();
    super.dispose();
  }

  Widget _buildTab(String label) {
    final theme = Theme.of(context);
    final onSurface = theme.colorScheme.onSurface;
    bool isSelected = selectedTab == label;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => selectedTab = label),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            border: Border.all(
              color: isSelected ? const Color(0xFF03A9F4) : theme.dividerColor,
              width: isSelected ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(8),
            color: theme.cardColor,
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: isSelected
                  ? const Color(0xFF03A9F4)
                  : onSurface.withOpacity(0.7),
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
    final theme = Theme.of(context);
    final onSurface = theme.colorScheme.onSurface;
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor, // themed card
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? Colors.white10 : Colors.grey[300]!),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 8,
                  offset: Offset(0, 3),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: onSurface.withOpacity(0.8)),
              SizedBox(width: 8),
              Text(
                type,
                style: TextStyle(
                  fontSize: 14,
                  color: isOverdue
                      ? Colors.redAccent
                      : onSurface.withOpacity(0.8),
                  fontWeight: isOverdue ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
              Spacer(),
              Text(
                time,
                textAlign: TextAlign.right,
                style: TextStyle(
                  fontSize: 13,
                  color: onSurface.withOpacity(0.6),
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isOverdue ? Colors.redAccent : onSurface,
            ),
          ),
          SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 14,
              color: onSurface.withOpacity(0.8),
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
                    backgroundColor: const Color(0xFF03A9F4),
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
                  icon: Icon(
                    Icons.access_time,
                    size: 18,
                    color: onSurface.withOpacity(0.8),
                  ),
                  label: Text(
                    'Snooze',
                    style: TextStyle(color: onSurface.withOpacity(0.8)),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: theme.dividerColor),
                    padding: EdgeInsets.symmetric(vertical: 12),
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
    final onSurface = Theme.of(context).colorScheme.onSurface;
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
          } else if (label == "Settings" && !isActive) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const SettingsPage()),
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
                color: isActive
                    ? Color(0xFF1976D2)
                    : onSurface.withOpacity(0.7),
                size: 26,
              ),
              SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: isActive
                      ? Color(0xFF1976D2)
                      : onSurface.withOpacity(0.7),
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
