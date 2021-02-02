import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:travely/model/UserManager.dart';
import 'package:travely/utils.dart';

import 'LocationManager.dart';

import 'package:firebase_database/firebase_database.dart';

import 'package:http/http.dart' as http;
import 'dart:io';
import 'dart:convert';

// Te una matriu de bookings. Cada posicio de la llista
// Correspon a un filtre (popular destinations, cheapest travels...)
class TrendingsModel extends ChangeNotifier{
  List<Bookings> _bookings;

  //Guarda l'index del filtre seleccionat a trendings
  int _filterSelected;

  List<String> _options;

  TrendingsModel() {
    _options =  ["Popular Destinations","Cheapest Travels",
      "Weekend Scape",
      "Best Quality",
      "Short Flight"];

    _filterSelected = 0;

    _bookings = List<Bookings>();

    //
    // var list = List<Booking>();
    // var hastags = List<String>();
    // hastags.add("Amor");
    // hastags.add("Pasion");
    // hastags.add("Desenredo");
    //
    // list.add(new Booking("Canarias",150,hastags,new DateTime.now(),false,0));
    // list.add(new Booking("Uebon",5,hastags,new DateTime.now(),false,0));

  }

  List<String> get options => _options;

  int get filterSelected => _filterSelected;

  set filterSelected(int value) {
    _filterSelected = value;
    notifyListeners();
  }

  set newTrendPageIndex(int index) => _bookings[_filterSelected].currentPage = index;

  void favButton(BuildContext ctx) {

    Bookings bks = _bookings[_filterSelected];
    Booking current = bks.list[bks.currentPage];

    if(current.fav){
      // S'ha de treure de fav
      _bookings.last.list.remove(current);
    }else{
      // S'ha d'afegir
      _bookings.last.list.add(current);
    }

    String userEmail = Provider.of<UserManager>(ctx,listen: false).email;
    var ref = FirebaseDatabase().reference().child(userEmail);


    ref.child(current.id.toString()).set(current.createSet());
    // TODO: SAULA.
    // https://medium.com/codechai/realtime-database-in-flutter-bef0f29e3378

    // Toogle del fav.
    current.favButton();
    notifyListeners();
  }

  Booking get current => _bookings[_filterSelected].current;

  // Ompla tot el model.
  // Inicialment obté l'ubicació de l'usuari amb el SDK de Geolocator
  // Basat en la localització, busca la informació sobre vols amb la loc.ç
  // origen actual

  // Retorna true si tot esta correcte.
  // Retorna false si hi ha algun problema.
  Future<bool> requestAndUpdateData(BuildContext ctx) async{

    LocationManager locationManager = Provider.of<LocationManager>(ctx, listen: false);
    Position pos = await locationManager.getPosition(LocationAccuracy.low);

    Bookings popularDest    = await searchPopularDestinations(pos);
    Bookings cheapestTravel = await searchCheapestTravel(pos);
    Bookings weekendScape   = await searchWeekendScape(pos);
    Bookings bestQuality    = await searchBestQuality(pos);
    Bookings shortFlight    = await searchShortFlight(pos);

    // TOdo: Afegir sort by Date.

    if(_bookings.isNotEmpty)print("Bookings not empty!");

    _bookings.add(popularDest);
    _bookings.add(cheapestTravel);
    _bookings.add(weekendScape);
    _bookings.add(bestQuality);
    _bookings.add(shortFlight);
    return true;
  }

  // TODO: Es recomana fer el parsing del json en unaltre thread.
  // https://flutter.dev/docs/cookbook/networking/background-parsing
  searchPopularDestinations(Position pos) async {
    List<Booking> bookingList = [];

    final response = await http.get(
        'https://tequila-api.kiwi.com/locations/topdestinations',
        headers: {HttpHeaders.authorizationHeader: tequilaApiToken});

    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON
      var json = jsonDecode(response.body);

      return Bookings(bookingList);
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to load song');
    }
  }

  searchShortFlight(Position pos) {

  }

  searchBestQuality(Position pos) {

  }

  searchWeekendScape(Position pos) {

  }


  searchCheapestTravel(Position pos) {

  }


}
// Guarda els bookings d'un tipo de filtre.
class Bookings extends ChangeNotifier{
  List<Booking> list;
  int _currentPage;

  int get currentPage => _currentPage;


  set currentPage(int value) {
    _currentPage = value;
  }

  Bookings(this.list):_currentPage = 0;

  Booking get current => list[_currentPage];
}

// Defineix un booking.
class Booking extends ChangeNotifier{
  int id;
  String destination;
  String shortName;

  String image;
  int price;
  List<String> hashtags;
  DateTime departureTime;
  bool fav;

  Booking(this.destination, this.price, this.hashtags, this.departureTime,
      this.fav);

  void favButton(){
      this.fav = !this.fav;
      notifyListeners();
  }

  // Retorna el set per a guardar-lo a firebase realtime db.
  createSet() {
    return {
      'shortName': shortName,
      'price': price,
      'departureTime':departureTime
    };
  }
}

