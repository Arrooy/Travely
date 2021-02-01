import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:travely/ui_utils.dart';

class TlyLogin extends StatelessWidget {
  final Function onPressed;
  final emailController = TextEditingController(text:"miquelsaula@gmail.com");
  final passwordController = TextEditingController(text: "123456");

  TlyLogin({this.onPressed});

  Widget build(BuildContext buildContext){
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Spacer(flex: 2,),
          Image.asset("assets/images/logo.png"),
          Spacer(flex: 1,),
          TlyForm(Icons.person, "E-Mail", false, emailController),
          TlyForm(Icons.lock, "Password", true, passwordController),
          Spacer(flex: 1,),
          TlyButton("Sign In", () => this.onPressed(context: buildContext, email: emailController.text.trim(), password: passwordController.text.trim())),
          Spacer(flex: 2,),
        ],
      ),
    );
  }
}