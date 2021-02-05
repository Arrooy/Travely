import 'dart:typed_data';

import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter_platform_interface/src/types/location.dart';
import 'package:google_place/google_place.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:travely/model/UserManager.dart';
import 'package:travely/utils.dart';

import 'package:firebase_database/firebase_database.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';

import 'model/Booking.dart';

class Tequila{

  static searchPopularDestinations(
      Position pos, List<String> nearAirports, int resultLimit, BuildContext context) async {
    List<Booking> bookingList = [];

    List<String> popularDestinations =
    await bestDestinationsFromNearAirports(nearAirports, resultLimit);
    bookingList = await searchFlightsToDestinations(nearAirports,
        flyToDestinations: popularDestinations);

    bookingList.add(Booking()..endOfData());
    return Bookings(bookingList,context);
  }

  static searchCheapestTravel(
      Position pos, List<String> nearAirports, int resultLimit, BuildContext context) async {

    List<Booking> bookingList = [];
    bookingList = await searchFlightsToDestinations(nearAirports,
        sort: "price", dayRange: 7);

    bookingList.add(Booking()..endOfData());
    return Bookings(bookingList,context);
  }

  static searchShortFlight(
      Position pos, List<String> nearAirports, int resultLimit, BuildContext context) async {
    List<Booking> bookingList = [];
    bookingList = await searchFlightsToDestinations(nearAirports,
        sort: "duration", dayRange: 7);

    bookingList.add(Booking()..endOfData());
    return Bookings(bookingList,context);
  }

  static searchBestQuality(
      Position pos, List<String> nearAirports, int resultLimit, BuildContext context) async {
    List<Booking> bookingList = [];
    bookingList = await searchFlightsToDestinations(nearAirports,
        sort: "quality", dayRange: 7);

    bookingList.add(Booking()..endOfData());
    return Bookings(bookingList,context);
  }

  static searchWeekendScape(
      Position pos, List<String> nearAirports, int resultLimit, BuildContext context) async {
    List<Booking> bookingList = [];
    bookingList = await searchFlightsToDestinations(nearAirports,
        onlyWeekends: true, sort: "date", dayRange: 7);

    bookingList.add(Booking()..endOfData());
    return Bookings(bookingList,context);
  }

  static searchLastMinute(
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
  static Future<List<Booking>> searchFlightsToDestinations(List<String> nearAirports,
      {List<String> flyToDestinations,
        String sort,
        bool onlyWeekends,
        int dayRange,
      List<Position> positions}) async {
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

    if (flyToDestinations != null) {
      // Destinacions format de api: A,B,C
      String flyToDestinationsReq =
      flyToDestinations.toString().replaceAll(" ", "");

      flyToDestinationsReq = flyToDestinationsReq.substring(
          1, flyToDestinationsReq.length - 1);

      requestDefinition["fly_to"] = flyToDestinationsReq;
    }

    // Fem la peticio al backend
    final response = await http.get(req('/v2/search', requestDefinition),
        headers: {'apikey': "QEiR_0FuSG8t7MquzDjz3LrLPqXDTXsW"});

    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON

      var json = jsonDecode(response.body);
      // Si ens proporcionen positions, les afegim als bookings.
      if(positions != null){
        for (var data in json["data"]) {
          bookingList.add(Booking()..fromJson(data,position: positions[flyToDestinations.indexOf(data["cityCodeTo"])]));
        }
      }else{
        // No tenim dades de positions, guardem el que ens dona tequila.
        for (var data in json["data"]) {
          bookingList.add(Booking()..fromJson(data));
        }
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
  static Future<List<String>> bestDestinationsFromNearAirports(
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
  static Future<List<String>> popularDestinationsFromPlace(
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

  static Future<List<String>> searchAirportsNearPos(Position pos, int limit) async {
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

  // Retorna una llista amb 2 elements.
  // El primer element correspon a les cities a la vista
  // El segon element correspon a les posicions de les cities.
  static searchCitiesInView(LatLngBounds bounds, int limit) async{
    List<String> result = [];
    List<Position> resultPositions = [];

    final response = await http.get(req('/locations/box', {
      "low_lat": bounds.southwest.latitude,
      "low_lon": bounds.southwest.longitude,
      "high_lat": bounds.northeast.latitude,
      "high_lon": bounds.northeast.longitude,
      "limit":limit,
      "location_types":"city"
    }), headers: {'apikey': tequilaApiToken});

    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON
      var json = jsonDecode(response.body);
      for (var loc in json["locations"]) {
        result.add(loc["code"]);
        resultPositions.add(Position(latitude:loc["location"]["lat"],longitude: loc["location"]["lon"]));
      }

      return [result,resultPositions];
    } else {
      debugPrint("Error!! ${response.body}");
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to load data');
    }
  }
}