import 'package:flutter/material.dart';
import 'package:bloo_app/widgets/textDisplay.dart';
import 'package:bloo_app/models/wasteType.dart';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';

class Information extends StatefulWidget {
  const Information({super.key});

  @override
  State<Information> createState() => _InformationState();
}

class _InformationState extends State<Information> {
  final CollectionReference wasteTypeResponse = FirebaseFirestore.instanceFor(app: Firebase.app('bloo-app')).collection('wastetypeResponse');
  final FirebaseStorage storage = FirebaseStorage.instanceFor(app: Firebase.app('bloo-app'));
  late String imagePath;
  late String base64;
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
    double screenWidth = MediaQuery.of(context).size.width;
    double fontSize = screenWidth * 0.05;
    if(fetching){
      imagePath = ModalRoute.of(context)!.settings.arguments as String;
      base64 = convert(imagePath);
      getType(base64);
    }
    return Scaffold(
        backgroundColor: Color.fromRGBO(241,253, 240,1),
        appBar: AppBar(
          backgroundColor: Color.fromRGBO(241,253, 240,1),
          title: TextDisplay(Colors.black, "Detected Objects", fontSize),
          centerTitle: true,
          automaticallyImplyLeading: false,
        ),
        body: Center(
          child: fetching ? Column(
            mainAxisAlignment: MainAxisAlignment.center,
              children: [
                LinearProgressIndicator(
                  color: Color.fromARGB(255, 97, 199, 82),
                  backgroundColor: Color.fromARGB(255, 169, 194, 165),
                ),
                TextDisplay(Colors.black, 'Loading...', fontSize),
              ],
            )
          : wasteTypeList(context)
        )
      );
  }

  ListView wasteTypeList(context){
    double screenWidth = MediaQuery.of(context).size.width;
    double fontSize = screenWidth * 0.04;
    return ListView.builder(
      itemCount: list.length + 1,
      itemBuilder: (context, index) {
        if(index == list.length)
          return buildButtons(context);
        WasteType wasteType = list[index];
        bool isLiked = likedIndexes.contains(index);
        bool isDisliked = dislikedIndexes.contains(index);
        return Padding(
          padding: const EdgeInsets.all(5.0),
          child: Card(
            elevation: 4,
            child: ListTile(
              tileColor: Color.fromRGBO(245,254,253,1),
              title: TextDisplay(Colors.black, wasteType.item.toUpperCase(), fontSize),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 5),
                  Text(wasteType.recyclable ? 'RECYCLABLE' : 'NOT RECYCLABLE',  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: wasteType.recyclable ? Colors.green : Colors.red,
                  ),),
                  SizedBox(height: 5),
                  Text('Material: '+wasteType.material.toLowerCase(), style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
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
  
  Future<void> addWasteTypeResponse() async {
    // Example data to add to Firestore
    Map<String, int> objects= {};
    for(WasteType w in list){
      objects[w.item] = 0;
    }
    for(int index in likedIndexes){
      objects[list[index].item] = 1;
    }
    for(int index in dislikedIndexes){
      objects[list[index].item] = 2;
    }
    String? imageUrl = await uploadImage();
    Map<String, dynamic> response = {
      'imageUrl': imageUrl,
      'objects': objects,
    };
    try {
      await wasteTypeResponse.add(response);
      print('Response added to Firestore');
    } catch (error) {
      print('Failed to add response: $error');
    }
  }

  Future<String?> uploadImage() async {
    File imageFile = File(imagePath);

    try {
      final fileName = imageFile.path.split('/').last;
      final storageRef = storage.ref().child('uploads/$fileName');
      final uploadTask = storageRef.putFile(imageFile);

      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();

      print('Uploaded image URL: $downloadUrl');
      return downloadUrl;
    } catch (e) {
      print('Error occurred while uploading image: $e');
    }
    return null;
  }

  Column buildButtons(context){
    double screenWidth = MediaQuery.of(context).size.width;
    double fontSize = screenWidth * 0.05;
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
                  onPressed: (){
                    addWasteTypeResponse(); 
                    Navigator.pushReplacementNamed(context, '/recycle');},
                  child: TextDisplay(Colors.white, "Recycle Again", fontSize)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 20.0),
            child: SizedBox( 
              width: double.infinity,
              child:  ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromRGBO(245,254,253,1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6.0),
                      side: BorderSide(color: Colors.black), // Set the rounded corners
                    ),
                  ),
                  onPressed: (){
                    addWasteTypeResponse(); 
                    Navigator.popUntil(context, ModalRoute.withName('/'));},
                  child: TextDisplay(Colors.black, "Home",fontSize)),
            ),
          ),
        ]
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
