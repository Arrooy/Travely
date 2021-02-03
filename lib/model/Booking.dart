import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
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
    String username = Provider.of<UserManager>(ctx,listen: false).email.split('@')[0];
    var ref = FirebaseDatabase.instance.reference().child("${username}/").child(current.id);

    if(current.fav){
      // S'ha de treure de fav
      _bookings.last.list.remove(current);
      ref.remove();
    }else{
      // S'ha d'afegir
      _bookings.last.list.add(current);
      ref.set(current.createSet());
    }

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

    final stopwatch = Stopwatch()..start();
    Bookings popularDest    = await searchPopularDestinations(pos);
    print('searchPopularDestinations() executed in ${stopwatch.elapsed}');

    Bookings cheapestTravel = await searchCheapestTravel(pos);
    Bookings weekendScape   = await searchWeekendScape(pos);
    Bookings bestQuality    = await searchBestQuality(pos);
    Bookings shortFlight    = await searchShortFlight(pos);

    // TOdo: Afegir sort by Date.

    if(_bookings.isNotEmpty) _bookings.clear();

    _bookings.add(popularDest);
    // _bookings.add(cheapestTravel);
    // _bookings.add(weekendScape);
    // _bookings.add(bestQuality);
    // _bookings.add(shortFlight);

    return true;
  }

  // TODO: Es recomana fer el parsing del json en unaltre thread.
  // https://flutter.dev/docs/cookbook/networking/background-parsing
  searchPopularDestinations(Position pos) async {
    List<Booking> bookingList = [];

    List<String> nearAirports = await searchAirportsNearPos(pos);
    List<String> popularDestinations = await bestDestinationsFromNearAirports(nearAirports);
    bookingList = await searchFlightsToDestinations(nearAirports,popularDestinations);

    return Bookings(bookingList);
  }

  Future<List<Booking>> searchFlightsToDestinations( List<String> nearAirports, List<String> popularDestinations) async{
    List<Booking> bookingList = [];

    //Aeroports de sortida -> format de la Api: A,B,C
    String nearAirportsReq = nearAirports.toString().replaceAll(" ", "");
    nearAirportsReq = nearAirportsReq.substring(1,nearAirportsReq.length - 1);

    // Destinacions format de api: A,B,C
    String popularDestinationsReq = popularDestinations.toString().replaceAll(" ", "");
    popularDestinationsReq = popularDestinationsReq.substring(1,popularDestinationsReq.length - 1);

    // Busquem vols desde avui, fins d'aqui 7 dies
    var now = new DateTime.now();
    var formatter = new DateFormat('dd/MM/yyyy');
    var oneWeekFromNow = now.add(new Duration(days: 30));

    // Fem la peticio al backend
    final response = await http.get(req('/v2/search',{
      "fly_from":nearAirportsReq,
      "fly_to": popularDestinationsReq,
      "dateFrom":formatter.format(now),
      "dateTo":formatter.format(oneWeekFromNow),
      "flight_type":"oneway",
      "one_for_city":1,
      "sort":"date",
      "vehicle_type":"aircraft"
    }), headers: {'apikey': "QEiR_0FuSG8t7MquzDjz3LrLPqXDTXsW"});

    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON

      var json = jsonDecode(response.body);
      for (var data in json["data"]){
        bookingList.add(Booking()..fromJson(data));
      }

      return bookingList;
    } else {
      debugPrint("Error!! ${response.body}");
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to load song');
    }
  }

  // Obte totes les destinacions populars dels aeroports introduits.
  // Automaticament elimina les repeticions.
  Future<List<String>> bestDestinationsFromNearAirports(List<String> nearAirports) async {
    List<Future<List<String>>> popularDestinations = [];

    // Per a cada aeroport busquem les destinacions més populars
    for(var airport in nearAirports){
      popularDestinations.add(popularDestinationsFromPlace(airport));
    }

    // Un cop s'han fet totes les crides, esperem a tenir la info.
    List<String> result = [];
    for (var future in popularDestinations){
      result.addAll(await future);
    }

    // Borrem els duplicats obtinguts.
    return result.toSet().toList();
  }

  /*
  Mateixa funcio sense optimitzar. Cada request de api es sincrona. Malament!

  Future<List<String>> bestDestinationsFromNearAirports(List<String> nearAirports) async {
    List<String> popularDestinations = [];
    for(var airport in nearAirports){
      List<String> newDestinations = await popularDestinationsFromPlace(airport);
      popularDestinations.addAll(newDestinations);
    }
    return popularDestinations.toSet().toList();
  }
  */


  // Retorna una llista amb les destinacions més populars
  Future<List<String>> popularDestinationsFromPlace(String airport) async{
    List<String> result = [];
    final response = await http.get(req('/locations/topdestinations',{
      "term":airport,
      "limit":5,
      "locale":"en-US",//"es-ES",
      "active_only":true
    }), headers: {'apikey': tequilaApiToken});

    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON
      var json = jsonDecode(response.body);
      for (var loc in json["locations"]){
        result.add(loc["id"]);
      }

      return result;
    } else {
      debugPrint("Error!! ${response.body}");
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to load song');
    }
  }

  Future<List<String>> searchAirportsNearPos(Position pos) async{
    List<String> result = [];
    final response = await http.get(req('/locations/radius',{
      "lat":pos.latitude,
      "lon":pos.longitude,
      "radius":250,
      "location_types":"airport",
      "limit":5,
      "locale":"en-US",
      "active_only":true
    }), headers: {'apikey': tequilaApiToken});

    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON
      var json = jsonDecode(response.body);
      for (var loc in json["locations"]){
        result.add(loc["id"]);
      }

      return result;
    } else {
      debugPrint("Error!! ${response.body}");
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

  String id;

  String destination;
  String shortDestination;

  String origin;
  String shortOrigin;

  int price;

  List<String> hashtags;

  DateTime _departureTime;

  bool fav;
  String image;

  void fromJson(Map<String,dynamic> json){
    // Booking booking = new Booking();
    this.origin = json["cityFrom"];
    this.shortOrigin = json["flyFrom"];

    this.destination = json["cityTo"];
    this.shortDestination = json["flyTo"];

    this.id = json["id"];
    this.hashtags = ["Hi"];

    //Todo: Verificar la data.
    this._departureTime = DateTime.parse(json["utc_departure"]);

    this.price = json["price"];

    this.image = 'https://picsum.photos/${200 + Random().nextInt(30)}/300/?random'; //"https://images.unsplash.com/photo-1516483638261-f4dbaf036963?ixlib=rb-1.2.1&ixid=MXwxMjA3fDB8MHxleHBsb3JlLWZlZWR8MXx8fGVufDB8fHw%3D&w=1000&q=80";

    this.fav = false;
    print(this);
  }


  String get departureTime{
    var formatter = new DateFormat('EEE dd/MM \'at\' h:mm a');
    return formatter.format(_departureTime);
  }

  // Toogle del boto de like.
  void favButton(){
      this.fav = !this.fav;
      notifyListeners();
  }

  // Retorna el set per a guardar-lo a firebase realtime db.
  createSet() {
    return {
      'shortOrigin': shortOrigin,
      'shortDestination':shortDestination,
      'price': price,
      'departureTime':_departureTime,
      'imageUrl': image
    };
  }

  @override
  String toString() {
    return 'Booking{destination: $destination, shortDestination: $shortDestination, origin: $origin, shortOrigin: $shortOrigin, departureTime: $_departureTime}';
  }
}

String req(String endpoint, Map<String,dynamic> values){
  String result = tequilaBaseURL + endpoint + "/?";
  for (var v in values.keys){
    result += v+"="+values[v].toString()+"&";
  }
  // Eliminem l'ultim &
  return result.substring(0, result.length - 1);
}
