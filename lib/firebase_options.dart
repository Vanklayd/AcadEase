// GENERATED CODE - manual
// Firebase configuration added from user-provided web config
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCUCFZBw7GreMd3RMAIehDuD8urQINhT2o',
    authDomain: 'acadease-d7921.firebaseapp.com',
    projectId: 'acadease-d7921',
    storageBucket: 'acadease-d7921.firebasestorage.app',
    messagingSenderId: '532841674348',
    appId: '1:532841674348:web:67a3cccd38e85c2d990a49',
    measurementId: 'G-QF9MKFSRB1',
  );

  // Placeholders for native platforms. Replace if you register native apps.
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCUCFZBw7GreMd3RMAIehDuD8urQINhT2o',
    appId: '1:532841674348:android:REPLACE_WITH_ANDROID_APP_ID',
    messagingSenderId: '532841674348',
    projectId: 'acadease-d7921',
    storageBucket: 'acadease-d7921.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCUCFZBw7GreMd3RMAIehDuD8urQINhT2o',
    appId: '1:532841674348:ios:REPLACE_WITH_IOS_APP_ID',
    messagingSenderId: '532841674348',
    projectId: 'acadease-d7921',
    storageBucket: 'acadease-d7921.firebasestorage.app',
    iosClientId: 'REPLACE_WITH_IOS_CLIENT_ID',
    iosBundleId: 'REPLACE_WITH_IOS_BUNDLE_ID',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCUCFZBw7GreMd3RMAIehDuD8urQINhT2o',
    appId: '1:532841674348:macos:REPLACE_WITH_MACOS_APP_ID',
    messagingSenderId: '532841674348',
    projectId: 'acadease-d7921',
    storageBucket: 'acadease-d7921.firebasestorage.app',
  );
}
