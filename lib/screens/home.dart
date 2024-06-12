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
      appBar: AppBar(
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
        child: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('images/blur-background.jpg'),
              fit: BoxFit.cover,
            )
          ),
          margin: const EdgeInsets.fromLTRB(12.0, 0.0, 12.0, 0.0),
          height: 200,
          width: 400,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TextButton(
                child: const Icon(
                  Icons.recycling,
                  size: 80,
                  color: Colors.black,
                ),
                onPressed: (){
                  Navigator.pushNamed(context, '/recycle');
                },
              ),
              TextButton(
                child: const TextDisplay(Colors.black, "Start Recycling", 25.0),
                  onPressed: (){
                    Navigator.pushNamed(context, '/recycle');
                  },
              ),
            ]
          )
      ),
    ));
  }
}
