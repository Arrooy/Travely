import 'package:chewie/chewie.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:travely/map.dart';
import 'package:travely/ui_utils.dart';
import 'package:video_player/video_player.dart';

import 'package:travely/background_video.dart';
import 'package:flutter/services.dart';

import 'model/login.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIOverlays([]);
  runApp(Travely());
}

class Travely extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    try {
      BackgroundVideo backgroundVideo = BackgroundVideo("trending");

      return MaterialApp(
        title: 'Travely',
        home: Scaffold(
          // appBar: AppBar(
          //   title: Text('Welcome to Flutter'),
          // ),
          body: Stack(children: <Widget>[
            backgroundVideo,
            TlyLogin(),
          ]),
          backgroundColor: Colors.white,
        ),
      );
    } catch (error) {
      print("ESCALATED TO MAIN!");
    }
  }
}