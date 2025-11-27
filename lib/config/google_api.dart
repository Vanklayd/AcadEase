// Put your Google API key here. This key must have Maps JavaScript SDK (for web),
// Maps SDK for Android/iOS, and Directions API enabled in Google Cloud Console.
class GoogleApi {
  // The API key is provided at build/run time via `--dart-define=GOOGLE_MAPS_API_KEY=...`.
  // Do NOT commit your API key into source control. If a key was already pushed,
  // rotate/revoke it in Google Cloud Console immediately.
  static const String apiKey = String.fromEnvironment(
    'GOOGLE_MAPS_API_KEY',
    defaultValue: '',
  );
}
