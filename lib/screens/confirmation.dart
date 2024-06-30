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

  late String imagePath;
  bool confirmed = false;
  String wasteType = "";
  List<WasteType> list = [];

  String convert(String imagePath){
    List<int> imageBytes = File(imagePath).readAsBytesSync();
    return base64Encode(imageBytes);
  }

  void getType(String base64) async {
    final startTime = DateTime.now();
    final response = await http.post(
      Uri.parse('https://blooapp-nakavwocwa-et.a.run.app/api/vision'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'base64_image': base64,
      }),
    );
    final endTime = DateTime.now();
    final duration = endTime.difference(startTime).inMilliseconds;

    print('Response time: $duration ms');
    if (response.statusCode == 200) {
      Map data = jsonDecode(response.body);
      setState(() {
        if(data['from_database'].length != 0){
          list.addAll((data['from_database'] as List).map((item) => WasteType.fromJson(item)).toList());
        }
        if(data['from_llm'].length != 0){
           list.addAll((data['from_llm'] as List).map((item) => WasteType.fromJson(item)).toList());
        }
        wasteType = list[0].item;
      });
    } else {
      throw Exception(response);
    }
  }

  @override
  Widget build(BuildContext context) {
    imagePath = ModalRoute.of(context)!.settings.arguments as String;
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(),
      // The image is stored as a file on the device. Use the `Image.file`
      // constructor with the given path to display the image.
      body: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
             Expanded(
              flex: 2,
              child: Image.file(File(imagePath),fit: BoxFit.cover,),
            ),
            if(!confirmed)
              buildRow()
            else if(confirmed && wasteType != "")
              buildColumn()
            else
              const CircularProgressIndicator()
              ]
            )
          )
        );
  }

  Column buildRow(){
    return Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 5.0),
            child: SizedBox(
              width: double.infinity,
              child:  ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black87,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6.0), // Set the rounded corners
                    ),
                  ),
                  onPressed: (){Navigator.pushReplacementNamed(context, '/recycle');},
                  child: const TextDisplay(Colors.white, "Retake", 25.0)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 5.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6.0), // Set the rounded corners
                    ),
                  ),
                  onPressed: (){ setState(() {
                    confirmed = true;
                    String base64 = convert(imagePath);
                    getType(base64);
                  });},
                  child: const TextDisplay(Colors.black, "Confirm", 25.0)),
            ),
          ),
        ]
    );
  }

  Column buildColumn(){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget> [
        TextContainer(TextDisplay(Colors.black, "Detected: $wasteType", 25.0)),
        TextContainer(TextDisplay(Colors.black, "Is this a $wasteType?", 25.0)),
        buildButtons()
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
