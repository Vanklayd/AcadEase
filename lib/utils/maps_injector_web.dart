import 'dart:async';
import 'dart:html' as html;

Future<void> injectMapsScript(String apiKey) async {
  if (apiKey.isEmpty) return;
  // Avoid injecting twice
  try {
    // `html.window` is always available in browser context; remove unnecessary null check
    final head = html.document.head;
    if (head == null) return;
    final script = html.ScriptElement()
      ..src =
          'https://maps.googleapis.com/maps/api/js?key=$apiKey&libraries=places'
      ..async = false;
    head.append(script);
    final completer = Completer<void>();
    script.onLoad.first.then((_) => completer.complete());
    script.onError.first.then((_) => completer.complete());
    return completer.future;
  } catch (_) {
    return;
  }
}
