import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Bookings extends ChangeNotifier{
  List<Booking> bookings;




}



class Booking extends ChangeNotifier{
  String destination;
  int price;
  List<String> hashtags;
  DateTime departureTime;
  bool fav;



}