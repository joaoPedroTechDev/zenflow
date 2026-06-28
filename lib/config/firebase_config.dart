import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

class FirebaseConfig {
  // ATENÇÃO: Insira suas chaves do Firebase aqui para sincronizar na nuvem!
  static const String apiKey = "AIzaSyDxLggGdiW99W8aNjeNm888Xv784eguJqU";
  static const String appId = "1:496872521176:web:1542636e6d00e3d3ee06ad";
  static const String messagingSenderId = "496872521176";
  static const String projectId = "zenflow-41134";
  static const String storageBucket = "zenflow-41134.firebasestorage.app";

  static bool get isConfigured {
    return apiKey.isNotEmpty &&
        appId.isNotEmpty &&
        projectId.isNotEmpty;
  }

  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return const FirebaseOptions(
        apiKey: apiKey,
        appId: appId,
        messagingSenderId: messagingSenderId,
        projectId: projectId,
        storageBucket: storageBucket,
        authDomain: "$projectId.firebaseapp.com",
      );
    }
    // Para Android e iOS, usamos a mesma inicialização manual baseada em chaves
    return const FirebaseOptions(
      apiKey: apiKey,
      appId: appId,
      messagingSenderId: messagingSenderId,
      projectId: projectId,
      storageBucket: storageBucket,
    );
  }
}
