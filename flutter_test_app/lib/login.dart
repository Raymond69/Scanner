import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;
final GoogleSignIn _googleSignIn = new GoogleSignIn();

class Login extends StatefulWidget {
  Login({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _LoginPageState createState() => new _LoginPageState();
}

class _LoginPageState extends State<Login> {
  String _email;
  String _password;
  final _scaffoldKey = new GlobalKey<ScaffoldState>();
  final _formKey = new GlobalKey<FormState>();

  /* Initialisation des states */
  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  }

  /* Checker le formulaire de Login et trigger la connection*/
  Future<FirebaseUser> _submitLogin() async {
    final form = _formKey.currentState;

    if (form.validate()) {
      form.save();

      final FirebaseUser user = await _auth.signInWithEmailAndPassword(
          email: _email,
          password: _password
      );

      return user;
    }

    return null;
  }

  /* Trigger l'authentification Firebase */
  void _runLogin(FirebaseUser user) {
    if (user != null) {
      /* push route */
      print(user);
    }
    else {
      Scaffold.of(context).showSnackBar(
          new SnackBar(
            backgroundColor: Colors.blue,
            content: new Text("Erreur lors de la connection!"),
          )
      );
    }
  }

  /* GOOGLE SIGN IN */
  Future<FirebaseUser> _handleSignIn() async {
    final GoogleSignInAccount googleUser = await _googleSignIn.signIn();
    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
    final FirebaseUser user = await _auth.signInWithGoogle(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    assert(user.email != null);
    assert(user.displayName != null);
    assert(!user.isAnonymous);
    assert(await user.getIdToken() != null);

    final FirebaseUser currentUser = await _auth.currentUser();
    assert(user.uid == currentUser.uid);

    return user;
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
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
          child: new Center(
            child: new Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                new Padding(padding: new EdgeInsets.only(top: 30.0)),
                new Text("SCANNER", style: const TextStyle(fontSize: 50.0, fontFamily: 'Sifonn', color: Colors.blue)),
                new Form(
                  key: _formKey,
                  child: new Padding(
                    padding: new EdgeInsets.all(40.0),
                    child: new Column(
                      children: <Widget>[
                        new Padding(padding: new EdgeInsets.only(top: 10.0)),
                        new TextFormField(
                          style: new TextStyle(fontSize: 20.0, color: Colors.blue),
                          decoration: new InputDecoration(
                              icon: new Icon(Icons.email),
                              filled: true,
                              fillColor: Colors.transparent,
                              hintText: "Adresse email",
                              hintStyle: new TextStyle(fontSize: 20.0, color: Colors.blue),
                              contentPadding: new EdgeInsets.fromLTRB(10.0, 30.0, 10.0, 10.0),
                              border: new OutlineInputBorder(
                                  borderSide: new BorderSide(width: 1.0, color: Colors.blue),
                                  borderRadius: new BorderRadius.circular(20.0)
                              )
                          ),
                          validator: (val) => !val.contains('@') ? "Attention, format de l'email Invalide" : null,
                          onSaved: (val) => _email = val,
                        ),
                        new Padding(padding: new EdgeInsets.only(top: 15.0)),
                        new TextFormField(
                          style: new TextStyle(fontSize: 20.0, color: Colors.blue),
                          decoration: new InputDecoration(
                              icon: new Icon(Icons.lock),
                              filled: true,
                              fillColor: Colors.transparent,
                              hintText: "Mot de passe",
                              hintStyle: new TextStyle(fontSize: 20.0, color: Colors.blue),
                              contentPadding: new EdgeInsets.fromLTRB(10.0, 30.0, 10.0, 10.0),
                              border: new OutlineInputBorder(
                                  borderSide: new BorderSide(width: 1.0, color: Colors.blue),
                                  borderRadius: new BorderRadius.circular(20.0)
                              )
                          ),
                          onSaved: (val) => _password = val,
                          obscureText: true,
                        ),
                        new Padding(padding: new EdgeInsets.only(top: 50.0)),
                        new MaterialButton(
                          height: 40.0,
                          minWidth: 200.0,
                          color: Colors.blue,
                          onPressed: () {
                            _submitLogin()
                                .then((FirebaseUser user) => _runLogin(user))
                                .catchError((e) {
                              _scaffoldKey.currentState.showSnackBar(
                                  new SnackBar(
                                    backgroundColor: Colors.red,
                                    duration: new Duration(seconds: 5),
                                    content: new Text(
                                      "Adresse email ou mot de passe incorrect!",
                                      style: const TextStyle(color: Colors.white),
                                    ),
                                  )
                              );
                            });
                          },
                          child: new Text(
                              'Se connecter',
                              style: const TextStyle(color: Colors.white, fontSize: 10.0)
                          ),
                        ),
                        new Padding(padding: new EdgeInsets.only(top: 15.0)),
                        new MaterialButton(
                          height: 40.0,
                          minWidth: 200.0,
                          color: Colors.blue,
                          onPressed: () => Navigator.pushNamed(context, "/signup"),
                          child: new Text(
                              'Créer un compte',
                              style: const TextStyle(color: Colors.white, fontSize: 10.0)
                          ),
                        ),
                        new Padding(padding: new EdgeInsets.only(top: 30.0)),
                        new FlatButton(
                          onPressed: () => Navigator.pushNamed(context, "/password"),
                          child: new Text(
                              "mot de passe oublié ?",
                              style: const TextStyle(color: Colors.blue)
                          ),
                        ),
                        new Padding(padding: new EdgeInsets.only(top: 30.0)),
                        new FlatButton(

                          onPressed: () {
                            _handleSignIn()
                                .then((FirebaseUser user) => _runLogin(user))
                                .catchError((e) => print(e));
                          },
                          child: new Image.asset(
                              'assets/icons/google.png',
                              width: 70.0,
                              height: 70.0
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}