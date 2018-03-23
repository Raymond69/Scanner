import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:async';

class HomePage extends StatefulWidget {
  HomePage({Key key, this.cameras}) : super(key: key);

  final List<CameraDescription> cameras;

  @override
  _HomePageState createState() => new _HomePageState();
}

class _HomePageState extends State<HomePage> {
  CameraController controller;
  CameraDescription inactiveCamera;
  int pictureCount = 0;
  String imagePath;
  bool opening = false;

  @override
  void initState() {
    super.initState();

    inactiveCamera = widget.cameras[1];

    controller = new CameraController(widget.cameras[0], ResolutionPreset.medium);
    controller.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  Future<Null> capture() async {
    if (controller.value.isStarted) {

      controller.stop();

      final Directory Dir = await getApplicationDocumentsDirectory();
      if (!mounted) {
        return;
      }
      final String dirPath = Dir.path;
      print(dirPath);

      controller.start();
//      final String path = '$tempPath/picture${pictureCount++}.jpg';
//      await controller.capture(path);
//      if (!mounted) {
//        return;
//      }
//      setState(
//            () {
//          imagePath = path;
//        },
//      );
    }
  }

  @override
  Widget build(BuildContext context) {
      return new AspectRatio(
          aspectRatio: controller.value.aspectRatio,
          child: new Stack(
            children: <Widget>[
              new CameraPreview(
                  controller
              ),
              new Container(
                alignment: Alignment.topRight,
                margin: const EdgeInsets.only(top: 25.0),
                child: new FlatButton(
                  onPressed: () async {

                    print(controller);

                    final CameraController tempController = controller;
                    controller = null;

                    await tempController?.dispose();

                    controller = new CameraController(inactiveCamera, ResolutionPreset.high);

                    if (inactiveCamera == widget.cameras[1])
                      inactiveCamera = widget.cameras[0];
                    else
                      inactiveCamera = widget.cameras[1];

                    await controller.initialize();

                    setState(() {});

                  },
                  child: new Image.asset(
                    "assets/icons/camera.png",
                    width: 40.0,
                    height: 40.0,
                  ),
                ),
              ),
              new Container(
                alignment: Alignment.bottomCenter,
                margin: const EdgeInsets.only(bottom: 20.0),
                child: new Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    new Expanded(
                      child: new FlatButton(
                        onPressed: null,
                        child: new Image.asset(
                          "assets/icons/profile.png",
                          width: 35.0,
                          height: 35.0,
                        ),
                      ),
                    ),
                    new Expanded(
                        child: new FloatingActionButton(
                          backgroundColor: Colors.transparent,
                          child: new LayoutBuilder(
                            builder: (context, constraint) {
                              return new Icon(
                                Icons.camera,
                                color: Colors.blue,
                                size: constraint.biggest.height,
                              );
                            },
                          ),
                          onPressed: controller.value.isStarted ? capture : null,
                        )
                    ),
                    new Expanded(
                      child: new FlatButton(
                        onPressed: null,
                        child: new Image.asset(
                          "assets/icons/album.png",
                          width: 35.0,
                          height: 35.0,
                        ),
                      ),
                    ),
                  ],
                ),
              )
            ],
          )
      );
  }
}