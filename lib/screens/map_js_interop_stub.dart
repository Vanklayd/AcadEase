// Stub for non-web platforms — throws to indicate web-only functionality.
import 'package:google_maps_flutter/google_maps_flutter.dart';

Future<Map<String, dynamic>> getDirectionsViaJs(
  LatLng origin,
  LatLng destination,
) async {
  throw UnsupportedError('getDirectionsViaJs is only available on web.');
}
