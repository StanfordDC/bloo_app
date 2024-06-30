import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:bloo_app/widgets/textDisplay.dart';
import 'package:bloo_app/models/wasteType.dart';

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
      appBar: AppBar(
        title:  TextDisplay(Colors.black, "Preview", 25.0),
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
                    backgroundColor: Color.fromARGB(255, 97, 199, 82),
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

  Column buildButtons(){
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 5.0),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
                onPressed: (){Navigator.pushReplacementNamed(context, '/information', arguments: wasteType);},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6.0), // Set the rounded corners
                  ),
                ),
                child: const TextDisplay(Colors.white, "Yes", 25.0)
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 5.0),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
                onPressed: (){Navigator.pushReplacementNamed(context, '/feedbacks');},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6.0), // Set the rounded corners
                  ),
                ),
                child: const TextDisplay(Colors.black, "No", 25.0)
            ),
          ),
        ),
      ]
    );
  }
}
