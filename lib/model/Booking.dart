import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_place/google_place.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:travely/model/UserManager.dart';
import 'package:travely/utils.dart';

import 'LocationManager.dart';

import 'package:firebase_database/firebase_database.dart';

import 'package:http/http.dart' as http;
import 'dart:io';
import 'dart:convert';

// TODO: POSAR UN BOOKING PER DEFECTE AL FINAL DE TOT QUE INDIQUI QUE JA NO HI HAN MES DADES!.
// TODO: Agafar una imatge de google

class Location {
  List<String> _hashtags;
  String _name;

  Location(this._name, this._hashtags);

  String get name => _name;
  List<String> get hashtags => _hashtags;
}

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

  void onHashtagPressed(context, index) async {
    //Fem que la velocitat de l'animacio sigui constant!
    if (_bookings[_filterSelected].currentPage != 0)
      await pageViewController.animateToPage(0,
          duration: Duration(
              milliseconds: 500 * _bookings[_filterSelected].currentPage),
          curve: Curves.easeInOut);

    // Borrem totes les fotos (Menys les primeres 2) per no gastar tota la memoria del telef.
    // En un rato el garbage collector s'ocupará.
    int i = 0;
    for (var bk in _bookings[_filterSelected].list){
      if(i > 1) bk.image = null;
      i++;
    }

    _filterSelected = index;

    _bookings[_filterSelected].list[0].requestHashtags();
    _bookings[_filterSelected].list[0].requestImage(context);
    _bookings[_filterSelected].requestNextPageVariableData(context);

    notifyListeners();
  }

  void newTrendPageIndex(int index, BuildContext context) {
    // Si arreivem a l'ulitim booking, no adelantis el index. Mostra el missatge.
    if (_bookings[_filterSelected].list.length > index) {
      _bookings[_filterSelected].currentPage = index;

      //Demanem el hastag i l'imatge de la seguent pagina.
      _bookings[_filterSelected].requestNextPageVariableData(context);
    }
  }

  void favButton(BuildContext ctx) {
    Bookings bks = _bookings[_filterSelected];
    Booking current = bks.list[bks.currentPage];

    if (current.fav) {
      // S'ha de treure de fav
      _bookings.last.list.remove(current);
    } else {
      // S'ha d'afegir
      _bookings.last.list.add(current);
    }

    // Toogle del fav.
    current.favButton();
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

    List<String> nearAirports = await searchAirportsNearPos(pos, airportLimit);

    Bookings popularDest =
        await searchPopularDestinations(pos, nearAirports, resultLimit,ctx);
    Bookings cheapestTravel =
        await searchCheapestTravel(pos, nearAirports, resultLimit,ctx);
    Bookings weekendScape =
        await searchWeekendScape(pos, nearAirports, resultLimit,ctx);
    Bookings bestQuality =
        await searchBestQuality(pos, nearAirports, resultLimit,ctx);
    Bookings shortFlight =
        await searchShortFlight(pos, nearAirports, resultLimit,ctx);
    Bookings lastMinute =
        await searchLastMinute(pos, nearAirports, resultLimit,ctx);

    _bookings.add(popularDest);
    _bookings.add(cheapestTravel);
    _bookings.add(weekendScape);
    _bookings.add(bestQuality);
    _bookings.add(shortFlight);
    _bookings.add(lastMinute);

    return true;
  }

  searchPopularDestinations(
      Position pos, List<String> nearAirports, int resultLimit, BuildContext context) async {
    List<Booking> bookingList = [];

    List<String> popularDestinations =
        await bestDestinationsFromNearAirports(nearAirports, resultLimit);
    bookingList = await searchFlightsToDestinations(nearAirports,
        popularDestinations: popularDestinations);

    bookingList.add(Booking()..endOfData());
    return Bookings(bookingList,context);
  }

  searchCheapestTravel(
      Position pos, List<String> nearAirports, int resultLimit, BuildContext context) async {
    List<Booking> bookingList = [];
    bookingList = await searchFlightsToDestinations(nearAirports,
        sort: "price", dayRange: 7);

    bookingList.add(Booking()..endOfData());
    return Bookings(bookingList,context);
  }

  searchShortFlight(
      Position pos, List<String> nearAirports, int resultLimit, BuildContext context) async {
    List<Booking> bookingList = [];
    bookingList = await searchFlightsToDestinations(nearAirports,
        sort: "duration", dayRange: 7);

    bookingList.add(Booking()..endOfData());
    return Bookings(bookingList,context);
  }

  searchBestQuality(
      Position pos, List<String> nearAirports, int resultLimit, BuildContext context) async {
    List<Booking> bookingList = [];
    bookingList = await searchFlightsToDestinations(nearAirports,
        sort: "quality", dayRange: 7);

    bookingList.add(Booking()..endOfData());
    return Bookings(bookingList,context);
  }

  searchWeekendScape(
      Position pos, List<String> nearAirports, int resultLimit, BuildContext context) async {
    List<Booking> bookingList = [];
    bookingList = await searchFlightsToDestinations(nearAirports,
        onlyWeekends: true, sort: "date", dayRange: 7);

    bookingList.add(Booking()..endOfData());
    return Bookings(bookingList,context);
  }

  searchLastMinute(
      Position pos, List<String> nearAirports, int resultLimit, BuildContext context) async {
    List<Booking> bookingList = [];
    bookingList = await searchFlightsToDestinations(nearAirports,
        sort: "date", dayRange: 0);
    if(bookingList.length < 3){
      //Repetim la solicitud amb 1 dia més.
      bookingList.addAll(await searchFlightsToDestinations(nearAirports,
          sort: "date", dayRange: 1));
    }
    bookingList.add(Booking()..endOfData());
    return Bookings(bookingList,context);
  }

  // Helpers per agafar les dades:
  Future<List<Booking>> searchFlightsToDestinations(List<String> nearAirports,
      {List<String> popularDestinations,
      String sort,
      bool onlyWeekends,
      int dayRange}) async {
    List<Booking> bookingList = [];

    //Aeroports de sortida -> format de la Api: A,B,C
    String nearAirportsReq = nearAirports.toString().replaceAll(" ", "");
    nearAirportsReq = nearAirportsReq.substring(1, nearAirportsReq.length - 1);

    // Busquem vols desde avui, fins d'aqui 7 dies
    var now = new DateTime.now();
    var formatter = new DateFormat('dd/MM/yyyy');

    var oneWeekFromNow = dayRange != null
        ? now.add(new Duration(days: dayRange))
        : now.add(new Duration(days: 30));

    Map<String, dynamic> requestDefinition = {
      "fly_from": nearAirportsReq,
      "dateFrom": formatter.format(now),
      "dateTo": formatter.format(oneWeekFromNow),
      "flight_type": "oneway",
      "one_for_city": 1,
      "sort": "date",
      "vehicle_type": "aircraft"
    };

    if (onlyWeekends != null) {
      requestDefinition["onlyWeekends"] = onlyWeekends;
      requestDefinition["flight_type"] = "round";
      requestDefinition["nights_in_dst_from"] = 0;
      requestDefinition["nights_in_dst_to"] = 1;
    }

    if (sort != null) {
      requestDefinition["sort"] = sort;
    }

    if (popularDestinations != null) {
      // Destinacions format de api: A,B,C
      String popularDestinationsReq =
          popularDestinations.toString().replaceAll(" ", "");

      popularDestinationsReq = popularDestinationsReq.substring(
          1, popularDestinationsReq.length - 1);

      requestDefinition["fly_to"] = popularDestinationsReq;
    }

    // Fem la peticio al backend
    final response = await http.get(req('/v2/search', requestDefinition),
        headers: {'apikey': "QEiR_0FuSG8t7MquzDjz3LrLPqXDTXsW"});

    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON

      var json = jsonDecode(response.body);
      for (var data in json["data"]) {
        bookingList.add(Booking()..fromJson(data));
      }

      return bookingList;
    } else {
      debugPrint("Error!! ${response.body}");
      // If the server did not return a 200 OK response,
      // then throw an exception.

      throw Exception('Failed to load data');
    }
  }

  // Obte totes les destinacions populars dels aeroports introduits.
  // Automaticament elimina les repeticions.
  Future<List<String>> bestDestinationsFromNearAirports(
      List<String> nearAirports, int destLimit) async {
    List<Future<List<String>>> popularDestinations = [];

    // Per a cada aeroport busquem les destinacions més populars
    for (var airport in nearAirports) {
      popularDestinations.add(popularDestinationsFromPlace(airport, destLimit));
    }

    // Un cop s'han fet totes les crides, esperem a tenir la info.
    List<String> result = [];
    for (var future in popularDestinations) {
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
  Future<List<String>> popularDestinationsFromPlace(
      String airport, int destLimit) async {
    List<String> result = [];
    final response = await http.get(
        req('/locations/topdestinations', {
          "term": airport,
          "limit": destLimit,
          "locale": "en-US", //"es-ES",
          "active_only": true
        }),
        headers: {'apikey': tequilaApiToken});

    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON
      var json = jsonDecode(response.body);
      for (var loc in json["locations"]) {
        result.add(loc["id"]);
      }

      return result;
    } else {
      debugPrint("Error!! ${response.body}");
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to load data');
    }
  }

  Future<List<String>> searchAirportsNearPos(Position pos, int limit) async {
    List<String> result = [];
    final response = await http.get(
        req('/locations/radius', {
          "lat": pos.latitude,
          "lon": pos.longitude,
          "radius": 250,
          "location_types": "airport",
          "limit": limit,
          "locale": "en-US",
          "active_only": true
        }),
        headers: {'apikey': tequilaApiToken});

    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON
      var json = jsonDecode(response.body);
      for (var loc in json["locations"]) {
        result.add(loc["id"]);
      }

      return result;
    } else {
      debugPrint("Error!! ${response.body}");
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to load data');
    }
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
    requestNextPageVariableData(context);
  }

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

  void fromJson(Map<String, dynamic> json) {
    // Booking booking = new Booking();
    this.origin = json["cityFrom"];
    this.shortOrigin = json["flyFrom"];

    this.destination = json["cityTo"];
    this.shortDestination = json["flyTo"];

    this.id = json["id"];

    this._departureTime = DateTime.parse(json["local_departure"]);

    this.price = json["price"];

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
    notifyListeners();
  }

  // Retorna el set per a guardar-lo a firebase realtime db.
  createSet() {
    return {
      'shortOrigin': shortOrigin,
      'shortDestination': shortDestination,
      'price': price,
      'departureTime': _departureTime
    };
  }

  Future<List<String>> requestHashTags(String placeId) async {
    var response = await http.get(tequilaBaseURL + "/locations/id?id=$placeId",
        headers: {'apikey': tequilaApiToken});

    if (response.statusCode == 200) {

      // If the server did return a 200 OK response,
      // then parse the JSON
      var json = jsonDecode(response.body);
      List<String> tags = [];

      for (var tag in json["locations"][0]["tags"]) {
        tags.add(tag["tag"]);
      }

      return tags;
    } else {
      // No posem tags.
      return [""];
    }
  }

  Future<Uint8List> requestImageFromGoogle(String destination, BuildContext context) async {

    // Working places example.
    var googlePlace = GooglePlace(googlePlacesApiToken);
    print("Getting image from $destination");

    var result = await googlePlace.search.getFindPlace(destination, InputType.TextQuery, fields: "photos");

    if(result != null && result.status == "OK" && result.candidates != null && result.candidates.length >= 1 && result.candidates.first.photos != null && result.candidates.first.photos.length >= 1){
      // Tenim una foto de google places.
      return googlePlace.photos.get(result.candidates.first.photos.first.photoReference,getPhoneHeight(context).toInt(),getPhoneWidth(context).toInt());
    }else{
      // Fallback ->  agafem una foto de pexels.

      return http.get(
          'https://api.pexels.com/v1/search?query=$destination&per_page=1&orientation=portrait&size=medium',
          headers: {HttpHeaders.authorizationHeader: pexelApiToken}).then<Uint8List>((response) async{

            if (response.statusCode == 200) {
            // If the server did return a 200 OK response,
            // then parse the JSON
            var json = jsonDecode(response.body);
            return (await NetworkAssetBundle(Uri.parse(json["photos"][0]["src"]["portrait"])).load("")).buffer.asUint8List();
          }else{
            return Future.error("We have no fotos of $destination");
          }

      }).catchError((error){
        print("Error! $error");
        return Future.error("We have no fotos of $destination");
      });
    }
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
