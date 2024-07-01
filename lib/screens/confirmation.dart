import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter/services.dart';

class Confirmation extends StatefulWidget {
  const Confirmation({super.key});

  @override
  State<Confirmation> createState() => _ConfirmationState();
}

class _ConfirmationState extends State<Confirmation> {

  late var arguments;
  late String imagePath;
  late var value;

   @override
  Widget build(BuildContext context) {
    arguments = ModalRoute.of(context)!.settings.arguments as Map;
    imagePath = arguments['imagePath'];
    value = arguments['value'];
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.black,
        statusBarIconBrightness: Brightness.light,
      ),
    );
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: <Widget>[
            displayImage(context),
            confirmButton(),
            retakeButton()
          ],
        ) 
      ),
    );
  }

  Widget displayImage(context) {
    var camera = value;
    final size = MediaQuery.of(context).size;
    var scale = size.aspectRatio * camera.aspectRatio;

    if (scale < 1) scale = 1 / scale;

    return ClipRRect(
      borderRadius: BorderRadius.circular(25.0), // Adjust the radius as needed
      child: Transform.scale(
        scale: scale,
        child: Center(
          child: Image.file(File(imagePath)),
        ),
      ),
    );
  }

  Widget confirmButton() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.all(30.0),
        child: GestureDetector(
          onTap: () {Navigator.pushReplacementNamed(context, '/information', arguments: imagePath);},
          child: Container(
            width: 80.0,
            height: 80.0,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 4.0),
              color: Colors.white,
            ),
            child: Center(
              child: Icon(
                Icons.check, // The correct icon
                color: Colors.black, // Color of the icon
                size: 50.0, // Size of the icon
              ),
            ),
          )
        )
      ),
    );
  }

  Widget retakeButton() {
    return Positioned(
      top :0,
      left: 0,
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: GestureDetector(
          onTap:(){Navigator.pushReplacementNamed(context, '/recycle');},
          child: Center(
            child: Icon(
              Icons.close, 
              color: Colors.white, // Color of the icon
              size: 35.0, // Size of the icon
            ),
          ),
        )
      ),
    );
  }
}
