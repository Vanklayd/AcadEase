import 'package:flutter/material.dart';
import 'package:appdev_project/main.dart';
import 'package:appdev_project/alerts_page.dart';
import 'package:appdev_project/weather_page.dart';

class SchedulePage extends StatefulWidget {
  const SchedulePage({super.key});

  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  int selectedDay = 7; // Tuesday is selected (7th)
  ScrollController _scrollController = ScrollController();
  bool _showFab = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
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
                            "9:41",
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
                      Icon(Icons.chevron_left, color: Colors.grey[600]),
                      _buildDayItem("Sun", 5, false),
                      _buildDayItem("Mon", 6, false),
                      _buildDayItem("Tue", 7, true),
                      _buildDayItem("Wed", 8, false),
                      _buildDayItem("Thu", 9, false),
                      Icon(Icons.chevron_right, color: Colors.grey[600]),
                    ],
                  ),
                ),

                // Divider
                Divider(color: Colors.grey[300], thickness: 1, height: 1),

                // Schedule List
                Expanded(
                  child: ListView(
                    controller: _scrollController,
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    children: [
                      // 8:00 AM
                      _buildTimeSlot("8:00 AM", null),

                      // 9:00 AM - Operating Systems
                      _buildTimeSlot(
                        "9:00 AM",
                        _buildClassCard(
                          title: "Operating Systems",
                          instructor: "Prof. J. Cruz",
                          location: "CS Lab 201",
                          time: "9:00 AM - 10:30 AM",
                          tag: "Weekly",
                          note: "Heavy rain expected, bring umbrella!",
                        ),
                      ),

                      // 10:00 AM
                      _buildTimeSlot("10:00 AM", null),

                      // 11:00 AM - Discrete Mathematics
                      _buildTimeSlot(
                        "11:00 AM",
                        _buildClassCard(
                          title: "Discrete Mathematics",
                          instructor: "Dr. M. Garcia",
                          location: "Rm 305",
                          time: "11:00 AM - 12:00 PM",
                          tag: "Weekly",
                          note: null,
                        ),
                      ),

                      // 12:00 PM
                      _buildTimeSlot("12:00 PM", null),

                      // 1:00 PM
                      _buildTimeSlot("1:00 PM", null),

                      // 2:00 PM - Data Structures
                      _buildTimeSlot(
                        "2:00 PM",
                        _buildClassCard(
                          title: "Data Structures",
                          instructor: "Engr. R. Santos",
                          location: "Lecture Hall 1",
                          time: "2:00 PM - 3:30 PM",
                          tag: "MWF",
                          note: null,
                        ),
                      ),

                      // 3:00 PM
                      _buildTimeSlot("3:00 PM", null),

                      // 4:00 PM
                      _buildTimeSlot("4:00 PM", null),

                      // 5:00 PM
                      _buildTimeSlot("5:00 PM", null),

                      // 6:00 PM
                      _buildTimeSlot("6:00 PM", null),

                      // 7:00 PM
                      _buildTimeSlot("7:00 PM", null),

                      // 8:00 PM
                      _buildTimeSlot("8:00 PM", null),
                    ],
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
                  onPressed: () {},
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
