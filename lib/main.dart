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
      apiKey: 'AIzaSyC_4NXebFUtXUCB3GDwlen3joeQ3ev357Q',
      appId: '1:797587856663:android:1324c1073e3decf508ab52',
      messagingSenderId: '797587856663',
      projectId: 'blooapp-25ad6',
      storageBucket: 'blooapp-25ad6.appspot.com',
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