import 'package:appdev_project/schedule_page.dart';
import 'package:appdev_project/alerts_page.dart';
import 'package:appdev_project/weather_page.dart';
import 'package:flutter/material.dart';
import 'screens/map_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Center(
        child: Container(
          constraints: BoxConstraints(maxWidth: 480),
          child: AcadEaseHome(),
        ),
      ),
    );
  }
}

class AcadEaseHome extends StatelessWidget {
  const AcadEaseHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFFFFF),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                // Header with App Name
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20.0,
                    vertical: 16.0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(width: 40), // Spacer for centering
                      Text(
                        "AcadEase",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          fontStyle: FontStyle.italic,
                          color: Colors.black,
                          letterSpacing: 0.5,
                        ),
                      ),
                      Row(
                        children: [
                          Icon(
                            Icons.notifications_outlined,
                            size: 26,
                            color: Colors.black,
                          ),
                          SizedBox(width: 12),
                          CircleAvatar(
                            radius: 18,
                            backgroundColor: Colors.grey[400],
                            child: Icon(
                              Icons.person,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Divider line
                Divider(color: Colors.grey[300], thickness: 1, height: 1),

                // Main Content
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Weather Card
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Color(0xFF64B5F6), Color(0xFF42A5F5)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.cloud_outlined,
                                color: Colors.white.withOpacity(0.9),
                                size: 32,
                              ),
                              SizedBox(width: 16),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "21°C",
                                    style: TextStyle(
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Text(
                                    "Cloudy",
                                    style: TextStyle(
                                      fontSize: 20,
                                      color: Colors.white.withOpacity(0.9),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: 12),

                        // Prioritize Study Session Card
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Color(0xF3FAFCFF),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.06),
                                blurRadius: 12,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Prioritize Study Session",
                                    style: TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                  Container(
                                    padding: EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[100],
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(Icons.track_changes, size: 20),
                                  ),
                                ],
                              ),
                              SizedBox(height: 12),
                              Text(
                                "Your Math 101 midterm is next week. Plan for a 2-hour deep dive today.",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[700],
                                  height: 1.5,
                                ),
                              ),
                              SizedBox(height: 16),
                              // Progress Bar
                              ClipRRect(
                                borderRadius: BorderRadius.circular(6),
                                child: LinearProgressIndicator(
                                  value: 0.5,
                                  backgroundColor: Colors.grey[300],
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.black87,
                                  ),
                                  minHeight: 8,
                                ),
                              ),
                              SizedBox(height: 16),
                              Container(
                                width: double.infinity,
                                padding: EdgeInsets.symmetric(vertical: 14),
                                decoration: BoxDecoration(
                                  color: Color(0xFFE3F2FD),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Center(
                                  child: Text(
                                    "View Study Plan",
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF1976D2),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: 22),

                        // Today's Classes Header
                        Text(
                          "Today's Classes",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),

                        SizedBox(height: 22),

                        // Class 1 - Calculus I
                        _buildClassCard(
                          time: "10:00",
                          period: "AM",
                          title: "Calculus I (Math 101)",
                          instructor: "Prof. Garcia | Room 305",
                          type: "Lecture",
                          isActive: true,
                        ),

                        SizedBox(height: 12),

                        // Class 2 - Philippine History
                        _buildClassCard(
                          time: "01:30",
                          period: "PM",
                          title: "Philippine History",
                          instructor: "Dr. Santos | Auditorium B",
                          type: "Seminar",
                          isActive: false,
                        ),

                        SizedBox(height: 12),

                        // Class 3 - Introduction to Programming
                        _buildClassCard(
                          time: "03:00",
                          period: "PM",
                          title: "Introduction to Programming",
                          instructor: "Ms. Reyes | Computer Lab 1",
                          type: "Lab",
                          isActive: false,
                        ),

                        SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),

                // Bottom Navigation Bar
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
                          _buildNavItem(context, Icons.home, "Home", true),
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
                            false,
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
            // Right-side floating traffic icon (vertically centered)
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.only(right: 12.0),
                child: FloatingActionButton.small(
                  heroTag: 'traffic_map_fab',
                  tooltip: 'Open Traffic Map',
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  elevation: 4,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const MapPage()),
                    );
                  },
                  child: const Icon(Icons.traffic),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClassCard({
    required String time,
    required String period,
    required String title,
    required String instructor,
    required String type,
    required bool isActive,
  }) {
    return Container(
      padding: EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Color(0xffFFFFFF),
        border: Border.all(width: 0.1, color: Colors.grey),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          // Time Column
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                time,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              Text(
                period,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          SizedBox(width: 18),
          // Indicator Dot
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: isActive ? Colors.black : Colors.grey[400],
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 18),
          // Class Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  instructor,
                  style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                ),
                SizedBox(height: 10),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    type,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Colors.grey[800],
                    ),
                  ),
                ),
              ],
            ),
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
          } else if (label == "Alerts" && !isActive) {
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
