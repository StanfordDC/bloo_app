import 'package:flutter/material.dart';
import 'dart:io';
import 'package:bloo_app/widgets/textDisplay.dart';

class Confirmation extends StatefulWidget {
  const Confirmation({super.key});

  @override
  State<Confirmation> createState() => _ConfirmationState();
}

class _ConfirmationState extends State<Confirmation> {

  late var arguments;
  late String imagePath;
  late double aspectRatio;

  @override
  Widget build(BuildContext context) {
    arguments = ModalRoute.of(context)!.settings.arguments as Map;
    imagePath = arguments['imagePath'];
    aspectRatio = arguments['aspectRatio'];
    return Scaffold(
      backgroundColor: Color.fromRGBO(241,253, 240,1),
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(241,253, 240,1),
        title:  TextDisplay(Colors.black, "Preview", 25.0),
        automaticallyImplyLeading: false,
        centerTitle: true,
      ),
      // The image is stored as a file on the device. Use the `Image.file`
      // constructor with the given path to display the image.
      body: Container(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                flex: 1,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(25.0), // Adjust the radius as needed
                  child: imagePreview(),
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  width: double.infinity,
                  height: 150.0,
                  child: Center(
                    child: buildRow()
                  )
                )
              ),
            // else
            //   const CircularProgressIndicator()
              ]
            )
          )
        )
      );
  }

  Widget imagePreview() {
    return AspectRatio(
      aspectRatio: aspectRatio,
      child: Image.file(File(imagePath),fit:BoxFit.cover)
    );
  }

  Column buildRow(){
    return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 5.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromRGBO(37,194,38,1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6.0), // Set the rounded corners
                    ),
                  ),
                  onPressed: (){Navigator.pushReplacementNamed(context, '/information', arguments: imagePath);},
                  child: const TextDisplay(Colors.white, "Confirm", 25.0)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 0.0),
            child: SizedBox( 
              width: double.infinity,
              child:  ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6.0),
                      side: BorderSide(color: Colors.black), // Set the rounded corners
                    ),
                  ),
                  onPressed: (){Navigator.pushReplacementNamed(context, '/recycle');},
                  child: const TextDisplay(Colors.black, "Retake", 25.0)),
            ),
          ),
        ]
    );
  }
}
