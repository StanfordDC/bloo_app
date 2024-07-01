import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Recycle extends StatefulWidget {
  final CameraDescription camera;
  const Recycle({super.key, required this.camera});

  @override
  State<Recycle> createState() => _RecycleState();
}

class _RecycleState extends State<Recycle> {
  late CameraController cameraController;
  late Future<void> cameraValue;

  void startCamera(){
    cameraController = CameraController(
        widget.camera, ResolutionPreset.high, enableAudio: false);
    cameraValue = cameraController.initialize();
  }

  @override
  void initState(){
    startCamera();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.black,
        statusBarIconBrightness: Brightness.light,
      ),
    );
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: FutureBuilder<void>(
          future: cameraValue,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return Stack(
                children: <Widget>[
                  cameraWidget(context),
                  cameraControlWidget(context),
                ],
              );
            } else {
              return Center(child: CircularProgressIndicator());
            }
          },
        ),
      ),
    );
  }

  Widget cameraWidget(context) {
    var camera = cameraController.value;
    final size = MediaQuery.of(context).size;
    var scale = size.aspectRatio * camera.aspectRatio;

    if (scale < 1) scale = 1 / scale;

    return ClipRRect(
      borderRadius: BorderRadius.circular(25.0), // Adjust the radius as needed
      child: Transform.scale(
        scale: scale,
        child: Center(
          child: CameraPreview(cameraController),
        ),
      ),
    );
  }

  Widget cameraControlWidget(context) {
    return Align(
        alignment: Alignment.bottomCenter,
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: GestureDetector(
            onTap: () async{
            try{
              await cameraValue;

              final image = await cameraController.takePicture();
              if (!context.mounted) return;

              // If the picture was taken, display it on a new screen.
              Navigator.pushReplacementNamed(context, '/confirmation', 
                arguments: {'imagePath' : image.path, 'value' : cameraController.value});
              } catch (e) {
              // If an error occurs, log the error to the console.
                print(e);
              }
            },
              child: Container(
                width: 80.0,
                height: 80.0,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 4.0),
                  color: Colors.transparent,
                ),
                child: Center(
                  child: Container(
                    width: 65.0,
                    height: 65.0,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                  ),
                ),
              )
            )
        ),
    );
  }
}
