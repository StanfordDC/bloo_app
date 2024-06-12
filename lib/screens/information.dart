import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bloo_app/widgets/textDisplay.dart';

class Information extends StatefulWidget {
  const Information({super.key});

  @override
  State<Information> createState() => _InformationState();
}

class _InformationState extends State<Information> {
  late String imagePath;
  late String wasteType;
  List<String> instructions = ["Waste type has not been categorized"];
  bool canBePlaced = true;
  bool exist = false;

  void insert(String wasteType) async{
    var collection = FirebaseFirestore.instance.collection('wasteType');
    var querySnapshot = await collection.get();
    for (var queryDocumentSnapshot in querySnapshot.docs) {
      Map<String, dynamic> data = queryDocumentSnapshot.data();
      var name = data['item'];
      if(name == wasteType){
        String description = data['instructions'];
        List<String> temp = description.split('<br/>');
        setState(() {
          instructions = [];
          for(String instruction in temp){
            String curr = instruction.trim();
            if(curr.isNotEmpty){
              instructions.add(curr);
            }
          }
          canBePlaced = data['recyclable'];
          exist = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    wasteType = ModalRoute.of(context)!.settings.arguments as String;
    insert(wasteType);
    return Scaffold(
        appBar: AppBar(
          title: const TextDisplay(Colors.black, "Information", 20.0),
          centerTitle: true),
        body: SingleChildScrollView(
          child: buildColumn()
        )
    );
  }


  Column buildColumn(){
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Padding(
              padding: EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 0.0),
              child: TextContainer(TextDisplay(Colors.black, "Waste Type", 20.0)),
          ),
          Padding(
              padding: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 12.0),
              child: TextContainer(TextDisplay(Colors.black, wasteType, 20.0)),
          ),
          const TextContainer(TextDisplay(Colors.black, "Recyclability Status", 20.0)),
          if(!exist)
            const Padding(
              padding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 12.0),
              child: TextContainer(TextDisplay(Colors.black, "NA", 20.0)),
            ),
          if(exist && canBePlaced)
            const Padding(
              padding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 12.0),
              child: TextContainer(TextDisplay(Colors.green, "RECYCLABLE", 20.0)),
            ),
          if(exist && !canBePlaced)
            const Padding(
              padding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 12.0),
              child: TextContainer(TextDisplay(Colors.red, "NOT RECYCLABLE", 20.0)),
            ),
          const TextContainer(TextDisplay(Colors.black, "Instruction", 20.0)),
          Container(
            width: double.infinity,
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6.0), // Set the rounded corners
              ),
              color: Colors.white54,
              elevation: 1.0,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Padding(
                    padding: EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 0.0),
                    child: TextDisplay(Colors.black, "", 0.0),
                  ),
                  if(isLowerCase(instructions[0][0].trim()))
                    TextContainer(TextDisplay(Colors.black87, '$wasteType ${instructions[0]}', 15.0)),
                  if(!isLowerCase(instructions[0][0].trim()))
                    TextContainer(TextDisplay(Colors.black87, instructions[0], 15.0)),
                  for(var i = 1 ; i < instructions.length ; i++)
                    TextContainer(TextDisplay(Colors.black87, instructions[i], 15.0)),
                  const Padding(
                    padding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 10.0),
                    child: TextDisplay(Colors.black, "", 0.0),
                  )
                ]
              ),
            ),
          ),
        ]
      );
  }


  bool isLowerCase(String input) {
    if (input.isEmpty) {
      return false; // An empty string does not have a first character.
    }
    String firstChar = input[0];
    return firstChar == firstChar.toLowerCase() && firstChar != firstChar.toUpperCase();
  }
}
