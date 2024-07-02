import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final containerSize = screenWidth * 0.3;
    return Scaffold(
      backgroundColor: Color.fromRGBO(241,253, 240,1),
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
                size: containerSize,
                color: Color.fromRGBO(37,194,38,1),
              ),
            ),
          ],
        ),
      ),
    ),);
  }
}
