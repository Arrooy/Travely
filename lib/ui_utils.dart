import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:travely/authentication_service.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
class TlyButton extends StatelessWidget {
  final String text;
  final Function onPressed;
  const TlyButton(this.text, [this.onPressed]);

  @override
  Widget build(BuildContext buildContext) {
    return Padding(
      padding: EdgeInsets.all(10),
      child: GestureDetector(
          onTap: onPressed,
          child: Container(
              width: 200,
              height: 60.0,
              alignment: FractionalOffset.center,
              decoration: new BoxDecoration(
                color: const Color.fromRGBO(247, 64, 106, 1.0),
                borderRadius: BorderRadius.all(const Radius.circular(30.0)),
              ),
              child: Text(
                this.text,
                style: new TextStyle(
                  color: Colors.white,
                  fontSize: 20.0,
                  fontWeight: FontWeight.w300,
                  letterSpacing: 0.3,
                ),
              ))),
    );
  }
}

class TlyForm extends StatefulWidget {
  final IconData icon;
  final String text;
  final bool isPassword;
  final textController;
  TlyForm(this.icon, this.text, this.isPassword, this.textController);

  @override
  _TlyFormState createState() => _TlyFormState();
}

class _TlyFormState extends State<TlyForm> {
  @override
  void dispose() {
    widget.textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.all(10),
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 20.0),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(const Radius.circular(10.0)),
              color: Color.fromRGBO(50, 50, 50, 0.6),
            ),
            child: TextFormField(

              controller: widget.textController,
              obscureText: widget.isPassword,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                  prefixIcon: Icon(
                    widget.icon,
                    color: Colors.white,
                  ),
                  border: InputBorder.none,
                  hintText: widget.text,
                  hintStyle:
                      const TextStyle(color: Colors.white, fontSize: 15.0),
                  contentPadding: const EdgeInsets.only(
                      top: 30.0, right: 30.0, bottom: 30.0, left: 5.0)),
            ),
          ),
        ));
  }
}


Widget snackBar(String message, String button, BuildContext context, Function onPressed) {

  return SnackBar(
    content: Text(message),
    action: SnackBarAction(
        label: button,
        onPressed: () => onPressed(context)
    ),
  );
}

Widget snackBarSimple(String message) {
  return SnackBar(
    content: Text(message),
  );
}

Widget futureInlineLoading() {
  return Row(
    mainAxisSize: MainAxisSize.max,
    children: <Widget>[SpinKitThreeBounce(
        size: 50,
        color: Colors.white,
      )],
  );
}


Widget futureLoading(String message) {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        SizedBox(
          child: CircularProgressIndicator(),
          width: 60,
          height: 60,
        ),
        Padding(
          padding: EdgeInsets.only(top: 16),
          child: Text(message),
        )
      ],
    ),
  );
}


Widget futureError(error){
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Icon(
          Icons.error_outline,
          color: Colors.red,
          size: 60,
        ),
        Padding(
          padding: const EdgeInsets.only(top: 16),
          child: Text('Error: $error'),
        )
      ],
    ),
  );
}


Widget homeDrawer(BuildContext context){
 return  Drawer(
    elevation: 5,
    child: ListView(
      // Important: Remove any padding from the ListView.
      padding: EdgeInsets.zero,

      children: <Widget>[
        DrawerHeader(
            margin: EdgeInsets.zero,
            padding: EdgeInsets.zero,
            // decoration: BoxDecoration(
            // image: DecorationImage(
            //     fit: BoxFit.fill,
            //     image:  Image.network('path/to/header_background.png'))),
            child: Stack(children: <Widget>[
              Positioned(
                  bottom: 12.0,
                  left: 16.0,
                  child: Text("Account settings",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 20.0,
                          fontWeight: FontWeight.w500))),
            ])),
        ListTile(
          title: Text('Delete all bookings'),
          onTap: () {},
        ),
        ListTile(
          title: Text('LogOut'),
          onTap: () {
            Provider.of<AuthenticationService>(context, listen: false)
                .signOut();
            Navigator.pushReplacementNamed(context, '/', arguments: true);
          },
        ),
      ],
    ),
  );
}