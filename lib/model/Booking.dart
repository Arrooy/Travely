import 'dart:typed_data';

import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_place/google_place.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:travely/model/UserManager.dart';
import 'package:travely/tequila.dart';
import 'package:travely/utils.dart';

import 'LocationManager.dart';

import 'package:firebase_database/firebase_database.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';

// Te una matriu de bookings. Cada posicio de la llista
// Correspon a un filtre (popular destinations, cheapest travels...)
class TrendingsModel extends ChangeNotifier {
  List<Bookings> _bookings;

  //Guarda l'index del filtre seleccionat a trendings
  int _filterSelected;

  List<String> _options;

  PageController pageViewController;


  TrendingsModel() {
    _options = [
      "Popular Destinations",
      "Cheapest Travels",
      "Weekend Scape",
      "Best Quality",
      "Short Flight",
      "Last Minute"
    ];

    _filterSelected = 0;
    pageViewController = new PageController();
    _bookings = List<Bookings>();
  }

  List<String> get options => _options;

  int get filterSelected => _filterSelected;

  void onSwipe(DragEndDetails details,BuildContext context) {
    double dx = details.velocity.pixelsPerSecond.dx;
    if(dx > 250){
      if(_filterSelected >= 1) onHashtagPressed(context, _filterSelected - 1,animate: false);
    }else if(dx < 250){
      if(_filterSelected < _bookings.length - 1) onHashtagPressed(context, _filterSelected + 1,animate: false);
    }
  }
  void onHashtagPressed(context, index,{bool animate}) async {
    //Fem que la velocitat de l'animacio sigui constant!
    if (_bookings[_filterSelected].currentPage != 0){
      if(animate == null || animate){
        await pageViewController.animateToPage(0,
            duration: Duration(
                milliseconds: 1000 ),
            curve: Curves.easeInOut);

      }else{
        pageViewController.jumpToPage(0);
      }
    }

    // Borrem totes les fotos (Menys les primeres 2) per no gastar tota la memoria del telef.
    // En un rato el garbage collector s'ocupará.
    int i = 0;
    for (var bk in _bookings[_filterSelected].list){
      if(i > 1) bk.image = null;
      i++;
    }

    _filterSelected = index;
    _bookings[_filterSelected]._currentPage = 0;

    _bookings[_filterSelected].list[0].requestHashtags();
    _bookings[_filterSelected].list[0].requestImage(context);

    await _bookings[_filterSelected].list[0].updateFavFromFirebase(context);
    _bookings[_filterSelected].requestNextPageVariableData(context);

    notifyListeners();
  }

  Future<void> newTrendPageIndex(int index, BuildContext context) async{
    // Si arreivem a l'ulitim booking, no adelantis el index. Mostra el missatge.
    if (_bookings[_filterSelected].list.length > index) {
      _bookings[_filterSelected].currentPage = index;

      //Demanem el hastag i l'imatge de la seguent pagina.
      _bookings[_filterSelected].requestNextPageVariableData(context);

      //No mostrem res de la nova pagina fins que no sapiguem si es fav o no.
      await current.updateFavFromFirebase(context);
    }
  }

  // Si bk esta definit comporta que volem donar like a bk i no al current id.
  // S'empra bk quan l'uusari interactua amb una preview.
  void favButton(BuildContext ctx, {Booking bk}) {
    Booking workingBooking = bk == null ? current : bk;

    String username = Provider.of<UserManager>(ctx,listen: false).email.split('@')[0];
    var ref = FirebaseDatabase.instance.reference().child("$username/").child(workingBooking.id);

    if (workingBooking.fav) {
      // S'ha de treure de fav
      ref.remove();

      print("Disliked ${workingBooking.destination}");
    }else{
      // S'ha d'afegir
      ref.set(workingBooking.createSet());

      print("liked ${workingBooking.destination}");
    }

    // Toogle del fav.
    workingBooking.favButton();
    notifyListeners();
  }

  Booking get current => _bookings[_filterSelected].current;
  Bookings get currentFilter => _bookings[_filterSelected];

  // Ompla tot el model.
  // Inicialment obté l'ubicació de l'usuari amb el SDK de Geolocator
  // Basat en la localització, busca la informació sobre vols amb la loc.ç
  // origen actual

  // Retorna true si tot esta correcte.
  // Retorna false si hi ha algun problema.
  Future<bool> requestAndUpdateData(BuildContext ctx) async {
    if (_bookings.isNotEmpty) return true;

    LocationManager locationManager =
        Provider.of<LocationManager>(ctx, listen: false);
    Position pos = await locationManager.getPosition(LocationAccuracy.low);

    int airportLimit = 5;
    int resultLimit = 5;

    List<String> nearAirports = await Tequila.searchAirportsNearPos(pos, airportLimit);

    Bookings popularDest =
        await Tequila.searchPopularDestinations(pos, nearAirports, resultLimit,ctx);
    Bookings cheapestTravel =
        await Tequila.searchCheapestTravel(pos, nearAirports, resultLimit,ctx);
    Bookings weekendScape =
        await Tequila.searchWeekendScape(pos, nearAirports, resultLimit,ctx);
    Bookings bestQuality =
        await Tequila.searchBestQuality(pos, nearAirports, resultLimit,ctx);
    Bookings shortFlight =
        await Tequila.searchShortFlight(pos, nearAirports, resultLimit,ctx);
    Bookings lastMinute =
        await Tequila.searchLastMinute(pos, nearAirports, resultLimit,ctx);


    _bookings.add(popularDest);
    _bookings.add(cheapestTravel);
    _bookings.add(weekendScape);
    _bookings.add(bestQuality);
    _bookings.add(shortFlight);
    _bookings.add(lastMinute);
    return true;
  }


}

// Guarda els bookings d'un tipo de filtre.
class Bookings extends ChangeNotifier {
  List<Booking> list;
  int _currentPage;

  Bookings(this.list, BuildContext context){
    _currentPage = 0;
    this.list[0].requestHashtags();
    this.list[0].requestImage(context);
    this.list[0].updateFavFromFirebase(context);
    requestNextPageVariableData(context);
  }
/*
    String username = Provider.of<UserManager>(ctx,listen: false).email.split('@')[0];
    var ref = FirebaseDatabase.instance.reference().child("$username/").child(current.id).once();
    */
  Booking get current => list[_currentPage];
  int get currentPage => _currentPage;

  set currentPage(int value) {
    _currentPage = value;
  }

  void requestNextPageVariableData(BuildContext context) {
    int nextIndex = _currentPage + 1;
    if(nextIndex < list.length - 1){

      this.list[nextIndex].requestHashtags();
      this.list[nextIndex].requestImage(context);
    }
  }

}

// Defineix un booking.
class Booking extends ChangeNotifier {
  String id;

  String destination;
  String shortDestination;

  String origin;
  String shortOrigin;

  int price;

  Future<List<String>> hashtags;

  DateTime _departureTime;

  bool fav;
  Future<Uint8List> image;

  bool isEnd;

  Position position;

  void fromJson(Map<String, dynamic> json, {Position position}) {
    // Booking booking = new Booking();
    this.origin = json["cityFrom"];
    this.shortOrigin = json["flyFrom"];

    this.destination = json["cityTo"];
    this.shortDestination = json["flyTo"];

    this.id = json["id"];

    this._departureTime = DateTime.parse(json["local_departure"]);

    this.price = json["price"];

    this.position = position;

    this.fav = false;
    this.isEnd = false;
  }

  void requestHashtags(){
    if(this.destination != null)
      this.hashtags = requestHashTags(this.shortDestination);
  }

  void requestImage(BuildContext context) {
    if(this.image == null && this.destination != null)
    this.image = requestImageFromGoogle(this.destination,context);
  }

  void updateFavFromFirebase(BuildContext context) async{

    if(this.destination == null) return;
    String username = Provider.of<UserManager>(context,listen: false).email.split('@')[0];
    var ref = FirebaseDatabase.instance.reference().child("$username/").child(id);
    var result = await ref.once();
    this.fav = (result.value != null);
  }

  void endOfData() {
    this.isEnd = true;
  }

  String get departureTime {
    var formatter = new DateFormat('EEE dd/MM \'at\' h:mm a');
    return formatter.format(_departureTime);
  }

  // Toogle del boto de like.
  void favButton() {
    this.fav = !this.fav;
  }

  // Retorna el set per a guardar-lo a firebase realtime db.
  createSet() {
    return {
      'shortOrigin': shortOrigin,
      'shortDestination': shortDestination,
      'destination': destination,
      'price': price
    };
  }


  @override
  String toString() {
    return 'Booking{destination: $destination, shortDestination: $shortDestination, origin: $origin, shortOrigin: $shortOrigin, departureTime: $_departureTime}';
  }
}

String req(String endpoint, Map<String, dynamic> values) {
  String result = tequilaBaseURL + endpoint + "/?";
  for (var v in values.keys) {
    result += v + "=" + values[v].toString() + "&";
  }
  // Eliminem l'ultim &
  return result.substring(0, result.length - 1);
}
