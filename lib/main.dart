import 'package:bloo_app/firebase_options.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:bloo_app/screens/home.dart';
import 'package:bloo_app/screens/recycle.dart';
import 'package:bloo_app/screens/confirmation.dart';
import 'package:bloo_app/screens/information.dart';
import 'package:bloo_app/screens/feedbacks.dart';
import 'package:firebase_core/firebase_core.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    name: 'bloo-app',
    options: FirebaseOptions(
      apiKey: "AIzaSyCU2dyuAwjCOmB2om_icyq5ZcGMmcQqgGk",
      authDomain: "recyclesg-2a357.firebaseapp.com",
      databaseURL: "https://recyclesg-2a357-default-rtdb.asia-southeast1.firebasedatabase.app",
      projectId: "recyclesg-2a357",
      storageBucket: "recyclesg-2a357.appspot.com",
      messagingSenderId: "375069917976",
      appId: "1:375069917976:web:c02006b142a8be8a94946d"
    ),
  );
  final cameras = await availableCameras();
  final firstCamera = cameras.first;

  runApp(MaterialApp(
      initialRoute: '/',
      routes: {
        '/': (context) => const Home(),
        '/recycle': (context) => Recycle(camera: firstCamera),
        '/confirmation': (context) => const Confirmation(),
        '/information': (context) => const Information(),
        '/feedbacks': (context) => const Feedbacks(),
      }
  ));
}