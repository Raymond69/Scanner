import 'dart:async';
import 'dart:ui';
import 'main.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;

class ProfilePage extends StatefulWidget {
  ProfilePage({Key key, this.googleUser}) : super(key: key);

  final GoogleSignIn googleUser;

  @override
  _ProfilePageState createState() => new _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
  }

  Future<Null> disconnectUser(BuildContext context) async {
    try {
      await _auth.signOut();
      if (widget.googleUser != null)
        await widget.googleUser.signOut();

      Navigator.pushReplacement(context, new MaterialPageRoute(
          builder: (BuildContext context) => new MyApp()
        )
      );
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
          backgroundColor: Colors.pink[800],
          title: new Text(
            "Mon compte",
            style: const TextStyle(color: Colors.white),
          ),
        ),
        key: _scaffoldKey,
        resizeToAvoidBottomPadding: false,
        body: new Center(
          child: new MaterialButton(
            height: 40.0,
            minWidth: 200.0,
            color: Colors.pink[800],
            child: new Text(
              "Se deconnecter",
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10.0
              )
            ),
            onPressed: () => disconnectUser(context),
          ),
        )
    );
  }
}