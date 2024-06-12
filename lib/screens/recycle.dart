import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
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
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: Stack(
        children:[
          FutureBuilder(future: cameraValue, builder: (context, snapshot){
            if(snapshot.connectionState == ConnectionState.done){
              return SizedBox(
                width: size.width,
                height: size.height,
                child: FittedBox(
                  fit: BoxFit.cover,
                  child: SizedBox(
                    width: 100,
                    child: CameraPreview(cameraController),
                  ),
                ),
              );
            }
            else{
              return const Center(child: CircularProgressIndicator(),);
            }
          })
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color.fromRGBO(255, 255, 255, .7),
        shape: const CircleBorder(),
        onPressed: () async{
          try{
            await cameraValue;

            final image = await cameraController.takePicture();
            if (!context.mounted) return;

            // If the picture was taken, display it on a new screen.
            Navigator.pushReplacementNamed(context, '/confirmation', arguments: image.path);
            } catch (e) {
            // If an error occurs, log the error to the console.
            print(e);
            }
        },
        child: const Icon(
            Icons.camera_alt,
            size: 40,
            color: Colors.black
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,

    );
  }
}
