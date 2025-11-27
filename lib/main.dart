import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:appdev_project/schedule_page.dart';
import 'package:appdev_project/alerts_page.dart';
import 'package:appdev_project/weather_page.dart';
import 'screens/map_page.dart';
import 'screens/login_screen.dart';
import 'package:weather/weather.dart';
import 'package:intl/intl.dart';
import 'config/google_api.dart';
import 'utils/maps_injector.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase with generated platform-specific options
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // If a web Maps API key was provided at build/run time via dart-define,
  // inject the Maps JS library before bootstrapping the Flutter app.
  try {
    await injectMapsScript(GoogleApi.apiKey);
  } catch (_) {}

  final currentUser = FirebaseAuth.instance.currentUser;
  runApp(MyApp(isSignedIn: currentUser != null));
}

class MyApp extends StatelessWidget {
  final bool isSignedIn;
  const MyApp({super.key, this.isSignedIn = false});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: isSignedIn ? const AcadEaseHome() : const LoginScreen(),
    );
  }
}

class AcadEaseHome extends StatefulWidget {
  const AcadEaseHome({super.key});

  @override
  State<AcadEaseHome> createState() => _AcadEaseHomeState();
}

class _AcadEaseHomeState extends State<AcadEaseHome> {
  final WeatherFactory _wf = WeatherFactory("ffce7850163c676d026a180b54c809a8");
  Weather? _weather;
  bool _isLoadingWeather = true;
  String? _weatherError;

  @override
  void initState() {
    super.initState();
    _fetchWeather();
  }

  Future<void> _fetchWeather() async {
    try {
      Weather w = await _wf.currentWeatherByCityName("Manila");
      if (mounted) {
        setState(() {
          _weather = w;
          _isLoadingWeather = false;
        });
      }
    } catch (e) {
      debugPrint("Error fetching weather: $e");
      if (mounted) {
        setState(() {
          _isLoadingWeather = false;
          _weatherError = "Unable to fetch weather";
        });
      }
    }
  }

  String _getWeatherIcon() {
    if (_weather == null) return "🌤️";
    String? main = _weather!.weatherMain?.toLowerCase();
    if (main == null) return "🌤️";

    if (main.contains('cloud')) return "☁️";
    if (main.contains('rain')) return "🌧️";
    if (main.contains('clear')) return "☀️";
    if (main.contains('storm') || main.contains('thunder')) return "⛈️";
    if (main.contains('snow')) return "❄️";
    if (main.contains('mist') || main.contains('fog')) return "🌫️";
    return "🌤️";
  }

  // Sample subjects pool (same as schedule_page.dart)
  final List<Map<String, dynamic>> subjectPool = const [
    {
      'title': 'Operating Systems',
      'instructor': 'Prof. J. Cruz',
      'location': 'CS Lab 201',
    },
    {
      'title': 'Discrete Mathematics',
      'instructor': 'Dr. M. Garcia',
      'location': 'Rm 305',
    },
    {
      'title': 'Data Structures',
      'instructor': 'Engr. R. Santos',
      'location': 'Lecture Hall 1',
    },
    {
      'title': 'Web Development',
      'instructor': 'Prof. A. Reyes',
      'location': 'IT Lab 102',
    },
    {
      'title': 'Database Systems',
      'instructor': 'Dr. L. Torres',
      'location': 'Rm 210',
    },
    {
      'title': 'Computer Networks',
      'instructor': 'Engr. P. Mendoza',
      'location': 'CS Lab 203',
    },
    {
      'title': 'Software Engineering',
      'instructor': 'Prof. K. Villanueva',
      'location': 'Rm 401',
    },
    {
      'title': 'Mobile Development',
      'instructor': 'Dr. S. Castillo',
      'location': 'IT Lab 105',
    },
    {
      'title': 'Machine Learning',
      'instructor': 'Prof. D. Ramos',
      'location': 'AI Lab 301',
    },
    {
      'title': 'Artificial Intelligence',
      'instructor': 'Dr. R. Flores',
      'location': 'AI Lab 302',
    },
  ];

  final List<String> tags = const ['Weekly', 'MWF', 'TTH', 'Daily'];
  final List<String> types = const ['Lecture', 'Lab', 'Seminar', 'Workshop'];
  final List<String> times = const [
    '9:00 AM - 10:30 AM',
    '11:00 AM - 12:00 PM',
    '1:00 PM - 2:30 PM',
    '2:00 PM - 3:30 PM',
    '3:00 PM - 4:30 PM',
    '4:00 PM - 5:30 PM',
  ];

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
      int typeIndex = (seed + i * 11) % types.length;

      Map<String, dynamic> subject = subjectPool[subjectIndex];
      schedule.add({
        'timeSlot': timeSlotIndex,
        'title': subject['title'],
        'instructor': subject['instructor'],
        'location': subject['location'],
        'time': times[timeSlotIndex],
        'tag': tags[tagIndex],
        'type': types[typeIndex],
      });
    }

    // Sort by time slot
    schedule.sort((a, b) => a['timeSlot'].compareTo(b['timeSlot']));
    return schedule;
  }

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
                        GestureDetector(
                          onTap: _weatherError != null
                              ? () {
                                  setState(() {
                                    _isLoadingWeather = true;
                                    _weatherError = null;
                                  });
                                  _fetchWeather();
                                }
                              : null,
                          child: Container(
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
                            child: _isLoadingWeather
                                ? Center(
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(
                                        vertical: 20,
                                      ),
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                      ),
                                    ),
                                  )
                                : _weatherError != null
                                ? Padding(
                                    padding: EdgeInsets.symmetric(vertical: 10),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.cloud_off,
                                          color: Colors.white.withOpacity(0.9),
                                          size: 32,
                                        ),
                                        SizedBox(width: 16),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "Weather Unavailable",
                                              style: TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                              ),
                                            ),
                                            Text(
                                              "Tap to retry",
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.white.withOpacity(
                                                  0.8,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  )
                                : Row(
                                    children: [
                                      Text(
                                        _getWeatherIcon(),
                                        style: TextStyle(fontSize: 32),
                                      ),
                                      SizedBox(width: 16),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "${_weather!.temperature!.celsius!.round()}°C",
                                            style: TextStyle(
                                              fontSize: 32,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                          Text(
                                            _weather!.weatherDescription ??
                                                "N/A",
                                            style: TextStyle(
                                              fontSize: 20,
                                              color: Colors.white.withOpacity(
                                                0.9,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
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

                        // Today's Classes Header with Date
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Today's Classes",
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            Text(
                              DateFormat('MMM d, yyyy').format(DateTime.now()),
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 22),

                        // Today's Classes - Dynamic
                        ..._buildTodayClasses(),

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

  bool _isClassActive(String timeRange) {
    DateTime now = DateTime.now();
    try {
      // Parse start and end time from "9:00 AM - 10:30 AM"
      List<String> times = timeRange.split(' - ');
      String startTimeStr = times[0];
      String endTimeStr = times[1];

      DateTime startTime = DateFormat('h:mm a').parse(startTimeStr);
      DateTime endTime = DateFormat('h:mm a').parse(endTimeStr);

      // Combine with today's date
      DateTime classStart = DateTime(
        now.year,
        now.month,
        now.day,
        startTime.hour,
        startTime.minute,
      );
      DateTime classEnd = DateTime(
        now.year,
        now.month,
        now.day,
        endTime.hour,
        endTime.minute,
      );

      // Check if current time is within class time
      return now.isAfter(classStart) && now.isBefore(classEnd);
    } catch (e) {
      return false;
    }
  }

  List<Widget> _buildTodayClasses() {
    DateTime today = DateTime.now();
    List<Map<String, dynamic>> todaySchedule = _getScheduleForDay(today);

    List<Widget> classWidgets = [];
    bool hasActiveClass = false;

    for (int i = 0; i < todaySchedule.length; i++) {
      var classItem = todaySchedule[i];
      String fullTime = classItem['time'];

      // Parse time (e.g., "9:00 AM - 10:30 AM")
      String startTime = fullTime.split(' - ')[0];
      List<String> timeParts = startTime.split(' ');
      String time = timeParts[0];
      String period = timeParts[1];

      bool isActive = _isClassActive(fullTime);
      if (isActive) hasActiveClass = true;

      classWidgets.add(
        _buildClassCard(
          time: time,
          period: period,
          title: classItem['title'],
          instructor: '${classItem['instructor']} | ${classItem['location']}',
          type: classItem['type'],
          isActive: isActive,
        ),
      );

      if (i < todaySchedule.length - 1) {
        classWidgets.add(SizedBox(height: 12));
      }
    }

    // If no class is currently active, mark the next upcoming class
    if (!hasActiveClass && classWidgets.isNotEmpty) {
      DateTime now = DateTime.now();
      for (int i = 0; i < todaySchedule.length; i++) {
        var classItem = todaySchedule[i];
        String startTime = classItem['time'].split(' - ')[0];
        try {
          DateTime classStart = DateFormat('h:mm a').parse(startTime);
          DateTime classStartFull = DateTime(
            now.year,
            now.month,
            now.day,
            classStart.hour,
            classStart.minute,
          );

          if (now.isBefore(classStartFull)) {
            // Rebuild this class card as active
            List<String> timeParts = startTime.split(' ');
            classWidgets[i * 2] = _buildClassCard(
              time: timeParts[0],
              period: timeParts[1],
              title: classItem['title'],
              instructor:
                  '${classItem['instructor']} | ${classItem['location']}',
              type: classItem['type'],
              isActive: true,
            );
            break;
          }
        } catch (e) {
          // Continue to next
        }
      }
    }

    return classWidgets;
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
