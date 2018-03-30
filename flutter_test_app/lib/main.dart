import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'dart:async';
import 'login.dart';
import 'home.dart';
import 'password.dart';
import 'signup.dart';
import 'results.dart';

List<CameraDescription> cameras;

Future<Null> main() async {
  cameras = await availableCameras();

  runApp(new MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Flutter Demo',
      theme: new ThemeData(
        primarySwatch: Colors.pink,
      ),
      home: new Login(cameras: cameras),
      routes: <String, WidgetBuilder>{
        '/signup': (_) => new SignUpPage(),
        '/password': (_) => new PasswordPage(),
        '/camera': (_) => new HomePage(cameras: cameras),
        '/results': (_) => new ResultsPage(),
      },
    );
  }
}