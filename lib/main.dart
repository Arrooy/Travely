import 'package:chewie/chewie.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:travely/map.dart';
import 'package:travely/ui_utils.dart';
import 'package:video_player/video_player.dart';

import 'package:travely/background_video.dart';
import 'package:flutter/services.dart';

import 'package:travely/home.dart';

import 'model/login.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIOverlays([]);
  runApp(Travely());
}

class Travely extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      title: 'Travely',
      theme:  new ThemeData(

      brightness: Brightness.dark,
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        foregroundColor: Colors.white,
        backgroundColor: Colors.red,
        splashColor: Colors.redAccent
      ),
    ),
        initialRoute: '/',
        routes: {
          '/': (context) => LogInScreen(),
          '/home': (context) => Home(),
        });

  }
}

class LogInScreen extends StatefulWidget {

  @override
  _LogInScreenState createState() => _LogInScreenState();
}

class _LogInScreenState extends State<LogInScreen> {
  BackgroundVideo backgroundVideo = BackgroundVideo(
      "fun");
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(children: [
        backgroundVideo,
        TlyLogin(),
        RaisedButton(onPressed: (){
          Navigator.pushReplacementNamed(context, '/home');
        },
          child: Text("Enter Home"),)
      ],),
      backgroundColor: Colors.white,
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
