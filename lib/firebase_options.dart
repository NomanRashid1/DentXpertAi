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
        return windows;
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
    apiKey: 'AIzaSyChKzD8M7cNMtI7l63EdgF3zQaqULKcJ2Q',
    appId: '1:278613351640:web:07557ebbe4af78dde00bad',
    messagingSenderId: '278613351640',
    projectId: 'dentxpert-e90d4',
    authDomain: 'dentxpert-e90d4.firebaseapp.com',
    storageBucket: 'dentxpert-e90d4.firebasestorage.app',
    measurementId: 'G-70WKY4T41S',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCoeZK_7hoXDcs8kcCOznq2N96GauWsZww',
    appId: '1:278613351640:android:09734351300ac82ae00bad',
    messagingSenderId: '278613351640',
    projectId: 'dentxpert-e90d4',
    storageBucket: 'dentxpert-e90d4.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAIxQsMKyvMoQu_uck3bZEs_SRA5kNlQWU',
    appId: '1:278613351640:ios:9b03d3c832ab167be00bad',
    messagingSenderId: '278613351640',
    projectId: 'dentxpert-e90d4',
    storageBucket: 'dentxpert-e90d4.firebasestorage.app',
    iosBundleId: 'com.example.dentxxpertAi',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyAIxQsMKyvMoQu_uck3bZEs_SRA5kNlQWU',
    appId: '1:278613351640:ios:9b03d3c832ab167be00bad',
    messagingSenderId: '278613351640',
    projectId: 'dentxpert-e90d4',
    storageBucket: 'dentxpert-e90d4.firebasestorage.app',
    iosBundleId: 'com.example.dentxxpertAi',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyChKzD8M7cNMtI7l63EdgF3zQaqULKcJ2Q',
    appId: '1:278613351640:web:4318f1b8f4b34f04e00bad',
    messagingSenderId: '278613351640',
    projectId: 'dentxpert-e90d4',
    authDomain: 'dentxpert-e90d4.firebaseapp.com',
    storageBucket: 'dentxpert-e90d4.firebasestorage.app',
    measurementId: 'G-VCB4EC107B',
  );
}
