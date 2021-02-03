import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:travely/ui_utils.dart';

class SignInSignUp extends StatefulWidget {
  final Function onPressed;
  final emailController = TextEditingController(text:"miquelsaula@gmail.com");
  final passwordController = TextEditingController(text: "123456");

  SignInSignUp({this.onPressed});

  @override
  _SignInSignUpState createState() => _SignInSignUpState();
}

class _SignInSignUpState extends State<SignInSignUp> {
  bool isSignUp = false;

  Widget build(BuildContext buildContext){
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Spacer(flex: 2,),
          Image.asset("assets/images/logo.png"),
          Spacer(flex: 1,),
          TlyForm(Icons.person, "E-Mail", false, widget.emailController),
          TlyForm(Icons.lock, "Password", true, widget.passwordController),
          Spacer(flex: 1,),
          TlyButton((!isSignUp) ? "Sign In" : "Sign Up", () => {
            widget.onPressed(
                context: buildContext,
                email: widget.emailController.text.trim(),
                password: widget.passwordController.text.trim(),
                isSignUp: isSignUp
            )}),
          GestureDetector(
              onTap: () => {
                //print("Text tapped!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
                setState(() => isSignUp = !isSignUp)
              },
              child: Text((!isSignUp) ? "No account? Click to sign up!" : "Already have an account? Click to sign in!")),
          Spacer(flex: 2,),
        ],
      ),
    );
  }
}