import 'package:flutter/material.dart';
import 'package:bloo_app/widgets/textDisplay.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(241,253, 240,1),
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(241,253, 240,1),
          // leading:  IconButton(
          //   icon: const Icon(
          //     Icons.feed_outlined,
          //     size: 35,
          //     color: Colors.black,
          //   ),
          //   onPressed:(){},
          // ),
          // actions: <Widget>[
          //   IconButton(
          //     icon: const Icon(
          //       Icons.person,
          //       size: 35,
          //       color: Colors.black,
          //     ),
          //     onPressed:(){},
          //   )
          // ]
      ),
      body: SafeArea(
      child: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/recycle');
              },
              child: Icon(
                Icons.recycling,
                size: 130,
                color: Color.fromRGBO(37,194,38,1),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/recycle');
              },
              child: TextDisplay(Color.fromRGBO(37,194,38,1), "Start Recycling Right", 30.0),
            ),
          ],
        ),
      ),
    ),);
  }
}
