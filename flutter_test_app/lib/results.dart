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
  double max = 0.0;
  String emotionString = "";
  String emotionAssetPath = "";
  List<Widget> allCards = new List();
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

  void maxValue(key, value)
  {
    String path;

    if (value > max) {
      print(value);
      switch (key) {
        case 'anger' :
          path = "assets/icons/anger.png";
          break;
        case 'contempt' :
          path = "assets/icons/contempt.png";
          break;
        case 'disgust' :
          path = "assets/icons/disgust.png";
          break;
        case 'fear' :
          path = "assets/icons/fear.png";
          break;
        case 'happiness' :
          path = "assets/icons/hapinness.png";
          break;
        case 'neutral' :
          path = "assets/icons/neutral.png";
          break;
        case 'sadness' :
          path = "assets/icons/sadness.png";
          break;
        case 'surprise' :
          path = "assets/icons/surprised.png";
          break;
      }
      try {
        setState(() {
          max = value;
          emotionString = key;
          emotionAssetPath = path;
        });
      } catch (e) {
        print(e);
      }
    }
  }

  void iterateMapEntry(key, value) {
    switch (key) {
      case 'gender' :
        allCards.add(
            new Container(
              margin: new EdgeInsets.only(left: 10.0, right: 10.0),
              width: MediaQuery.of(context).size.width - 50.0,
              child: new Card(
                child: new Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    new Padding(padding: new EdgeInsets.only(top: 10.0)),
                    new Center(
                      child: new Title(
                          color: Colors.blue,
                          child: new Text(
                            key,
                            style: const TextStyle(
                                color: Colors.blue,
                                fontSize: 50.0
                            ),

                          )
                      ),
                    ),
                    new Padding(padding: new EdgeInsets.only(top: 70.0)),
                    new Center(
                      child: new Container(
                        width: 150.0,
                        height: 150.0,
                        child: value == 'male' ? new Image.asset(
                            "assets/icons/masculine.png"
                        ) : new Image.asset(
                            "assets/icons/female-sign.png"
                        ),
                      ),
                    )
                  ],
                ),
              ),
            )
        );
        break;
      case 'age' :
        allCards.add(
            new Container(
              margin: new EdgeInsets.only(left: 10.0, right: 10.0),
              width: MediaQuery.of(context).size.width - 50.0,
              child: new Card(
                child: new Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    new Padding(padding: new EdgeInsets.only(top: 10.0)),
                    new Center(
                      child: new Title(
                          color: Colors.blue,
                          child: new Text(
                            key,
                            style: const TextStyle(
                                color: Colors.blue,
                                fontSize: 50.0
                            ),

                          )
                      ),
                    ),
                    new Padding(padding: new EdgeInsets.only(top: 70.0)),
                    new Center(
                      child: new Container(
                        width: 250.0,
                        height: 250.0,
                        child: new Text(
                          "${value.toStringAsFixed(0)} yo",
                          style: const TextStyle(
                              color: Colors.blue,
                              fontSize: 60.0
                          ),
                        )
                      ),
                    )
                  ],
                ),
              ),
            )
        );
        break;
      case 'emotion' :
        value.forEach(maxValue);
        allCards.add(
            new Container(
              margin: new EdgeInsets.only(left: 10.0, right: 10.0),
              width: MediaQuery.of(context).size.width - 50.0,
              child: new Card(
                child: new Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    new Padding(padding: new EdgeInsets.only(top: 10.0)),
                    new Center(
                      child: new Title(
                          color: Colors.blue,
                          child: new Text(
                            key,
                            style: const TextStyle(
                                color: Colors.blue,
                                fontSize: 50.0
                            ),

                          )
                      ),
                    ),
                    new Padding(padding: new EdgeInsets.only(top: 70.0)),
                    new Center(
                      child: new Container(
                          width: 150.0,
                          height: 150.0,
                          child: new Image.asset(
                              emotionAssetPath
                          )
                      ),
                    )
                  ],
                ),
              ),
            )
        );
        break;
      case 'makeup' :
        print('makeup');
        break;
      case 'accessories' :
        print('accessories');
        break;
    }
  }

  List<Widget> attributesWidget() {
    results["faceAttributes"].forEach(iterateMapEntry);
    return allCards;
  }

  Widget displayAnalyze(BuildContext context) {
    try {
      if (results != null) {
        if (results.isNotEmpty) {
          return new Container(
            margin: new EdgeInsets.symmetric(vertical: 20.0),
            height: 400.0,
            child: new ListView.builder(
              scrollDirection: Axis.horizontal,
              itemBuilder: (BuildContext context, int index) => attributesWidget()[index],
              itemCount: attributesWidget().length,
            ),
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
            child: displayAnalyze(context),
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