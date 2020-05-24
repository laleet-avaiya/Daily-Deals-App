import 'package:firebase_database/firebase_database.dart';
import 'dart:async';
import 'package:badges/badges.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:time_ago_provider/time_ago_provider.dart';

import 'model/Post.dart';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Daily Deals',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: MyHomePage(title: 'Daily Deals'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  String _message = '';
  List<Post> postList = [];

  _register() {
    _firebaseMessaging.getToken().then((token) => print(token));
  }

  void getMessage() {
    _firebaseMessaging.configure(
        onMessage: (Map<String, dynamic> message) async {
      print('on message $message');
      setState(() => _message = message["notification"]["title"]);
    }, onResume: (Map<String, dynamic> message) async {
      print('on resume $message');
      setState(() => _message = message["notification"]["title"]);
    }, onLaunch: (Map<String, dynamic> message) async {
      print('on launch $message');
      setState(() => _message = message["notification"]["title"]);
    });
  }

  void loadData() {
    DatabaseReference postRef =
        FirebaseDatabase.instance.reference().child("posts");

    postRef.once().then((DataSnapshot snap) {
      var KEYS = snap.value.keys;
      var DATA = snap.value;

      postList.clear();

      for (var individualKey in KEYS) {
        Post post = new Post(
            DATA[individualKey]['title'],
            DATA[individualKey]['description'],
            DATA[individualKey]['image_url'],
            DATA[individualKey]['source_url'],
            DATA[individualKey]['published_on'],
            DATA[individualKey]['label']);
        postList.insert(0, post);
      }

      var total = postList.length;
      setState(() {
        print("Length : $total ");
      });
    });
  }

  @override
  void initState() {
    super.initState();
    getMessage();
    loadData();
  }

  _launchURL() async {
    const url = 'https://flutter.dev';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: new Container(
          child: postList.length == 0
              ? new Text("Loading...")
              : new ListView.builder(
                  itemCount: postList.length,
                  itemBuilder: (BuildContext context, int index) {
                    return PostUI(postList[index]);
                  },
                ),
        ));
  }

  Widget PostUI(Post post) {
    double c_width = MediaQuery.of(context).size.width * 0.8;
    return new GestureDetector(
      onTap: _launchURL,
      onLongPress: () {
        _register();
      },
      child: new Card(
        elevation: 5,
        margin: EdgeInsets.fromLTRB(10, 10, 10, 5),
        semanticContainer: true,
        clipBehavior: Clip.antiAliasWithSaveLayer,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
        child: new Container(
          padding: new EdgeInsets.all(10.0),
          child: new Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Image.network(
                      post.image_url,
                      width: 90,
                      height: 90,
                    ),
                  ],
                ),
                Expanded(
                    child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      post.title,
                      softWrap: true,
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16.0),
                    ),
                    Text(
                      TimeAgo.getTimeAgo(int.parse(post.published_on)),
                      softWrap: true,
                      style: TextStyle(fontSize: 12.0),
                    ),
                    // Text(post.source_url),
                    Badge(
                      badgeColor: Colors.blueAccent,
                      shape: BadgeShape.square,
                      borderRadius: 7,
                      toAnimate: true,
                      badgeContent: Text(post.label,
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontSize: 12.0)),
                    ),
                  ],
                )),
              ]),
        ),
      ),
    );
  }
}
