import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:raygun_test/raygun_service.dart';

Future<Null> main() async {
  // This captures errors reported by the Flutter framework.
  FlutterError.onError = (FlutterErrorDetails details) async {
    FlutterError.dumpErrorToConsole(details);
    Zone.current.handleUncaughtError(details.exception, details.stack);
  };

  runZoned<Future<Null>>(() async {
    runApp(new MyApp());
  }, onError: (error, stackTrace) async {
    RaygunService().sendCrashReport(error, stackTrace);
  });
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  RaygunService raygunService = new RaygunService();

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text('Crashy'),
      ),
      body: new Center(
        child: new Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            new RaisedButton(
              child: new Text('Dart exception'),
              elevation: 1.0,
              onPressed: () {
                throw new StateError('This is a Dart exception.');
              },
            ),
            new RaisedButton(
              child: new Text('async Dart exception'),
              elevation: 1.0,
              onPressed: () async {
                foo() async {
                  throw new StateError('This is an async Dart exception.');
                }

                bar() async {
                  await foo();
                }

                await bar();
              },
            ),
            new RaisedButton(
              child: new Text('Java exception'),
              elevation: 1.0,
              onPressed: () async {
                final channel = const MethodChannel('crashy-custom-channel');
                await channel.invokeMethod('blah');
              },
            ),
          ],
        ),
      ),
    );
  }
}

class RaygunRequest {}