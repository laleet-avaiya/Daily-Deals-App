import 'package:firebase_database/firebase_database.dart';
import 'package:badges/badges.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:time_ago_provider/time_ago_provider.dart';
import 'package:firebase_admob/firebase_admob.dart';
import 'model/Post.dart';

void main() => runApp(MyApp());

// You can also test with your own ad unit IDs by registering your device as a
// test device. Check the logs for your device's ID value.
const String AD_MOB_APP_ID = 'ca-app-pub-8894739064593802~2924171610';
const String AD_MOB_TEST_DEVICE = '9BD99794EFFFC5BD85BE8BB42E0E6525';

// Banner
const String AD_MOB_AD_ID = 'ca-app-pub-8894739064593802/9106436587';

// IntersititialAd
const String InterstitialAd_AD_ID = 'ca-app-pub-8894739064593802/5097256421';

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Daily Deals',
      color: Colors.white,
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
  List<Post> postList = [];
  String _message = '';
  BannerAd _bannerAd;
  InterstitialAd _interstitialAd;
  bool _adShown;

  static const MobileAdTargetingInfo targetingInfo = MobileAdTargetingInfo(
    testDevices:
        AD_MOB_TEST_DEVICE != null ? <String>[AD_MOB_TEST_DEVICE] : null,
  );

  BannerAd createBannerAd() {
    return BannerAd(
      adUnitId: AD_MOB_AD_ID,
      // adUnitId: BannerAd.testAdUnitId,
      size: AdSize.banner,
      targetingInfo: targetingInfo,
      listener: (MobileAdEvent event) {
        if (event == MobileAdEvent.loaded) {
          _adShown = true;
          setState(() {});
        } else if (event == MobileAdEvent.failedToLoad) {
          _adShown = false;
          setState(() {});
        }
      },
    );
  }

  InterstitialAd createInterstitialAd() {
    return InterstitialAd(
      // adUnitId: InterstitialAd.testAdUnitId,
      adUnitId: InterstitialAd_AD_ID,
      targetingInfo: targetingInfo,
      listener: (MobileAdEvent event) {
        print("InterstitialAd event $event");
      },
    );
  }

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
      Comparator<Post> postComparator =
          (a, b) => b.published_on.compareTo(a.published_on);
      postList.clear();

      for (var individualKey in KEYS) {
        Post post = new Post(
            individualKey,
            DATA[individualKey]['title'],
            DATA[individualKey]['description'],
            DATA[individualKey]['image_url'],
            DATA[individualKey]['source_url'],
            DATA[individualKey]['published_on'],
            DATA[individualKey]['label']);
        postList.add(post);
      }
      postList.sort(postComparator);

      var total = postList.length;
      setState(() {
        print("Length : $total ");
      });
    });
  }

  @override
  void initState() {
    super.initState();
    _firebaseMessaging.subscribeToTopic('post');
    getMessage();
    loadData();
    // FirebaseAdMob.instance.initialize(appId: FirebaseAdMob.testAppId);
    FirebaseAdMob.instance.initialize(appId: AD_MOB_APP_ID);
    _adShown = false;
    _bannerAd = createBannerAd()
      ..load()
      ..show();
  }

  Future<void> _getData() async {
    setState(() {
      loadData();
    });
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    _interstitialAd?.dispose();
    super.dispose();
  }

  _launchURL(url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> fakeBottomButtons = new List<Widget>();
    fakeBottomButtons.add(new Container(
      height: 50.0,
    ));

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
          bottom: TabBar(
            tabs: [
              Tab(icon: Icon(Icons.home)),
              Tab(icon: Icon(Icons.phone_android)),
              Tab(icon: Icon(Icons.show_chart)),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            new Container(
              child: postList.length == 0
                  ? Center(
                      child: CircularProgressIndicator(
                          backgroundColor: Colors.green))
                  : RefreshIndicator(
                      child: new ListView.builder(
                        itemCount: postList.length,
                        itemBuilder: (BuildContext context, int index) {
                          return PostUI(postList[index]);
                        },
                      ),
                      onRefresh: _getData,
                    ),
            ),
            Icon(Icons.ac_unit),
            Icon(Icons.ac_unit),
          ],
        ),
        persistentFooterButtons: fakeBottomButtons,
      ),
    );
  }

  Widget PostUI(Post post) {
    return new GestureDetector(
      onTap: () => _launchURL(post.source_url),
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
                Container(
                  padding: new EdgeInsets.all(10.0),
                  child: Image.network(
                    post.image_url,
                    width: 80,
                    height: 80,
                  ),
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
                          fontWeight: FontWeight.bold,
                          fontSize: 12.0,
                          height: 1.3),
                    ),
                    Text(
                      TimeAgo.getTimeAgo(int.parse(post.published_on)),
                      softWrap: true,
                      style: TextStyle(fontSize: 10.0, height: 1.6),
                    ),
                    Text(
                      "",
                      style: TextStyle(fontSize: 10.0, height: 0.2),
                    ),
                    Badge(
                      badgeColor: Colors.black87,
                      shape: BadgeShape.square,
                      borderRadius: 7,
                      toAnimate: true,
                      badgeContent: Text(" " + post.label + " ",
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
