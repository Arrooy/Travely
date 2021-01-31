import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:travely/ui_utils.dart';

class TlyLogin extends StatelessWidget {
  Widget build(BuildContext buildContext){
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TlyForm(Icons.person, "Username", false),
          TlyForm(Icons.lock, "Password", true),
          TlyButton("Sign In"),
        ],
      ),
    );
  }
}