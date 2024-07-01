import 'package:flutter/material.dart';
import 'package:bloo_app/widgets/textDisplay.dart';
import 'package:bloo_app/models/wasteType.dart';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class Information extends StatefulWidget {
  const Information({super.key});

  @override
  State<Information> createState() => _InformationState();
}

class _InformationState extends State<Information> {
  late String imagePath;
  List<int> likedIndexes = [];
  List<int> dislikedIndexes = [];
  List<WasteType> list = [];
  bool fetching = true;
  int count = 0;

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

    print(count);
    print('Response time: $duration ms');
    if (response.statusCode == 200) {
      Map data = json.decode(utf8.decode(response.bodyBytes));
      setState(() {
        fetching = false;
        count++;
        if(data['from_database'].length != 0){
          list.addAll((data['from_database'] as List).map((item) => WasteType.fromJson(item)).toList());
        }
        if(data['from_llm'].length != 0){
           list.addAll((data['from_llm'] as List).map((item) => WasteType.fromJson(item)).toList());
        }
      });
    } else {
      throw Exception(response);
    }
  }

  @override
  Widget build(BuildContext context) {
    if(fetching){
      imagePath = ModalRoute.of(context)!.settings.arguments as String;
      var base64 = convert(imagePath);
      getType(base64);
    }
    return Scaffold(
        backgroundColor: Color.fromRGBO(241,253, 240,1),
        appBar: AppBar(
          backgroundColor: Color.fromRGBO(37,194,38,1),
          title: const TextDisplay(Colors.white, "Detected Objects", 20.0),
          centerTitle: true,
          leading: IconButton(
            icon: Icon(Icons.home, size: 30, color: Colors.white), 
            onPressed: () {
              Navigator.popUntil(context, ModalRoute.withName('/'));
            },
          ),
        ),
        body: Center(
          child: fetching ? Column(
            mainAxisAlignment: MainAxisAlignment.center,
              children: [
                LinearProgressIndicator(
                  color: Color.fromARGB(255, 97, 199, 82),
                  backgroundColor: Color.fromARGB(255, 169, 194, 165),
                ),
                const TextDisplay(Colors.black, 'Loading...', 25),
              ],
            )
          : wasteTypeList()
        )
      );
  }

  ListView wasteTypeList(){
    return ListView.builder(
      itemCount: list.length,
      itemBuilder: (context, index) {
        WasteType wasteType = list[index];
        bool isLiked = likedIndexes.contains(index);
        bool isDisliked = dislikedIndexes.contains(index);
        return Padding(
          padding: const EdgeInsets.all(5.0),
          child: Card(
            elevation: 4,
            child: ListTile(
              tileColor: Color.fromRGBO(245,254,253,1),
              title: TextDisplay(Colors.black, wasteType.item.toUpperCase(), 20),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 5),
                  Text(wasteType.recyclable ? 'RECYCLABLE' : 'NOT RECYCLABLE',  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: wasteType.recyclable ? Colors.green : Colors.red,
                  ),),
                  SizedBox(height: 5),
                  Text('Recycling Instructions', style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),),
                  SizedBox(height: 5),
                  processInstructions(wasteType.instructions),
                  responseButtons(wasteType.link, index, isLiked, isDisliked)
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget processInstructions(String instructions) {
    List<String> temp = instructions.split('•');
    temp = temp.map((part) => part.trim()).toList();
    List<Widget> instructionWidgets = [];

    for (int i = 0; i < temp.length; i++) {
      String instruction = temp[i].trim();
      if (instruction.isNotEmpty) {
        if (i == 0) {
          // First instruction, no bullet point needed
          instructionWidgets.add(Text(
            instruction, textAlign: TextAlign.justify,
          ));
        } else {
          // Subsequent instructions with bullet points
          instructionWidgets.add(Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 5,
                child: Text('•'),
              ),
              SizedBox(width: 5),
              Expanded(
                child: Text(
                  instruction,
                  textAlign : TextAlign.justify
                ),
              ),
            ],
          ));
        }
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: instructionWidgets,
    );
  }

  Row responseButtons(String link, int index, bool isLiked, bool isDisliked){
    return Row(
      children: [
        IconButton(
          icon: Icon(Icons.thumb_up, color: isLiked? const Color.fromARGB(255, 67, 66, 66) : Colors.grey,),
          onPressed: () {
            setState(() {
              if (isLiked) {
                likedIndexes.remove(index);
              } else {
                likedIndexes.add(index);
                dislikedIndexes.remove(index);
              }
            });
          }
        ),
        IconButton(
          icon: Icon(Icons.thumb_down, color: isDisliked? const Color.fromARGB(255, 67, 66, 66) : Colors.grey,),
          onPressed: () {
            // Handle thumbs down action here
            setState(() {
              if (isDisliked) {
                dislikedIndexes.remove(index);
              } else {
                dislikedIndexes.add(index);
                likedIndexes.remove(index);
              }
            });
          },
        ),
        if(link.length > 0)
          IconButton(
            icon: Icon(Icons.link, color: Colors.grey, size: 30),
            onPressed: () {
              _launchURL(link);
            },
          ),
      ],
    );
  }

  _launchURL(String link) async {
    if (await canLaunchUrl(Uri.parse(link))) {
      await launchUrl(Uri.parse(link));
    } else {
      throw 'Could not launch $link';
    }
  }
}
