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
    apiKey: 'AIzaSyAWceP1VxCOo7cgX9ld_JwbwhVO1VRpqd4',
    appId: '1:232380895558:web:5f5f5261333fa8d10ad547',
    messagingSenderId: '232380895558',
    projectId: 'cloi-d6e0b',
    authDomain: 'cloi-d6e0b.firebaseapp.com',
    storageBucket: 'cloi-d6e0b.appspot.com',
    measurementId: 'G-4SG4H217XM',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAveXg1LLwr6nV132-mC4K_HOv6yF-H2E8',
    appId: '1:232380895558:android:c7afc2a0b52cb9000ad547',
    messagingSenderId: '232380895558',
    projectId: 'cloi-d6e0b',
    storageBucket: 'cloi-d6e0b.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDlIw0iE2JGmibv51BEEZTewhUv-xK5Lgc',
    appId: '1:232380895558:ios:75eac7c6a42fa7df0ad547',
    messagingSenderId: '232380895558',
    projectId: 'cloi-d6e0b',
    storageBucket: 'cloi-d6e0b.appspot.com',
    androidClientId: '232380895558-mdr0mtknuq8od5m96sv0gpbpsgsmo1fu.apps.googleusercontent.com',
    iosClientId: '232380895558-7366ea5sd4p4hmgrmqqc722nc3dskarp.apps.googleusercontent.com',
    iosBundleId: 'com.example.cloi',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDlIw0iE2JGmibv51BEEZTewhUv-xK5Lgc',
    appId: '1:232380895558:ios:2fca3e6ea60ec52d0ad547',
    messagingSenderId: '232380895558',
    projectId: 'cloi-d6e0b',
    storageBucket: 'cloi-d6e0b.appspot.com',
    androidClientId: '232380895558-mdr0mtknuq8od5m96sv0gpbpsgsmo1fu.apps.googleusercontent.com',
    iosClientId: '232380895558-6uriq90552f6a3ob7d95v57gv9lot282.apps.googleusercontent.com',
    iosBundleId: 'com.example.cloi.RunnerTests',
  );
}