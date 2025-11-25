import 'package:flutter/material.dart';
import 'package:appdev_project/main.dart';
import 'package:appdev_project/alerts_page.dart';
import 'package:appdev_project/weather_page.dart';
import 'package:appdev_project/add_schedule_page.dart';
import 'package:intl/intl.dart';

class SchedulePage extends StatefulWidget {
  const SchedulePage({super.key});

  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  late DateTime currentWeekStart;
  late int selectedDay;
  ScrollController _scrollController = ScrollController();
  bool _showFab = false;
  int weekOffset = 0; // Track which week we're viewing

  // Sample subjects pool
  final List<Map<String, dynamic>> subjectPool = [
    {'title': 'Operating Systems', 'instructor': 'Prof. J. Cruz', 'location': 'CS Lab 201'},
    {'title': 'Discrete Mathematics', 'instructor': 'Dr. M. Garcia', 'location': 'Rm 305'},
    {'title': 'Data Structures', 'instructor': 'Engr. R. Santos', 'location': 'Lecture Hall 1'},
    {'title': 'Web Development', 'instructor': 'Prof. A. Reyes', 'location': 'IT Lab 102'},
    {'title': 'Database Systems', 'instructor': 'Dr. L. Torres', 'location': 'Rm 210'},
    {'title': 'Computer Networks', 'instructor': 'Engr. P. Mendoza', 'location': 'CS Lab 203'},
    {'title': 'Software Engineering', 'instructor': 'Prof. K. Villanueva', 'location': 'Rm 401'},
    {'title': 'Mobile Development', 'instructor': 'Dr. S. Castillo', 'location': 'IT Lab 105'},
    {'title': 'Machine Learning', 'instructor': 'Prof. D. Ramos', 'location': 'AI Lab 301'},
    {'title': 'Artificial Intelligence', 'instructor': 'Dr. R. Flores', 'location': 'AI Lab 302'},
  ];

  final List<String> tags = ['Weekly', 'MWF', 'TTH', 'Daily'];
  final List<String> times = [
    '9:00 AM - 10:30 AM',
    '11:00 AM - 12:00 PM',
    '1:00 PM - 2:30 PM',
    '2:00 PM - 3:30 PM',
    '3:00 PM - 4:30 PM',
    '4:00 PM - 5:30 PM',
  ];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    // Get current date and calculate week start (Sunday)
    DateTime now = DateTime.now();
    int daysFromSunday = now.weekday % 7; // Sunday = 0
    currentWeekStart = now.subtract(Duration(days: daysFromSunday));
    selectedDay = now.day; // Select today's date
  }

  void _navigateWeek(int direction) {
    setState(() {
      weekOffset += direction;
      DateTime now = DateTime.now();
      int daysFromSunday = now.weekday % 7;
      DateTime baseWeekStart = now.subtract(Duration(days: daysFromSunday));
      currentWeekStart = baseWeekStart.add(Duration(days: weekOffset * 7));
      // Update selected day to the first day of the new week
      selectedDay = currentWeekStart.day;
    });
  }

  List<Map<String, dynamic>> _getScheduleForDay(DateTime date) {
    // Generate deterministic random schedule based on date
    int seed = date.year * 10000 + date.month * 100 + date.day;
    // Number of classes for the day (2-4 classes)
    int classCount = (seed % 3) + 2;
    
    List<Map<String, dynamic>> schedule = [];
    List<int> usedTimeSlots = [];
    
    for (int i = 0; i < classCount; i++) {
      int subjectIndex = (seed + i * 7) % subjectPool.length;
      int timeSlotIndex = (seed + i * 3) % times.length;
      
      // Avoid duplicate time slots
      while (usedTimeSlots.contains(timeSlotIndex)) {
        timeSlotIndex = (timeSlotIndex + 1) % times.length;
      }
      usedTimeSlots.add(timeSlotIndex);
      
      int tagIndex = (seed + i * 5) % tags.length;
      
      Map<String, dynamic> subject = subjectPool[subjectIndex];
      schedule.add({
        'timeSlot': timeSlotIndex,
        'title': subject['title'],
        'instructor': subject['instructor'],
        'location': subject['location'],
        'time': times[timeSlotIndex],
        'tag': tags[tagIndex],
        'note': (seed + i) % 5 == 0 ? 'Don\'t forget your project submission!' : null,
      });
    }
    
    // Sort by time slot
    schedule.sort((a, b) => a['timeSlot'].compareTo(b['timeSlot']));
    return schedule;
  }

  void _scrollListener() {
    // Show FAB when scrolled 1/8 of the total scrollable area
    double threshold = _scrollController.position.maxScrollExtent / 8;

    if (_scrollController.offset >= threshold && !_showFab) {
      setState(() {
        _showFab = true;
      });
    } else if (_scrollController.offset < threshold && _showFab) {
      setState(() {
        _showFab = false;
      });
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                // Header
                Container(
                  color: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Column(
                    children: [
                      // Status Bar
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            DateFormat('h:mm').format(DateTime.now()),
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: Colors.black,
                            ),
                          ),
                          Row(
                            children: [
                              Icon(Icons.signal_cellular_4_bar, size: 16),
                              SizedBox(width: 4),
                              Icon(Icons.wifi, size: 16),
                              SizedBox(width: 4),
                              Icon(Icons.battery_full, size: 20),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      // Title
                      Text(
                        "Schedule",
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),

                // Divider
                Divider(color: Colors.grey[300], thickness: 1, height: 1),

                // Week Calendar
                Container(
                  color: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: Icon(Icons.chevron_left, color: Colors.grey[600]),
                        onPressed: () => _navigateWeek(-1),
                        padding: EdgeInsets.zero,
                        constraints: BoxConstraints(),
                      ),
                      ...List.generate(5, (index) {
                        DateTime date = currentWeekStart.add(Duration(days: index));
                        String dayName = DateFormat('EEE').format(date).substring(0, 3);
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedDay = date.day;
                            });
                          },
                          child: _buildDayItem(dayName, date.day, date.day == selectedDay),
                        );
                      }),
                      IconButton(
                        icon: Icon(Icons.chevron_right, color: Colors.grey[600]),
                        onPressed: () => _navigateWeek(1),
                        padding: EdgeInsets.zero,
                        constraints: BoxConstraints(),
                      ),
                    ],
                  ),
                ),

                // Divider
                Divider(color: Colors.grey[300], thickness: 1, height: 1),

                // Schedule List
                Expanded(
                  child: Builder(
                    builder: (context) {
                      DateTime selectedDate = currentWeekStart.add(
                        Duration(days: List.generate(5, (i) => i).firstWhere(
                          (i) => currentWeekStart.add(Duration(days: i)).day == selectedDay,
                          orElse: () => 0,
                        ))
                      );
                      List<Map<String, dynamic>> daySchedule = _getScheduleForDay(selectedDate);
                      
                      // Build time slots from 8 AM to 8 PM
                      List<Widget> timeSlots = [];
                      Map<int, Map<String, dynamic>> classMap = {};
                      
                      // Map classes to their time slot indices
                      for (var classItem in daySchedule) {
                        classMap[classItem['timeSlot']] = classItem;
                      }
                      
                      // Generate time slots
                      List<String> allTimeSlots = [
                        '8:00 AM',
                        '9:00 AM',
                        '10:00 AM',
                        '11:00 AM',
                        '12:00 PM',
                        '1:00 PM',
                        '2:00 PM',
                        '3:00 PM',
                        '4:00 PM',
                        '5:00 PM',
                        '6:00 PM',
                        '7:00 PM',
                        '8:00 PM',
                      ];
                      
                      for (int i = 0; i < allTimeSlots.length; i++) {
                        // Check if there's a class starting at this hour
                        Map<String, dynamic>? matchingClass;
                        for (var entry in classMap.entries) {
                          if (times[entry.key].startsWith(allTimeSlots[i])) {
                            matchingClass = entry.value;
                            break;
                          }
                        }
                        
                        if (matchingClass != null) {
                          timeSlots.add(
                            _buildTimeSlot(
                              allTimeSlots[i],
                              _buildClassCard(
                                title: matchingClass['title'],
                                instructor: matchingClass['instructor'],
                                location: matchingClass['location'],
                                time: matchingClass['time'],
                                tag: matchingClass['tag'],
                                note: matchingClass['note'],
                              ),
                            ),
                          );
                        } else {
                          timeSlots.add(_buildTimeSlot(allTimeSlots[i], null));
                        }
                      }
                      
                      return ListView(
                        controller: _scrollController,
                        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        children: timeSlots,
                      );
                    },
                  ),
                ),
              ],
            ),

            // Floating Action Button - only show when scrolled down
            if (_showFab)
              Positioned(
                bottom: 90,
                right: 20,
                child: FloatingActionButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddSchedulePage(),
                      ),
                    );
                  },
                  backgroundColor: Colors.white,
                  child: Icon(Icons.add, color: Colors.black, size: 30),
                  elevation: 4,
                ),
              ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildDayItem(String day, int date, bool isSelected) {
    return Column(
      children: [
        Text(
          day,
          style: TextStyle(
            fontSize: 12,
            color: isSelected ? Colors.blue : Colors.grey[600],
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        SizedBox(height: 8),
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: isSelected ? Colors.blue : Colors.transparent,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              date.toString(),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : Colors.black,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimeSlot(String time, Widget? classCard) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 0, bottom: 12),
            child: Text(
              time,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
          ),
          classCard ??
              Container(
                padding: EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    "No classes scheduled",
                    style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                  ),
                ),
              ),
        ],
      ),
    );
  }

  Widget _buildClassCard({
    required String title,
    required String instructor,
    required String location,
    required String time,
    required String tag,
    String? note,
  }) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
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
                    color: Colors.black,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  tag,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            instructor,
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
          SizedBox(height: 4),
          Text(
            "$location  •  $time",
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
          if (note != null) ...[
            SizedBox(height: 12),
            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, size: 16, color: Colors.blue[700]),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      note,
                      style: TextStyle(fontSize: 13, color: Colors.blue[900]),
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

  Widget _buildBottomNavBar() {
    return Container(
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
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(Icons.home_outlined, "Home", false),
              _buildNavItem(Icons.calendar_today, "Schedule", true),
              _buildNavItem(Icons.notifications_outlined, "Alerts", false),
              _buildNavItem(Icons.cloud_outlined, "Weather", false),
              _buildNavItem(Icons.settings_outlined, "Settings", false),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, bool isActive) {
    return Expanded(
      child: InkWell(
        onTap: () {
          if (label == "Alerts" && !isActive) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => AlertsPage()),
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
