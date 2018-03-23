import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'dart:async';
import 'login.dart';
import 'home.dart';
import 'password.dart';
import 'signup.dart';

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
        primarySwatch: Colors.blue,
      ),
      home: new Login(title: 'Flutter Demo Home Page'),
      routes: <String, WidgetBuilder>{
        '/signup': (_) => new SignUpPage(),
        '/password': (_) => new PasswordPage(),
        '/camera': (_) => new HomePage(cameras: cameras),
      },
    );
  }
}