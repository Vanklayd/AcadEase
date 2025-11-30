import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'map_js_interop_stub.dart'
    if (dart.library.html) 'map_js_interop_web.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import '../config/google_api.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final Completer<GoogleMapController> _controller = Completer();
  CameraPosition? _initialPosition;
  Position? _currentPosition;
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};
  final List<String> _recommendations = [];
  String _debugInfo = '';
  // traffic summaries collected by _fetchAndDrawRoute
  final List<Map<String, dynamic>> _trafficSummaries = [];

  // Keep a reference to map controller
  dynamic
  _mapController; // replace with actual controller type (e.g., GoogleMapController)

  // Minimal dark style JSON (Google Maps)
  static const String _darkMapStyle = '''
  [
    {"elementType": "geometry","stylers": [{"color": "#212121"}]},
    {"elementType": "labels.icon","stylers": [{"visibility": "off"}]},
    {"elementType": "labels.text.fill","stylers": [{"color": "#757575"}]},
    {"elementType": "labels.text.stroke","stylers": [{"color": "#212121"}]},
    {"featureType": "road","elementType": "geometry","stylers": [{"color": "#383838"}]},
    {"featureType": "road","elementType": "labels.text.fill","stylers": [{"color": "#8a8a8a"}]},
    {"featureType": "poi.park","elementType": "geometry","stylers": [{"color": "#181818"}]},
    {"featureType": "water","elementType": "geometry","stylers": [{"color": "#000000"}]},
    {"featureType": "transit","stylers": [{"visibility": "off"}]}
  ]
  ''';

  void _applyMapTheme(BuildContext context) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    try {
      final controller = await _controller.future;
      await controller.setMapStyle(isDark ? _darkMapStyle : null);
    } catch (_) {}
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _applyMapTheme(context);
  }

  @override
  void initState() {
    super.initState();
    _determinePosition();
  }

  Future<void> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Location services are disabled.')),
      );
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location permissions are denied')),
        );
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Location permissions are permanently denied'),
        ),
      );
      return;
    }

    final pos = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.best,
    );
    if (!mounted) return;
    setState(() {
      _currentPosition = pos;
      _initialPosition = CameraPosition(
        target: LatLng(pos.latitude, pos.longitude),
        zoom: 14,
      );
      _markers.add(
        Marker(
          markerId: const MarkerId('me'),
          position: LatLng(pos.latitude, pos.longitude),
          infoWindow: const InfoWindow(title: 'You'),
        ),
      );
    });
  }

  Future<void> _analyzeNearbyRoutes() async {
    if (_currentPosition == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Current location unknown')));
      return;
    }

    setState(() {
      _polylines.clear();
      _recommendations.clear();
    });

    // For demo: create a few nearby sample destinations (offsets). In production you might
    // use Places API or Roads API to find nearby busy routes programmatically.
    final origin = LatLng(
      _currentPosition!.latitude,
      _currentPosition!.longitude,
    );
    final nearby = [
      LatLng(origin.latitude + 0.01, origin.longitude + 0.01),
      LatLng(origin.latitude + 0.015, origin.longitude - 0.008),
      LatLng(origin.latitude - 0.012, origin.longitude + 0.012),
    ];

    _trafficSummaries.clear();
    int id = 0;
    for (final dest in nearby) {
      id++;
      await _fetchAndDrawRoute(origin, dest, 'route_$id');
    }

    if (!mounted) return;
    if (_trafficSummaries.isEmpty) {
      _debugInfo =
          'No route data available. Try again or check API key and network.';
      setState(() {});
      return;
    }

    // Sort heavy -> moderate -> light
    _trafficSummaries.sort(
      (a, b) => (b['score'] as int).compareTo(a['score'] as int),
    );
    _recommendations.clear();
    for (final t in _trafficSummaries) {
      final lvl = t['level'] as String;
      final eta = t['etaText'] as String;
      final coord = t['coord'] as String;
      _recommendations.add('$lvl — $coord — $eta');
    }
    setState(() {});

    // Center on the worst (first) route and show its info window
    if (_trafficSummaries.isNotEmpty) {
      final first = _trafficSummaries.first;
      final lat = first['lat'] as double;
      final lng = first['lng'] as double;
      final mid = CameraPosition(target: LatLng(lat, lng), zoom: 14.5);
      final controller = await _controller.future;
      await controller.animateCamera(CameraUpdate.newCameraPosition(mid));
      try {
        await controller.showMarkerInfoWindow(
          MarkerId(first['markerId'] as String),
        );
      } catch (_) {
        // Some platforms or plugin versions may not support showing multiple info windows.
      }
    }
  }

  // Helper: reverse-geocode LatLng to a readable place/road name
  Future<String> _reverseGeocode(double lat, double lng) async {
    final apiKey = GoogleApi.apiKey;
    if (apiKey.isEmpty || apiKey.contains('YOUR_GOOGLE_API_KEY')) {
      return '(${lat.toStringAsFixed(3)}, ${lng.toStringAsFixed(3)})';
    }
    final uri = Uri.parse(
      'https://maps.googleapis.com/maps/api/geocode/json?latlng=$lat,$lng&key=$apiKey',
    );
    try {
      final res = await http.get(uri).timeout(const Duration(seconds: 8));
      if (res.statusCode != 200) {
        return '(${lat.toStringAsFixed(3)}, ${lng.toStringAsFixed(3)})';
      }
      final data = json.decode(res.body) as Map<String, dynamic>;
      final results = (data['results'] as List?) ?? [];
      if (results.isEmpty) {
        return '(${lat.toStringAsFixed(3)}, ${lng.toStringAsFixed(3)})';
      }
      // Prefer street/route type if available; else use formatted_address
      final first = results.first as Map<String, dynamic>;
      final formatted = (first['formatted_address'] as String?) ?? '';
      // Attempt to extract 'route' short name from address_components
      final comps = (first['address_components'] as List?) ?? [];
      final routeComp = comps.cast<Map<String, dynamic>?>().firstWhere(
        (c) => ((c?['types'] as List?) ?? []).contains('route'),
        orElse: () => null,
      );
      final routeName = routeComp?['short_name'] as String?;
      return routeName?.isNotEmpty == true
          ? routeName!
          : (formatted.isNotEmpty
                ? formatted
                : '(${lat.toStringAsFixed(3)}, ${lng.toStringAsFixed(3)})');
    } catch (_) {
      return '(${lat.toStringAsFixed(3)}, ${lng.toStringAsFixed(3)})';
    }
  }

  Future<void> _fetchAndDrawRoute(
    LatLng origin,
    LatLng destination,
    String id,
  ) async {
    final apiKey = GoogleApi.apiKey;
    if (apiKey.isEmpty || apiKey.contains('YOUR_GOOGLE_API_KEY')) {
      // No API key provided - show helpful message and return
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Google API key missing - add it to lib/config/google_api.dart',
          ),
        ),
      );
      return;
    }

    final url = Uri.parse(
      'https://maps.googleapis.com/maps/api/directions/json?origin=${origin.latitude},${origin.longitude}&destination=${destination.latitude},${destination.longitude}&key=$apiKey&departure_time=now',
    );

    try {
      Map<String, dynamic> body;
      if (kIsWeb) {
        // Use Maps JS DirectionsService via interop to avoid CORS on web
        body = await getDirectionsViaJs(origin, destination);
      } else {
        final res = await http.get(url).timeout(const Duration(seconds: 10));
        // Log raw response for debugging
        debugPrint('Directions API response (${res.statusCode}): ${res.body}');
        if (res.statusCode != 200) {
          setState(() {
            _debugInfo = 'HTTP ${res.statusCode}';
          });
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Directions API returned ${res.statusCode}'),
            ),
          );
          return;
        }
        final parsed = json.decode(res.body) as Map<String, dynamic>;
        body = parsed;
      }
      final status = (body['status'] ?? 'NO_STATUS') as String;
      final errMsg = (body['error_message'] ?? '') as String;
      setState(() {
        _debugInfo =
            'status=$status; error_message=$errMsg; routes=${(body['routes'] as List?)?.length ?? 0}';
      });
      if (status != 'OK') {
        // Provide more helpful feedback: status and optional error_message
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Directions API status: $status — $errMsg')),
        );
        return;
      }
      final routes = (body['routes'] as List?);
      if (routes == null || routes.isEmpty) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No routes returned by Directions API')),
        );
        return;
      }
      final route = (body['routes'] as List).first as Map<String, dynamic>;
      final overview =
          (route['overview_polyline'] as Map<String, dynamic>)['points']
              as String;

      // Attempt to read duration and duration_in_traffic if present
      final legs = route['legs'] as List;
      int duration = 0;
      int durationInTraffic = 0;
      if (legs.isNotEmpty) {
        final leg = legs.first as Map<String, dynamic>;
        duration = (leg['duration']?['value'] ?? 0) as int;
        durationInTraffic =
            (leg['duration_in_traffic']?['value'] ?? duration) as int;
      }

      final points = PolylinePoints.decodePolyline(overview);
      final polylineCoordinates = points
          .map((p) => LatLng(p.latitude, p.longitude))
          .toList();

      // classify traffic level based on increase in travel time
      double ratio = duration == 0 ? 0.0 : durationInTraffic / duration;
      String level;
      int score; // heavy=3, moderate=2, light=1
      Color color;
      if (ratio > 1.4) {
        level = 'Heavy traffic';
        score = 3;
        color = Colors.red;
      } else if (ratio > 1.15) {
        level = 'Moderate traffic';
        score = 2;
        color = Colors.orange;
      } else {
        level = 'Light traffic';
        score = 1;
        color = Colors.green;
      }

      final polyId = PolylineId(id);
      final polyline = Polyline(
        polylineId: polyId,
        color: color,
        width: 6,
        points: polylineCoordinates,
      );

      final etaText =
          '${(durationInTraffic / 60).toStringAsFixed(0)} min (traffic)';
      final lat = destination.latitude;
      final lng = destination.longitude;
      final coord = '(${lat.toStringAsFixed(3)}, ${lng.toStringAsFixed(3)})';

      // Reverse-geocode to a place/road name
      final placeName = await _reverseGeocode(lat, lng);

      final markerId = MarkerId('dest_$id');
      setState(() {
        _polylines.add(polyline);
        _markers.add(
          Marker(
            markerId: markerId,
            position: destination,
            infoWindow: InfoWindow(
              title: level,
              snippet: '$placeName • $etaText',
            ),
          ),
        );
      });

      _trafficSummaries.add({
        'level': level,
        'score': score,
        'etaText': etaText,
        'coord': coord, // keep as fallback
        'place': placeName, // new: readable name
        'lat': lat,
        'lng': lng,
        'markerId': markerId.value,
      });
      if (mounted) setState(() {});
    } catch (e) {
      debugPrint('Error fetching directions: $e');
      if (!mounted) return;
      setState(() {
        _debugInfo = 'exception: ${e.toString()}';
      });
      // If running on web a CORS error may occur; guide the developer.
      // We avoid importing foundation here to keep the file simple; check at runtime via URL detection instead
      final msg = e.toString();
      if (msg.contains('XMLHttpRequest') ||
          msg.contains('CORS') ||
          msg.contains('Access-Control')) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Network/CORS error calling Directions API. On web you must add the Maps script tag to web/index.html and use a key with appropriate referrers, or proxy the Directions request through your server.',
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error fetching directions: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onSurface = theme.colorScheme.onSurface;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('Traffic Map')),
      body: _initialPosition == null
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                // Map with bottom padding so the draggable sheet doesn't completely cover controls
                Positioned.fill(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 120.0),
                    child: GoogleMap(
                      initialCameraPosition: _initialPosition!,
                      markers: _markers,
                      polylines: _polylines,
                      myLocationEnabled: true,
                      trafficEnabled: true,
                      onMapCreated: (controller) {
                        _controller.complete(controller);
                        _mapController = controller;
                        _applyMapTheme(context);
                      },
                    ),
                  ),
                ),

                // Small analyze button placed safely using top padding to avoid status bar overlap
                Positioned(
                  right: 12,
                  top: MediaQuery.of(context).padding.top + 12,
                  child: FloatingActionButton(
                    heroTag: 'analyze',
                    onPressed: _analyzeNearbyRoutes,
                    mini: true,
                    child: const Icon(Icons.traffic),
                  ),
                ),

                // Draggable recommendations sheet at the bottom. Initially small so it doesn't block the map.
                DraggableScrollableSheet(
                  initialChildSize: 0.12,
                  minChildSize: 0.08,
                  maxChildSize: 0.6,
                  builder: (context, scrollController) {
                    return ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(16),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          color: theme.canvasColor,
                          boxShadow: const [
                            BoxShadow(color: Colors.black26, blurRadius: 8),
                          ],
                        ),
                        child: SingleChildScrollView(
                          controller: scrollController, // critical for dragging
                          child: Column(
                            children: [
                              // Handle
                              Container(
                                width: 40,
                                height: 6,
                                margin: const EdgeInsets.symmetric(vertical: 8),
                                decoration: BoxDecoration(
                                  color: theme.dividerColor,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                              // Header actions
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12.0,
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'Nearby Traffic',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        setState(() {
                                          _recommendations.clear();
                                          _trafficSummaries.clear();
                                          _polylines.clear();
                                          _markers.removeWhere(
                                            (m) => m.markerId.value.startsWith(
                                              'dest_',
                                            ),
                                          );
                                        });
                                      },
                                      child: const Text('Clear'),
                                    ),
                                  ],
                                ),
                              ),
                              // Debug
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12.0,
                                  vertical: 4.0,
                                ),
                                child: Text(
                                  _debugInfo.isEmpty
                                      ? 'No debug info'
                                      : _debugInfo,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: onSurface.withOpacity(0.7),
                                  ),
                                ),
                              ),
                              // List content (or empty state)
                              if (_trafficSummaries.isEmpty)
                                const Padding(
                                  padding: EdgeInsets.all(16),
                                  child: Center(
                                    child: Text(
                                      'No traffic data yet. Tap the traffic icon to analyze.',
                                    ),
                                  ),
                                )
                              else
                                ..._trafficSummaries.map((t) {
                                  final level = t['level'] as String;
                                  final eta = t['etaText'] as String;
                                  final place =
                                      (t['place'] as String?) ??
                                      (t['coord'] as String);
                                  IconData icon;
                                  Color iconColor;
                                  if (level.startsWith('Heavy')) {
                                    icon = Icons.report;
                                    iconColor = Colors.red;
                                  } else if (level.startsWith('Moderate')) {
                                    icon = Icons.warning_amber_rounded;
                                    iconColor = Colors.orange;
                                  } else {
                                    icon = Icons.check_circle_outline;
                                    iconColor = Colors.green;
                                  }
                                  return ListTile(
                                    leading: Icon(icon, color: iconColor),
                                    title: Text('$level — $eta'),
                                    subtitle: Text(place),
                                    onTap: () async {
                                      final lat = t['lat'] as double;
                                      final lng = t['lng'] as double;
                                      final controller =
                                          await _controller.future;
                                      await controller.animateCamera(
                                        CameraUpdate.newLatLngZoom(
                                          LatLng(lat, lng),
                                          15.0,
                                        ),
                                      );
                                      try {
                                        await controller.showMarkerInfoWindow(
                                          MarkerId(t['markerId'] as String),
                                        );
                                      } catch (_) {}
                                    },
                                  );
                                }),
                              const SizedBox(height: 12),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
    );
  }
}
