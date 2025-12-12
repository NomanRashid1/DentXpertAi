// File: lib/firebase_options.dart (dentxpert project mein replace karen)

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
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
      case TargetPlatform.windows:
      // Android keys ko Web/Windows ke liye istemaal karna theek nahi hai,
      // lekin aapke paas Web keys nahi hain, isliye Android keys hi use kar rahe hain
        return android;
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

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBePW0mOV3-CJAe80BUGNkCJa6ip0luWoU',
    appId: '1:29614196880:android:2e4e6825677a68e21a7015',
    messagingSenderId: '29614196880',
    projectId: 'tomato-disease-app',
    storageBucket: 'tomato-disease-app.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBePW0mOV3-CJAe80BUGNkCJa6ip0luWoU',
    appId: '1:29614196880:ios:9b03d3c832ab167be00bad',
    messagingSenderId: '29614196880',
    projectId: 'tomato-disease-app',
    storageBucket: 'tomato-disease-app.appspot.com',
    iosBundleId: 'com.example.dentxxpertAi',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBePW0mOV3-CJAe80BUGNkCJa6ip0luWoU',
    appId: '1:29614196880:web:075577ebbe4af78dde00bad',
    messagingSenderId: '29614196880',
    projectId: 'tomato-disease-app',
    authDomain: 'tomato-disease-app.firebaseapp.com',
    storageBucket: 'tomato-disease-app.appspot.com',
    measurementId: 'G-70WKY4T41S',
  );

// macos/windows ko ab android ki keys istemaal karni chahiye (jaisa ke currentPlatform mein set kiya hai).
}