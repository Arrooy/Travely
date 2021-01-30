import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class TlyButton extends StatelessWidget {
  final String text;
  const TlyButton(this.text);

  @override
  Widget build(BuildContext buildContext) {
    return Padding(
      padding: EdgeInsets.all(10),
      child: GestureDetector(
          onTap: () => print("Button pressed"),
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

class TlyForm extends StatelessWidget {
  final IconData icon;
  final String text;
  final bool isPassword;
  TlyForm(this.icon, this.text, this.isPassword);

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
              obscureText: isPassword,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                  icon: Icon(
                    icon,
                    color: Colors.white,
                  ),
                  border: InputBorder.none,
                  hintText: text,
                  hintStyle:
                      const TextStyle(color: Colors.white, fontSize: 15.0),
                  contentPadding: const EdgeInsets.only(
                      top: 30.0, right: 30.0, bottom: 30.0, left: 5.0)),
            ),
          ),
        ));
  }
}
