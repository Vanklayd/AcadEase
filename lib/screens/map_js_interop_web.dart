// Web implementation: use Maps JS DirectionsService via JS interop.
import 'dart:async';
import 'dart:html' as html;
import 'dart:js' as js;
import 'dart:js_util' as js_util;
import 'package:google_maps_flutter/google_maps_flutter.dart';

Future<Map<String, dynamic>> getDirectionsViaJs(
  LatLng origin,
  LatLng destination,
) {
  final completer = Completer<Map<String, dynamic>>();
  try {
    final google = js_util.getProperty(html.window, 'google');
    if (google == null) {
      completer.completeError(Exception('window.google is not available'));
      return completer.future;
    }
    final maps = js_util.getProperty(google, 'maps');
    final DirectionsService = js_util.getProperty(maps, 'DirectionsService');
    final service = js_util.callConstructor(DirectionsService, []);

    final travelModeObj = js_util.getProperty(maps, 'TravelMode');
    final drivingMode = js_util.getProperty(travelModeObj, 'DRIVING');

    // Create a JS Date object (new Date()) to request traffic-aware durations
    final DateCtor = js_util.getProperty(html.window, 'Date');
    final dateObj = js_util.callConstructor(DateCtor, []);

    final request = js_util.jsify({
      'origin': {'lat': origin.latitude, 'lng': origin.longitude},
      'destination': {
        'lat': destination.latitude,
        'lng': destination.longitude,
      },
      'travelMode': drivingMode,
      // departureTime must be inside drivingOptions for DirectionsService
      'drivingOptions': js_util.jsify({
        'departureTime': dateObj,
        'trafficModel': 'bestguess',
      }),
    });

    void callback(result, status) {
      try {
        final statusStr =
            js_util.callMethod(status, 'toString', []) as String? ??
            status.toString();
        // Convert minimal useful fields to a Dart map so map_page can reuse parsing logic.
        if (statusStr != 'OK') {
          completer.complete({'status': statusStr, 'error_message': ''});
          return;
        }
        final routes = js_util.getProperty(result, 'routes');
        final firstRoute = js_util.getProperty(routes, 0);

        // Safely extract overview polyline 'points' as a String (or empty string)
        String overview = '';
        try {
          final overviewObj = js_util.getProperty(
            firstRoute,
            'overview_polyline',
          );
          final pts = overviewObj == null
              ? null
              : js_util.getProperty(overviewObj, 'points');
          overview = pts == null ? '' : (pts as String);
        } catch (_) {
          overview = '';
        }

        // Safely extract durations
        int duration = 0;
        int? durationInTraffic;
        try {
          final legs = js_util.getProperty(firstRoute, 'legs');
          final firstLeg = legs == null ? null : js_util.getProperty(legs, 0);
          if (firstLeg != null) {
            final durObj = js_util.getProperty(firstLeg, 'duration');
            final durVal = durObj == null
                ? null
                : js_util.getProperty(durObj, 'value');
            duration = durVal == null ? 0 : (durVal as num).toInt();

            final durationInTrafficProp = js_util.getProperty(
              firstLeg,
              'duration_in_traffic',
            );
            if (durationInTrafficProp != null) {
              final dit = js_util.getProperty(durationInTrafficProp, 'value');
              durationInTraffic = dit == null ? null : (dit as num).toInt();
            }
          }
        } catch (_) {
          duration = 0;
          durationInTraffic = null;
        }

        // Build a Dart map similar to the REST response minimal fields used by map_page
        final map = <String, dynamic>{
          'status': 'OK',
          'routes': [
            {
              'overview_polyline': {'points': overview},
              'legs': [
                {
                  'duration': {'value': duration},
                  'duration_in_traffic': durationInTraffic == null
                      ? null
                      : {'value': durationInTraffic},
                },
              ],
            },
          ],
        };
        completer.complete(map);
      } catch (e) {
        completer.completeError(e);
      }
    }

    // Use allowInterop so JS can call the Dart function
    js.context.callMethod('setTimeout', [js.allowInterop(() {}), 0]);
    js_util.callMethod(service, 'route', [request, js.allowInterop(callback)]);
  } catch (e) {
    completer.completeError(e);
  }

  return completer.future;
}
