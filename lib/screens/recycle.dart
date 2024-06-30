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
      appBar: AppBar(
        backgroundColor: Colors.black,
        automaticallyImplyLeading: false,
      ),
      body: Container(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children:[
              FutureBuilder(future: cameraValue, builder: (context, snapshot){
                if(snapshot.connectionState == ConnectionState.done){
                  return Expanded(
                    flex: 1,
                    child: CameraPreview(cameraController),
                  );
                }
                else{
                  return const Center(child: CircularProgressIndicator(),);
                }
              }),
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  height: 150,
                  width: double.infinity,
                  padding: EdgeInsets.all(15),
                  color: Colors.black,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      cameraControlWidget(context),
                    ],
                  ),
                ),
              )
            ],
          ),
        )
      )
    );
  }

  Widget cameraControlWidget(context) {
    return Expanded(
      child: Align(
        alignment: Alignment.center,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            GestureDetector(
               onTap: () async{
                try{
                  await cameraValue;

                  final image = await cameraController.takePicture();
                  if (!context.mounted) return;

                  // If the picture was taken, display it on a new screen.
                  Navigator.pushReplacementNamed(context, '/confirmation', 
                    arguments: {'imagePath' : image.path, 'aspectRatio' : cameraController.value.aspectRatio});
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
          ],
        ),
      ),
    );
  }

  Widget cameraPreviewWidget() {
    return AspectRatio(
      aspectRatio: cameraController.value.aspectRatio,
      child: CameraPreview(cameraController),
    );
  }

}
