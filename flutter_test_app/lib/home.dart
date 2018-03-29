import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';
import 'results.dart';
import 'dart:async';

class HomePage extends StatefulWidget {
  HomePage({Key key, this.cameras, this.user}) : super(key: key);

  final List<CameraDescription> cameras;
  final FirebaseUser user;

  @override
  _HomePageState createState() => new _HomePageState();
}

class _HomePageState extends State<HomePage> {
  CameraController controller;
  CameraDescription inactiveCamera;
  int pictureCount = 0;
  String imagePath;
  bool captured;
  List<Widget> buttons;

  @override
  void initState() {
    super.initState();

    buttons = [];
    captured = false;

    inactiveCamera = widget.cameras[1];

    controller = new CameraController(widget.cameras[0], ResolutionPreset.high);
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

  List<Widget> isCaptured() {
    switch (captured) {
      case true :
        if (buttons != null)
          buttons.clear();
        buttons.add(
            new FlatButton(
              onPressed: () {
                captured = false;
                setState(() {});
                controller.start();
                Navigator.push(
                    context,
                    new MaterialPageRoute(
                        builder: (BuildContext context) => new ResultsPage(imagePath: imagePath, user: widget.user),
                    )
                );
              },
              child: new Image.asset(
                "assets/icons/send.png",
                width: 35.0,
                height: 35.0,
              ),
            )
        );
        buttons.add(
            new FlatButton(
              onPressed: () {
                captured = false;
                setState(() {});
                controller.start();
              },
              child: new Image.asset(
                "assets/icons/delete.png",
                width: 35.0,
                height: 35.0,
              ),
            )
        );
        buttons.add(
            new Container(
              width: 35.0,
              height: 35.0,
            )
        );
        buttons.add(
            new Container(
              width: 35.0,
              height: 35.0,
            )
        );
        buttons.add(
            new Container(
              width: 35.0,
              height: 35.0,
            )
        );
        return buttons;
        break;
      case false :
        if (buttons != null)
          buttons.clear();
        buttons.add(
            new FlatButton(
              onPressed: null,
              child: new Image.asset(
                "assets/icons/album.png",
                width: 35.0,
                height: 35.0,
              ),
            )
        );
        buttons.add(
            new Container()
        );
        buttons.add(
          new Image.asset(
            "assets/icons/camera.png",
            width: 40.0,
            height: 40.0,
          )
        );
        buttons.add(
            new FloatingActionButton(
              backgroundColor: Colors.transparent,
              child: new LayoutBuilder(
                builder: (context, constraints) {
                  return new Icon(
                    Icons.camera,
                    color: Colors.blue,
                    size: constraints.biggest.height,
                  );
                },
              ),
              onPressed: controller.value.isStarted ? capture : null,
            )
        );
        buttons.add(
          new FlatButton(
            onPressed: null,
            child: new Image.asset(
              "assets/icons/profile.png",
              width: 35.0,
              height: 35.0,
            ),
          ),
        );
        return buttons;
        break;
      default:
        return null;
    }
  }

  Future<Null> capture() async {
    if (controller.value.isStarted) {

      captured = true;

      setState(() {});

      final Directory Dir = await getApplicationDocumentsDirectory();
      if (!mounted) {
        return;
      }
      final String dirPath = Dir.path;


      final String path = '$dirPath/picture${pictureCount++}.jpg';
      await controller.capture(path);
      if (!mounted) {
        return;
      }
      setState(
            () {
          imagePath = path;
        },
      );

      controller.stop();
    }
  }

  @override
  Widget build(BuildContext context) {
      return new AspectRatio(
          aspectRatio: 10.0,
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
                  child: isCaptured().elementAt(2),
                ),
              ),
              new Container(
                alignment: Alignment.topLeft,
                margin: const EdgeInsets.only(top: 25.0),
                child: buttons.elementAt(1),
              ),
              new Container(
                alignment: Alignment.bottomCenter,
                margin: const EdgeInsets.only(bottom: 20.0),
                child: new Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    new Expanded(
                      child: isCaptured().elementAt(4),
                    ),
                    new Expanded(
                        child: isCaptured().elementAt(3),
                    ),
                    new Expanded(
                      child: isCaptured().elementAt(0),
                    ),
                  ],
                ),
              )
            ],
          )
      );
  }
}