import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:bloo_app/widgets/textDisplay.dart';

class Feedbacks extends StatefulWidget {
  const Feedbacks({super.key});

  @override
  State<Feedbacks> createState() => _FeedbacksState();
}

class _FeedbacksState extends State<Feedbacks> {
  static String chosen = "";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: <Widget>[
          const TextContainer(TextDisplay(Colors.black, "Please enter the waste type", 25.0)),
            Container(
                margin: const EdgeInsets.fromLTRB(12.0, 0.0, 12.0, 10.0),
            child: const AutocompleteBasicExample()),
          ElevatedButton(
              onPressed: (){Navigator.pushReplacementNamed(context, '/information', arguments: chosen);},
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black
              ),
              child: const TextDisplay(Colors.white, "Confirm", 25.0),
          ),
        ]
      )
    );
  }
}

class AutocompleteBasicExample extends StatelessWidget {
  const AutocompleteBasicExample({super.key});
  static List<String> _kOptions = [];

  void insert() async{
    var collection = FirebaseFirestore.instance.collection('wasteType');
    var querySnapshot = await collection.get();
    Map<String, String> id;
    for (var queryDocumentSnapshot in querySnapshot.docs) {
      Map<String, dynamic> data = queryDocumentSnapshot.data();
      var name = data['item'];
      _kOptions.add(name);
    }
  }
  @override
  Widget build(BuildContext context) {
    insert();
    return Autocomplete<String>(
      optionsBuilder: (TextEditingValue textEditingValue) {
        if (textEditingValue.text == '') {
          return const Iterable<String>.empty();
        }
        return _kOptions.where((String option) {
          return option.contains(textEditingValue.text.toLowerCase());
        });
      },
      onSelected: (String selection) {
        _FeedbacksState.chosen = selection;
      },
    );
  }
}
