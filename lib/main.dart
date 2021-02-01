import 'package:chewie/chewie.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:travely/GenericDialog.dart';
import 'package:travely/model/LocationManager.dart';
import 'package:travely/map.dart';
import 'package:travely/model/LocationManager.dart';
import 'package:travely/ui_utils.dart';
import 'package:video_player/video_player.dart';

import 'package:travely/background_video.dart';
import 'package:flutter/services.dart';

import 'package:travely/home.dart';

import 'login.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIOverlays([]);
  runApp(Travely());
}

class Travely extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Es posa un listener per a fer dispose del teclat quan el fa qualsevol acció fora d'aquest.
    return Listener(
      onPointerDown: (_) {
        FocusScopeNode currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus && currentFocus.focusedChild != null) {
          FocusManager.instance.primaryFocus.unfocus();
        }
      },
      child: MultiProvider(
        providers: [
          Provider(create: (context) => new LocationManager())
        ],
        child: MaterialApp(
            title: 'Travely',
            theme: new ThemeData(
              brightness: Brightness.dark,
              floatingActionButtonTheme: FloatingActionButtonThemeData(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.red,
                  splashColor: Colors.redAccent),
            ),
            initialRoute: '/',
            routes: {
              '/': (context) => LogInScreen(),
              '/home': (context) => Home(),
            }),
      ),
    );
  }
}

class LogInScreen extends StatefulWidget {
  @override
  _LogInScreenState createState() => _LogInScreenState();
}

class _LogInScreenState extends State<LogInScreen> {

  BackgroundVideo backgroundVideo = BackgroundVideo("horror");

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        key:_scaffoldKey,
        children: [
          backgroundVideo,
          TlyLogin( onPressed: () => _processSignIn(context)),
          Builder(
              builder: (context) => RaisedButton(
              onPressed: () {
                _processSignIn(context);
              },
              child: Text("Enter Home"),
            ),
          )
        ],
      ),
      backgroundColor: Colors.white,
    );
  }

  void _processSignIn(BuildContext context) async{

    // Quidado es async. Tenir-ho en compte. Si tot es correcte, s'executa el callback
    LocationManager locationManager = Provider.of<LocationManager>(context, listen: false);

    await locationManager.mustHaveLocationDialogs(context,() async{
      Position position = await locationManager.getPosition(LocationAccuracy.medium);
      print("Current position is " + (position == null ? 'Unknown' : position.latitude.toString() + ', ' + position.longitude.toString()));
      return locationManager;
    });
  }

  @override
  void dispose() {
    super.dispose();
  }
}
