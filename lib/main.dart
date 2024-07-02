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
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
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