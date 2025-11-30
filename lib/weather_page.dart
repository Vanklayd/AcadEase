import 'package:flutter/material.dart';
import 'package:appdev_project/main.dart';
import 'package:appdev_project/schedule_page.dart';
import 'package:appdev_project/alerts_page.dart';
import 'package:weather/weather.dart';
import 'settings_page.dart';
import 'package:intl/intl.dart';

class WeatherPage extends StatefulWidget {
  const WeatherPage({super.key});

  @override
  State<WeatherPage> createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> {
  final WeatherFactory _wf = WeatherFactory("ffce7850163c676d026a180b54c809a8");
  Weather? _weather;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchWeather();
  }

  Future<void> _fetchWeather() async {
    try {
      // Fetch weather for Manila, Philippines
      Weather weather = await _wf.currentWeatherByCityName("Manila");
      setState(() {
        _weather = weather;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      debugPrint("Error fetching weather: $e");
    }
  }

  String _formatTime(DateTime dateTime) {
    return DateFormat('hh:mm a').format(dateTime);
  }

  // Removed unused _formatDate helper to clean warnings.

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
                    DateFormat('h:mm').format(DateTime.now()),
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
                'Weather',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: onSurface,
                ),
              ),
            ),
            // Divider
            Container(height: 1, color: theme.dividerColor),
            Expanded(
              child: _isLoading
                  ? Center(child: CircularProgressIndicator(color: onSurface))
                  : SingleChildScrollView(
                      padding: EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Date and Temperature
                          Container(
                            padding: EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: theme.cardColor, // themed card
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isDark ? Colors.white10 : Colors.black12,
                              ),
                              boxShadow: isDark
                                  ? []
                                  : [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.06),
                                        blurRadius: 12,
                                        offset: Offset(0, 4),
                                      ),
                                    ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      DateFormat(
                                        'EEEE,',
                                      ).format(DateTime.now()),
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                        color: onSurface,
                                      ),
                                    ),
                                    Text(
                                      DateFormat(
                                        'MMMM d',
                                      ).format(DateTime.now()),
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                        color: onSurface,
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      DateFormat(
                                        'hh:mm a',
                                      ).format(DateTime.now()),
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: onSurface.withOpacity(0.6),
                                      ),
                                    ),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      _weather != null
                                          ? '${_weather!.temperature!.celsius!.toStringAsFixed(0)}°C'
                                          : '-- °C',
                                      style: TextStyle(
                                        fontSize: 48,
                                        fontWeight: FontWeight.w700,
                                        color: onSurface,
                                      ),
                                    ),
                                    Text(
                                      _weather != null
                                          ? '${_weather!.temperature!.fahrenheit!.toStringAsFixed(0)}°F'
                                          : '-- °F',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: onSurface.withOpacity(0.6),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 24),
                          // Location placeholder box with PH map background
                          Container(
                            height: 400,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isDark
                                    ? Colors.white10
                                    : Colors.grey[300]!,
                              ),
                              image: DecorationImage(
                                image: AssetImage('assets/images/phmap.jpg'),
                                fit: BoxFit.cover,
                                alignment: Alignment(0.6, -0.2),
                              ),
                            ),
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color: (isDark ? Colors.black : Colors.white)
                                    .withOpacity(
                                      isDark ? 0.55 : 0.65,
                                    ), // themed overlay
                              ),
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.location_on,
                                      size: 48,
                                      color: Color(0xFF03A9F4),
                                    ),
                                    SizedBox(height: 16),
                                    Text(
                                      _weather?.areaName ?? 'Manila',
                                      style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.w600,
                                        color: onSurface,
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      _weather?.country ?? 'Philippines',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: onSurface.withOpacity(0.7),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 24),
                          // Today's Forecast
                          Text(
                            "Today's Forecast",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: onSurface,
                            ),
                          ),
                          SizedBox(height: 16),
                          _buildForecastRow(
                            'Temperature',
                            _weather != null
                                ? '${_weather!.temperature!.celsius!.toStringAsFixed(0)}°C / ${_weather!.temperature!.fahrenheit!.toStringAsFixed(0)}°F'
                                : '-- °C / -- °F',
                          ),
                          SizedBox(height: 12),
                          _buildForecastRow(
                            'Humidity',
                            _weather != null ? '${_weather!.humidity}%' : '--%',
                          ),
                          SizedBox(height: 12),
                          _buildForecastRow(
                            'Wind',
                            _weather != null
                                ? '${_weather!.windSpeed!.toStringAsFixed(1)} km/h'
                                : '-- km/h',
                          ),
                          SizedBox(height: 12),
                          _buildForecastRow(
                            'Conditions',
                            _weather?.weatherDescription ?? 'Unknown',
                          ),
                          SizedBox(height: 24),
                          // Sunrise and Sunset
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  padding: EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    color: theme.cardColor,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: isDark
                                          ? Colors.white10
                                          : Colors.black12,
                                    ),
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
                                        _weather?.sunrise != null
                                            ? _formatTime(_weather!.sunrise!)
                                            : '--:-- --',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: onSurface,
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        'Sunrise',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: onSurface.withOpacity(0.6),
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
                                    color: theme.cardColor,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: isDark
                                          ? Colors.white10
                                          : Colors.black12,
                                    ),
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
                                        _weather?.sunset != null
                                            ? _formatTime(_weather!.sunset!)
                                            : '--:-- --',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: onSurface,
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        'Sunset',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: onSurface.withOpacity(0.6),
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
    final onSurface = Theme.of(context).colorScheme.onSurface;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 16, color: onSurface.withOpacity(0.7)),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: onSurface,
          ),
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
    final onSurface = Theme.of(context).colorScheme.onSurface;
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
