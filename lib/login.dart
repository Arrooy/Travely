import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:travely/ui_utils.dart';

class TlyLogin extends StatelessWidget {

  TlyLogin({Function onPressed});

  Widget build(BuildContext buildContext){
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Spacer(flex: 2,),
          Image.asset("assets/images/logo.png"),
          Spacer(flex: 1,),
          TlyForm(Icons.person, "Username", false),
          TlyForm(Icons.lock, "Password", true),
          Spacer(flex: 1,),
          TlyButton("Sign In"),
          Spacer(flex: 2,),
        ],
      ),
    );
  }

}