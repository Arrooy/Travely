import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

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
        onPressed: () => onPressed
    ),
  );
}

Widget snackBarSimple(String message) {
  return SnackBar(
    content: Text(message),
  );
}