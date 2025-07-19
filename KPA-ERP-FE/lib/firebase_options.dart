// lib/firebase_options.dart

import 'package:firebase_core/firebase_core.dart';

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    return const FirebaseOptions(
      apiKey: 'dummy',
      appId: 'dummy',
      messagingSenderId: 'dummy',
      projectId: 'dummy',
    );
  }
}
