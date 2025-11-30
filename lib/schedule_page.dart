import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'services/user_repository.dart';
import 'models/schedule_entry.dart' as models;
import 'package:appdev_project/add_schedule_page.dart';
import 'package:appdev_project/alerts_page.dart';
import 'package:appdev_project/weather_page.dart';
import 'package:appdev_project/settings_page.dart';
import 'package:appdev_project/main.dart';

class SchedulePage extends StatefulWidget {
  const SchedulePage({super.key});

  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  late DateTime currentWeekStart;
  late int selectedDay;
  final ScrollController _scrollController = ScrollController();
  bool _showFab = false;
  int weekOffset = 0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    DateTime now = DateTime.now();
    int daysFromSunday = now.weekday % 7;
    currentWeekStart = now.subtract(Duration(days: daysFromSunday));
    selectedDay = now.day;
  }

  void _scrollListener() {
    double threshold = 100;
    if (!_scrollController.hasClients) return;
    threshold = _scrollController.position.maxScrollExtent / 8;
    if (_scrollController.offset >= threshold && !_showFab) {
      setState(() => _showFab = true);
    } else if (_scrollController.offset < threshold && _showFab) {
      setState(() => _showFab = false);
    }
  }

  void _navigateWeek(int direction) {
    setState(() {
      weekOffset += direction;
      DateTime now = DateTime.now();
      int daysFromSunday = now.weekday % 7;
      DateTime baseWeekStart = now.subtract(Duration(days: daysFromSunday));
      currentWeekStart = baseWeekStart.add(Duration(days: weekOffset * 7));
      selectedDay = currentWeekStart.day;
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onSurface = theme.colorScheme.onSurface;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor, // themed background
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        DateFormat('h:mm').format(DateTime.now()),
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: onSurface, // themed text
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
                          Icon(Icons.battery_full, size: 20, color: onSurface),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Schedule',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: onSurface,
                    ),
                  ),
                ],
              ),
            ),

            Divider(color: theme.dividerColor, thickness: 1, height: 1),

            // Week calendar
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.chevron_left,
                      color: onSurface.withOpacity(0.7),
                    ),
                    onPressed: () => _navigateWeek(-1),
                  ),
                  ...List.generate(5, (index) {
                    DateTime date = currentWeekStart.add(Duration(days: index));
                    String dayName = DateFormat(
                      'EEE',
                    ).format(date).substring(0, 3);
                    bool isSelected = date.day == selectedDay;
                    return GestureDetector(
                      onTap: () => setState(() => selectedDay = date.day),
                      child: _buildDayItem(dayName, date.day, isSelected),
                    );
                  }),
                  IconButton(
                    icon: Icon(
                      Icons.chevron_right,
                      color: onSurface.withOpacity(0.7),
                    ),
                    onPressed: () => _navigateWeek(1),
                  ),
                ],
              ),
            ),

            Divider(color: theme.dividerColor, thickness: 1, height: 1),

            // Schedule list from Firestore
            Expanded(
              child: StreamBuilder<List<models.ScheduleEntry>>(
                stream: (() {
                  final user = FirebaseAuth.instance.currentUser;
                  if (user == null)
                    return Stream<List<models.ScheduleEntry>>.empty();
                  return UserRepository.instance.streamSchedule(user.uid);
                })(),
                builder: (context, snap) {
                  final entries = snap.data ?? [];

                  // Determine weekday letter (M,T,W,T,F,S,S) from selectedDay
                  DateTime selectedDate = currentWeekStart.add(
                    Duration(
                      days: [0, 1, 2, 3, 4].firstWhere(
                        (i) =>
                            currentWeekStart.add(Duration(days: i)).day ==
                            selectedDay,
                        orElse: () => 0,
                      ),
                    ),
                  );
                  String weekdayLetter = DateFormat(
                    'E',
                  ).format(selectedDate).substring(0, 1);

                  // Filter by day and within start/end dates
                  final todayEntries = entries.where((e) {
                    if (!e.days.contains(weekdayLetter)) return false;
                    return !(selectedDate.isBefore(e.startDate) ||
                        selectedDate.isAfter(e.endDate));
                  }).toList();

                  // Build simple time-ordered list
                  todayEntries.sort(
                    (a, b) => a.startTime.compareTo(b.startTime),
                  );

                  if (todayEntries.isEmpty) {
                    return Center(child: Text('No classes scheduled'));
                  }

                  return ListView.separated(
                    controller: _scrollController,
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    itemBuilder: (context, index) {
                      final e = todayEntries[index];
                      return Dismissible(
                        key: Key(e.id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: EdgeInsets.only(right: 20),
                          decoration: BoxDecoration(
                            color: Colors.redAccent,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(Icons.delete, color: Colors.white),
                        ),
                        confirmDismiss: (direction) async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: Text('Delete class?'),
                              content: Text(
                                'Remove "${e.title}" from your schedule?',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx, false),
                                  child: Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx, true),
                                  child: Text(
                                    'Delete',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ),
                              ],
                            ),
                          );
                          if (confirm != true) return false;

                          final uid = FirebaseAuth.instance.currentUser?.uid;
                          if (uid == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Not signed in')),
                            );
                            return false;
                          }

                          try {
                            // Backup entry for undo
                            final backup = models.ScheduleEntry(
                              id: '',
                              title: e.title,
                              instructor: e.instructor,
                              location: e.location,
                              startDate: e.startDate,
                              endDate: e.endDate,
                              startTime: e.startTime,
                              endTime: e.endTime,
                              days: List<String>.from(e.days),
                              tag: e.tag,
                              note: e.note,
                            );

                            await UserRepository.instance.deleteScheduleEntry(
                              uid,
                              e.id,
                            );

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Class deleted'),
                                action: SnackBarAction(
                                  label: 'UNDO',
                                  onPressed: () async {
                                    try {
                                      await UserRepository.instance
                                          .addScheduleEntry(uid, backup);
                                    } catch (err) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text('Restore failed: $err'),
                                        ),
                                      );
                                    }
                                  },
                                ),
                              ),
                            );
                            return true;
                          } catch (err) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Delete failed: $err')),
                            );
                            return false;
                          }
                        },
                        child: _buildClassCard(
                          title: e.title,
                          instructor: '${e.instructor} | ${e.location}',
                          time: '${e.startTime} - ${e.endTime}',
                          tag: e.tag ?? '',
                          note: e.note,
                        ),
                      );
                    },
                    separatorBuilder: (_, __) => SizedBox(height: 12),
                    itemCount: todayEntries.length,
                  );
                },
              ),
            ),

            // (FAB removed from body — now provided by Scaffold.floatingActionButton)
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => AddSchedulePage()),
          );
        },
        backgroundColor: theme.colorScheme.background,
        foregroundColor: onSurface,
        child: Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: _buildBottomNavBar(theme, onSurface, isDark),
    );
  }

  Widget _buildDayItem(String day, int date, bool isSelected) {
    final theme = Theme.of(context);
    final onSurface = theme.colorScheme.onSurface;
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      children: [
        Text(
          day,
          style: TextStyle(
            fontSize: 12,
            color: isSelected
                ? const Color(0xFF1976D2)
                : onSurface.withOpacity(0.7),
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        SizedBox(height: 8),
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF1976D2) : Colors.transparent,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              date.toString(),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                // selected stays white; unselected becomes lighter in dark mode
                color: isSelected
                    ? Colors.white
                    : (isDark ? onSurface.withOpacity(0.7) : Colors.black),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildClassCard({
    required String title,
    required String instructor,
    required String time,
    required String tag,
    String? note,
  }) {
    final theme = Theme.of(context);
    final onSurface = theme.colorScheme.onSurface;
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? Colors.white10 : Colors.black12),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: onSurface,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white10 : Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  tag,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: onSurface,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            instructor,
            style: TextStyle(fontSize: 14, color: onSurface.withOpacity(0.7)),
          ),
          SizedBox(height: 4),
          Text(
            time,
            style: TextStyle(fontSize: 14, color: onSurface.withOpacity(0.7)),
          ),
          if (note != null) ...[
            SizedBox(height: 12),
            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isDark ? Colors.white10 : Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 16,
                    color: const Color(0xFF1976D2),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      note,
                      style: TextStyle(fontSize: 13, color: onSurface),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBottomNavBar(ThemeData theme, Color onSurface, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.background, // avoid seed-tinted blue overlay
        boxShadow: [
          BoxShadow(
            color: (isDark
                ? Colors.black.withOpacity(0.4)
                : Colors.black.withOpacity(0.08)),
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
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(Icons.home_outlined, 'Home', false, onSurface),
              _buildNavItem(Icons.calendar_today, 'Schedule', true, onSurface),
              _buildNavItem(
                Icons.notifications_outlined,
                'Alerts',
                false,
                onSurface,
              ),
              _buildNavItem(Icons.cloud_outlined, 'Weather', false, onSurface),
              _buildNavItem(
                Icons.settings_outlined,
                'Settings',
                false,
                onSurface,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    IconData icon,
    String label,
    bool isActive,
    Color onSurface,
  ) {
    return Expanded(
      child: InkWell(
        onTap: () {
          if (label == 'Schedule' && !isActive) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (c) => SchedulePage()),
            );
            return;
          }
          if (label == 'Alerts' && !isActive) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (c) => AlertsPage()),
            );
            return;
          }
          if (label == 'Weather' && !isActive) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (c) => WeatherPage()),
            );
            return;
          }
          if (label == 'Home' && !isActive) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (c) => AcadEaseHome()),
            );
            return;
          }
          if (label == 'Settings' && !isActive) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (c) => SettingsPage()),
            );
            return;
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
                    ? const Color(0xFF1976D2)
                    : onSurface.withOpacity(0.7),
                size: 26,
              ),
              SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: isActive
                      ? const Color(0xFF1976D2)
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
