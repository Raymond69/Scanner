import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:ui';
import 'dart:async';
import 'package:async_loader/async_loader.dart';
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
  Uri downloadUrl;
  Map results;
  final GlobalKey<AsyncLoaderState> _asyncLoaderState = new GlobalKey<AsyncLoaderState>();

  @override
  void initState() {
    super.initState();
  }

  Future<Null> _uploadFile() async {
    final file = new File(widget.imagePath);

    final String rand = "${new Random().nextInt(10000)}";
    final StorageReference ref = FirebaseStorage.instance.ref().child("users/${widget.user.uid}/images/foo$rand.jpg");
    final StorageUploadTask uploadImage = ref.put(file);
    _postCall(downloadUrl = (await uploadImage.future).downloadUrl);
  }

  void _postCall(Uri downloadUrl) {
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

    try {
      client.post(
        uri.toString(),
        headers: {
          "Content-Type" : "application/json",
          "Ocp-Apim-Subscription-Key" : subscriptionKey
        },
        body: JSON.encoder.convert(
            {
              "url" : downloadUrl.toString()
            }
        ),

      ).then((response) {
        if(response.statusCode == 200) {
          switch (response.body.length) {
            case 2 :
              setState(() {
                results = new Map();
              });
              break;
            default:
              setState(() {
                results = JSON.decode(response.body.substring(1, response.body.length - 1));
              });
              break;
          }
        }
      });
    } catch (e) {
      print(e);
    }
  }

  Widget displayAnalyze() {
    try {
      if (results != null) {
        if (results.isNotEmpty) {
          return new Column(
            children: <Widget>[
              new Card(
                child: new Container(
                  margin: new EdgeInsets.all(40.0),
                  child: new Text(
                    "Genre : ${results["faceAttributes"]["gender"]}",
                    style: const TextStyle(
                        color: Colors.blue,
                        fontSize: 35.0
                    ),
                  ),
                ),
              ),
              new Card(
                child: new Container(
                  margin: new EdgeInsets.all(40.0),
                  child: new Text(
                    "Age : ${results["faceAttributes"]["age"]}",
                    style: const TextStyle(
                        color: Colors.blue,
                        fontSize: 35.0
                    ),
                  ),
                ),
              ),
              new Card(
                child: new Container(
                  margin: new EdgeInsets.all(40.0),
                  child: new Text(
                    "cheveux : ",
                    style: const TextStyle(
                        color: Colors.blue,
                        fontSize: 35.0
                    ),
                  ),
                ),
              ),
            ],
          );
        } else {
          return new Center(
            child: new Text(
              "Aucun visage détecté ...",
              style: const TextStyle(
                color: Colors.red,
                fontSize: 30.0,
              ),
            ),
          );
        }
      }
      return new Center(
        child: new Text(
          "Analyse en cours ...",
          style: const TextStyle(
            color: Colors.blue,
            fontSize: 30.0,
          ),
        ),
      );
    } catch (e) {
      print(e);
    }
    return new Container();
  }

  @override
  Widget build(BuildContext context) {
    var _asyncLoader = new AsyncLoader(
      key: _asyncLoaderState,
      initState: () async => await _uploadFile(),
      renderLoad: () => new Center(
        child: new CircularProgressIndicator(),
      ),
      renderError: ([error]) => new Center(
        child: new Text(
            "Désolé, il y a eu une erreur lors du chargement du résultat :( ...",
            style: const TextStyle(color: Colors.red),
        ),
      ),
      renderSuccess: ({data}) => new ListView(
        children: <Widget>[
          new Image.file(
            new File(widget.imagePath),
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
          ),
          new Padding(
            padding: new EdgeInsets.all(10.0),
            child: displayAnalyze(),
          ),
        ],
        scrollDirection: Axis.vertical,
      ),
    );
    return new Scaffold(
      appBar: new AppBar(
        backgroundColor: Colors.blue,
        title: new Text(
            "Résultats",
            style: const TextStyle(color: Colors.white)
        ),
      ),
      body: new Flex(
        direction: Axis.vertical,
        children: <Widget>[
          new Expanded(
            child: _asyncLoader
          ),
        ],
      ),
    );
  }
}