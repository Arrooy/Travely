import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:travely/authentication_service.dart';
import 'package:travely/model/LocationManager.dart';
import 'package:travely/ui_utils.dart';

import 'package:travely/background_video.dart';
import 'package:flutter/services.dart';

import 'package:travely/home.dart';

import 'login.dart';
import 'model/Booking.dart';
import 'model/UserManager.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIOverlays([]);
  await Firebase.initializeApp();

  runApp(Travely());
}

class Travely extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Es posa un listener per a fer dispose del teclat quan el fa qualsevol acció fora d'aquest.
    return Listener(
      onPointerDown: (_) {
        FocusScopeNode currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus &&
            currentFocus.focusedChild != null) {
          FocusManager.instance.primaryFocus.unfocus();
        }
      },
      child: MultiProvider(
        providers: [
          Provider<LocationManager>(create: (_) => new LocationManager()),
          Provider<AuthenticationService>(
              create: (_) => AuthenticationService(FirebaseAuth.instance)),
          StreamProvider<User>(create: (context)=>Provider.of<AuthenticationService>(context,listen:false).authStateChanges),
          ListenableProvider<TrendingsModel>( create: (_) => new TrendingsModel(),),
          Provider<UserManager>(create: (_)=> new UserManager(),)
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
  BackgroundVideo backgroundVideo = BackgroundVideo("summer travel barcelona");

  @override
  Widget build(BuildContext context) {
    final bool commingFromHome = ModalRoute.of(context).settings.arguments;

    if(commingFromHome == null || !commingFromHome) {
      User user = Provider.of<User>(context, listen: false);
      if (user != null) {
        Provider.of<UserManager>(context,listen: false).email = user.email;

        WidgetsBinding.instance.addPostFrameCallback((_) {
          _beforeSignInCheck(context: context);
        });
      }
    }

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          backgroundVideo,
          SignInSignUp(onPressed: _beforeSignInCheck)
        ],
      ),
      backgroundColor: Colors.white,
    );
  }

  void _processSignIn({BuildContext context, String email, String password, bool isSignUp}) async {
    String result;
    if (isSignUp) result = await context.read<AuthenticationService>().signUp(email: email, password: password);
    else          result = await context.read<AuthenticationService>().signIn(email: email, password: password);
    if (result != "success") {
      Scaffold.of(context).showSnackBar(snackBarSimple(result));
      return;
    }
    Navigator.pushReplacementNamed(context, '/home');
  }

  void _beforeSignInCheck({BuildContext context, String email, String password, bool isSignUp}) async{
    // Si tota la config de localitzaico es correcte, s'executa el callback
    LocationManager locationManager =
    Provider.of<LocationManager>(context, listen: false);
    await locationManager.mustHaveLocationDialogs(context, (){

      if(email != null && password != null){
        //Sha de fer SignIn/SignUp
        _processSignIn(context: context,email: email,password: password,isSignUp: isSignUp);
      }else{
        // Usuari ja està autenticat. Entrem directament.
        Navigator.pushReplacementNamed(context, '/home');
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }
}