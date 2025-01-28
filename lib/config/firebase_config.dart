import 'package:firebase_core/firebase_core.dart';

class FirebaseConfig {
  static const FirebaseOptions webOptions = FirebaseOptions(
    apiKey: "AIzaSyDnGMwJYzsOp4_7WxC8CiN0Y4XBk-gNomc",
    authDomain: "br-sma.firebaseapp.com",
    projectId: "br-sma",
    storageBucket: "br-sma.appspot.com",
    messagingSenderId: "787190721610",
    appId: "1:787190721610:web:57921c0bf2523985274ab3",
    measurementId: "G-1MV3HFZN78"
  );

  static Future<void> initializeFirebase() async {
    await Firebase.initializeApp(options: webOptions);
  }
}
