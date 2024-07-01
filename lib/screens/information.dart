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
      Map data = jsonDecode(response.body);
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
        appBar: AppBar(
          backgroundColor: Color.fromRGBO(0,195,0,1),
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
          padding: const EdgeInsets.all(8.0),
          child: Card(
            elevation: 3,
            child: ListTile(
              title: TextDisplay(Colors.black, wasteType.item.toUpperCase(), 20),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Recyclable: ${wasteType.recyclable ? 'YES' : 'NO'}'),
                  Text('Instructions: ${wasteType.instructions}'),
                  responseButtons(wasteType.link, index, isLiked, isDisliked)
                ],
              ),
            ),
          ),
        );
      },
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

  bool isLowerCase(String input) {
    if (input.isEmpty) {
      return false; // An empty string does not have a first character.
    }
    String firstChar = input[0];
    return firstChar == firstChar.toLowerCase() && firstChar != firstChar.toUpperCase();
  }
}
