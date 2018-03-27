import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:ui';
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';

class ResultsPage extends StatefulWidget {
  ResultsPage({Key key, this.imagePath, this.user}) : super(key: key);

  final String imagePath;
  final FirebaseUser user;

  @override
  _ResultsPageState createState() => new _ResultsPageState();
}

class _ResultsPageState extends State<ResultsPage> {
  final String subscriptionKey = "cbd68cc35a6d4b7cba7d83fd09973965";
  final String uriBase = "https://westcentralus.api.cognitive.microsoft.com/face/v1.0/detect";
  String _fileContents;

  @override
  void initState() {
    super.initState();
    _uploadFile();
  }

  Future<Null> _uploadFile() async {
    final file = new File(widget.imagePath);

    final String rand = "${new Random().nextInt(10000)}";
    final StorageReference ref = FirebaseStorage.instance.ref().child("users/${widget.user}/images/foo$rand.jpg");
    final StorageUploadTask uploadImage = ref.put(file);

    _postCall();
  }

  void _postCall() {
    var client = new http.Client();

    /* CONFIGURATION DE L'URL */
    var uri = new Uri.https(
        "westcentralus.api.cognitive.microsoft.com",
        "/face/v1.0/detect",
        {
          "returnFaceId" : "true",
          "returnFaceLandmarks" : "false",
          "returnFaceAttributes" : "age,gender,headPose,smile,facialHair,glasses,emotion,hair,makeup,occlusion,accessories,blur,exposure,noise",
        }
    );

    client.post(
        uri.toString(),
        headers: {
          "Content-Type" : "application/json",
          "Ocp-Apim-Subscription-Key" : subscriptionKey
        },
        body: JSON.encoder.convert(
            {
              "url" : "http://szzljy.com/images/face/face3.jpg"
            }
        ),

    ).then((response) {
      print("Response status: ${response.statusCode}");
      print("Response body: ${response.body}");
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        backgroundColor: Colors.blue,
        title: new Text(
            "Résultats",
            style: const TextStyle(color: Colors.white)
        ),
      ),
      body: new Center(
        child: new Text(
          "afficher les resultats",
          style: const TextStyle(color: Colors.blue)
        ),
      ),
    );
  }
}