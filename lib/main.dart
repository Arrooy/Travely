import 'package:chewie/chewie.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import 'package:travely/background_video.dart';
import 'package:flutter/services.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIOverlays ([]);
  runApp(Travely());
}

class Travely extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Travely',
      home: Scaffold(
        // appBar: AppBar(
        //   title: Text('Welcome to Flutter'),
        // ),
        body: BackgroundVideo("Vacation Travel Traveling Hot")
      ),
    );
  }
}
