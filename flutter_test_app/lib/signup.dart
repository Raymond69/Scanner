import 'dart:ui';
import 'package:flutter/material.dart';

class SignUpPage extends StatefulWidget {
  SignUpPage({Key key}) : super(key: key);

  @override
  _SignUpPageState createState() => new _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  String _pseudo;
  String _email;
  String _password;
  final _scaffoldKey = new GlobalKey<ScaffoldState>();
  final _formKey = new GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        backgroundColor: Colors.pink[800],
        title: new Text(
            "Créer un compte",
            style: const TextStyle(color: Colors.white),
        ),
      ),
      key: _scaffoldKey,
      resizeToAvoidBottomPadding: false,
      body: new BackdropFilter(
        filter: new ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
        child: new Container(
          decoration: new BoxDecoration(
            color: Colors.grey,
            image: new DecorationImage(
              colorFilter: new ColorFilter.mode(Colors.white.withOpacity(0.2), BlendMode.dstATop),
              image: new AssetImage('assets/images/obj.jpg'),
              fit: BoxFit.cover,
            ),
          ),
        ),
      )
    );
  }
}