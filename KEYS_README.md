Hiding Google API keys

This project removes hardcoded Google API keys from source to avoid accidental commits.

How to provide keys locally

- Web and native (recommended): pass the key at build/run time using dart-define.

  flutter run -d chrome --dart-define=GOOGLE_MAPS_API_KEY=YOUR_KEY_HERE
  flutter build web --dart-define=GOOGLE_MAPS_API_KEY=YOUR_KEY_HERE
 flutter run -d chrome --dart-define=GOOGLE_MAPS_API_KEY=YOUR_KEY_HERE

  The app reads the key from `const String.fromEnvironment('GOOGLE_MAPS_API_KEY')` and
  injects the Maps JS library dynamically on web.

- Android alternative (not committed): create `android/app/src/main/res/values/google_maps_api.xml`
  with the following content and keep it out of version control:

  <?xml version="1.0" encoding="utf-8"?>
  <resources>
    <string name="google_maps_key">YOUR_ANDROID_KEY_HERE</string>
  </resources>

  Then update `AndroidManifest.xml` to reference `@string/google_maps_key` for the meta-data value.

Security notes

- Never commit API keys. If a key was pushed accidentally, rotate/revoke it in Google Cloud Console.
- Use project-level restrictions (HTTP referrers, Android package + SHA-1, iOS bundle id) in the Cloud Console.
- For CI, set environment variables/secrets and inject them to the build with `--dart-define`.

Local helper (web)

- The repo includes a small PowerShell helper `tools/inject_maps_key.ps1` (not yet added) that can copy
  a template to `web/index.html` and inject the key from the `GOOGLE_MAPS_API_KEY` environment variable.

  Example (PowerShell):
    $env:GOOGLE_MAPS_API_KEY = 'YOUR_KEY_HERE'
    .\tools\inject_maps_key.ps1

  This writes `web/index.html`. Do NOT commit the resulting `web/index.html` if it contains your key.
  Configure your CI to run the injector using the secure secret and then build.
