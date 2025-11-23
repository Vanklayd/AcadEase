import 'package:flutter/material.dart';
import 'package:appdev_project/main.dart';
import 'package:appdev_project/schedule_page.dart';
import 'package:appdev_project/alerts_page.dart';

class WeatherPage extends StatefulWidget {
  const WeatherPage({super.key});

  @override
  State<WeatherPage> createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> {
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
                'Weather',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              ),
            ),
            // Divider
            Container(height: 1, color: Colors.grey[300]),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Date and Temperature
                    Container(
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Friday,',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                'December 1',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                '09:41 AM',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '28°C',
                                style: TextStyle(
                                  fontSize: 48,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                '82°F',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 24),
                    // Philippines Map
                    Container(
                      height: 400,
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Stack(
                        children: [
                          Center(
                            child: CustomPaint(
                              size: Size(300, 400),
                              painter: PhilippinesMapPainter(),
                            ),
                          ),
                          Positioned(
                            left: 160,
                            top: 180,
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: Color(0xFF03A9F4),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 3,
                                ),
                              ),
                              child: Icon(
                                Icons.location_on,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 24),
                    // Today's Forecast
                    Text(
                      "Today's Forecast",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 16),
                    _buildForecastRow('Temperature', '28°C / 82°F'),
                    SizedBox(height: 12),
                    _buildForecastRow('Humidity', '75%'),
                    SizedBox(height: 12),
                    _buildForecastRow('Wind', '10 km/h NE'),
                    SizedBox(height: 12),
                    _buildForecastRow('Conditions', 'Partly Cloudy'),
                    SizedBox(height: 24),
                    // Sunrise and Sunset
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.grey[50],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.wb_sunny_outlined,
                                  color: Color(0xFFFFB300),
                                  size: 40,
                                ),
                                SizedBox(height: 12),
                                Text(
                                  '06:05 AM',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Sunrise',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: Container(
                            padding: EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.grey[50],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.nightlight_round_outlined,
                                  color: Color(0xFF1976D2),
                                  size: 40,
                                ),
                                SizedBox(height: 12),
                                Text(
                                  '05:38 PM',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Sunset',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
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
                        false,
                      ),
                      _buildNavItem(
                        context,
                        Icons.cloud_outlined,
                        "Weather",
                        true,
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

  Widget _buildForecastRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: 16, color: Colors.grey[700])),
        Text(
          value,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ],
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

class PhilippinesMapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey[400]!
      ..style = PaintingStyle.fill;

    final dotPaint = Paint()
      ..color = Colors.grey[400]!
      ..style = PaintingStyle.fill;

    // Draw Philippines map using dots
    final path = Path();

    // Northern Luzon
    for (double x = 130; x < 160; x += 4) {
      for (double y = 20; y < 100; y += 4) {
        if (_isInNorthernLuzon(x, y)) {
          canvas.drawCircle(Offset(x, y), 1.5, dotPaint);
        }
      }
    }

    // Central and Southern Luzon
    for (double x = 115; x < 175; x += 4) {
      for (double y = 100; y < 200; y += 4) {
        if (_isInCentralLuzon(x, y)) {
          canvas.drawCircle(Offset(x, y), 1.5, dotPaint);
        }
      }
    }

    // Visayas
    for (double x = 140; x < 220; x += 4) {
      for (double y = 200; y < 280; y += 4) {
        if (_isInVisayas(x, y)) {
          canvas.drawCircle(Offset(x, y), 1.5, dotPaint);
        }
      }
    }

    // Mindanao
    for (double x = 160; x < 240; x += 4) {
      for (double y = 280; y < 390; y += 4) {
        if (_isInMindanao(x, y)) {
          canvas.drawCircle(Offset(x, y), 1.5, dotPaint);
        }
      }
    }

    // Palawan
    for (double x = 40; x < 100; x += 4) {
      for (double y = 160; y < 360; y += 4) {
        if (_isInPalawan(x, y)) {
          canvas.drawCircle(Offset(x, y), 1.5, dotPaint);
        }
      }
    }
  }

  bool _isInNorthernLuzon(double x, double y) {
    return (x - 145).abs() < 15 && y < 100;
  }

  bool _isInCentralLuzon(double x, double y) {
    return (x - 145).abs() < 30 && y >= 100 && y < 200;
  }

  bool _isInVisayas(double x, double y) {
    return (x - 180).abs() < 40 && y >= 200 && y < 280;
  }

  bool _isInMindanao(double x, double y) {
    return (x - 200).abs() < 40 && y >= 280;
  }

  bool _isInPalawan(double x, double y) {
    double centerY = 260;
    double width = 15;
    return (x - 70).abs() < width && (y - centerY).abs() < 100;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
