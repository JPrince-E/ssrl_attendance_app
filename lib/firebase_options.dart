// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
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
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyB20ATSn2dPC0uzBxRWMS9gTUbDYfVWLn8',
    appId: '1:178151117059:web:fb6fe8acf63970802ed936',
    messagingSenderId: '178151117059',
    projectId: 'ssrl-app',
    authDomain: 'ssrl-app.firebaseapp.com',
    storageBucket: 'ssrl-app.appspot.com',
    measurementId: 'G-ZE2BPJ4BPZ',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAKdNrNVOYvXpK_RfvlD3YCr1SBP6dfiJw',
    appId: '1:178151117059:android:66bb61ce4694bcc62ed936',
    messagingSenderId: '178151117059',
    projectId: 'ssrl-app',
    storageBucket: 'ssrl-app.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCBA3WmroYcdR9Kcb5GBWEZ5yFFRsGwHPQ',
    appId: '1:178151117059:ios:cbfa9c0d45d9983e2ed936',
    messagingSenderId: '178151117059',
    projectId: 'ssrl-app',
    storageBucket: 'ssrl-app.appspot.com',
    iosBundleId: 'com.example.ssrlAttendanceApp',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCBA3WmroYcdR9Kcb5GBWEZ5yFFRsGwHPQ',
    appId: '1:178151117059:ios:fabf04a86cff874d2ed936',
    messagingSenderId: '178151117059',
    projectId: 'ssrl-app',
    storageBucket: 'ssrl-app.appspot.com',
    iosBundleId: 'com.example.ssrlAttendanceApp.RunnerTests',
  );
}