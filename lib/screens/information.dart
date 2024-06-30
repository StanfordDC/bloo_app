import 'package:flutter/material.dart';
import 'package:bloo_app/widgets/textDisplay.dart';
import 'package:bloo_app/models/wasteType.dart';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class Information extends StatefulWidget {
  const Information({super.key});

  @override
  State<Information> createState() => _InformationState();
}

class _InformationState extends State<Information> {
  late String imagePath;
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
          title: const TextDisplay(Colors.black, "Detected Objects", 20.0),
          centerTitle: true,
          leading: IconButton(
            icon: Icon(Icons.home, size: 30), 
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
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Card(
            elevation: 3,
            child: ListTile(
              title: Text(
                wasteType.item,
                style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Material: ${wasteType.material}'),
                  Text('Recyclable: ${wasteType.recyclable ? 'Yes' : 'No'}'),
                  Text('Instructions: ${wasteType.instructions}'),
                ],
              ),
              trailing: IconButton(
                icon: Icon(Icons.link),
                onPressed: () {
                  // Handle link navigation here
                  // Example: launch URL
                  // launch(wasteType.link);
                },
              ),
            ),
          ),
        );
      },
    );
  }
  // Column buildColumn(){
  //   return Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: <Widget>[
  //         const Padding(
  //             padding: EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 0.0),
  //             child: TextContainer(TextDisplay(Colors.black, "Waste Type", 20.0)),
  //         ),
  //         Padding(
  //             padding: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 12.0),
  //             child: TextContainer(TextDisplay(Colors.black, wasteType, 20.0)),
  //         ),
  //         const TextContainer(TextDisplay(Colors.black, "Recyclability Status", 20.0)),
  //         if(!exist)
  //           const Padding(
  //             padding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 12.0),
  //             child: TextContainer(TextDisplay(Colors.black, "NA", 20.0)),
  //           ),
  //         if(exist && canBePlaced)
  //           const Padding(
  //             padding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 12.0),
  //             child: TextContainer(TextDisplay(Colors.green, "RECYCLABLE", 20.0)),
  //           ),
  //         if(exist && !canBePlaced)
  //           const Padding(
  //             padding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 12.0),
  //             child: TextContainer(TextDisplay(Colors.red, "NOT RECYCLABLE", 20.0)),
  //           ),
  //         const TextContainer(TextDisplay(Colors.black, "Instruction", 20.0)),
  //         Container(
  //           width: double.infinity,
  //           child: Card(
  //             shape: RoundedRectangleBorder(
  //               borderRadius: BorderRadius.circular(6.0), // Set the rounded corners
  //             ),
  //             color: Colors.white54,
  //             elevation: 1.0,
  //             child: Column(
  //               crossAxisAlignment: CrossAxisAlignment.start,
  //               children: <Widget>[
  //                 const Padding(
  //                   padding: EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 0.0),
  //                   child: TextDisplay(Colors.black, "", 0.0),
  //                 ),
  //                 if(isLowerCase(instructions[0][0].trim()))
  //                   TextContainer(TextDisplay(Colors.black87, '$wasteType ${instructions[0]}', 15.0)),
  //                 if(!isLowerCase(instructions[0][0].trim()))
  //                   TextContainer(TextDisplay(Colors.black87, instructions[0], 15.0)),
  //                 for(var i = 1 ; i < instructions.length ; i++)
  //                   TextContainer(TextDisplay(Colors.black87, instructions[i], 15.0)),
  //                 const Padding(
  //                   padding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 10.0),
  //                   child: TextDisplay(Colors.black, "", 0.0),
  //                 )
  //               ]
  //             ),
  //           ),
  //         ),
  //       ]
  //     );
  // }


  bool isLowerCase(String input) {
    if (input.isEmpty) {
      return false; // An empty string does not have a first character.
    }
    String firstChar = input[0];
    return firstChar == firstChar.toLowerCase() && firstChar != firstChar.toUpperCase();
  }
}
