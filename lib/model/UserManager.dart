import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class UserManager{
  String _email;

  UserManager():_email = "";

  String get email => _email;
  set email(String value) => _email = value;
}