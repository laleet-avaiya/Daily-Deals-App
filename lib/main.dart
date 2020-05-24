import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import 'model/Post.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Daily Deals',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
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
  List<Post> postList = [];

  void initState() {
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
        postList.add(post);
      }

      var total = postList.length;
      setState(() {
        print("Length : $total ");
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'You have pushed the button this many times:',
              )
            ],
          ),
        ));
  }
}
