import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:google_place/google_place.dart';

import 'package:http/http.dart' as http;


final String pexelApiToken = "563492ad6f91700001000001e69ed8ad08eb4d24867553648a9521a9";

// MAPS: https://itsshivam.medium.com/guide-to-integrate-google-maps-with-flutter-db86d033ea25
// APIS: https://console.developers.google.com/apis/library?filter=category:maps&project=root-amulet-303207
final String  googleMapsAndroidToken = "AIzaSyA5Ay_HG2-RyeqtbQCViQE3XZkm4dk_taE";
final String  googleMapsIOSToken = "AIzaSyAiC37U7llwtHc0cU8lVhpRIsQWJjDlP_8";

// En teoria ha de ser multiplataforma.
final String googlePlacesApiToken = "AIzaSyAc4XLMDlLVeSatFQLqoTxuwjakIyWqFwo";

//https://tequila.kiwi.com/portal/my-solutions
final String tequilaApiToken = "nS0OLaxhbQ79iNHAcvMdZDM1Lmv6Qn8_";
String tequilaBaseURL = "https://tequila-api.kiwi.com";

double getPhoneWidth(BuildContext context){
  return MediaQuery.of(context).size.width * MediaQuery.of(context).devicePixelRatio;
}

double getPhoneHeight(BuildContext context){
  final padding = MediaQuery.of(context).padding;
  return MediaQuery.of(context).size.height * MediaQuery.of(context).devicePixelRatio - padding.top - padding.bottom;
}

Future<Uint8List> requestImageFromGoogle(String destination, BuildContext context) async {

  // Working places example.
  var googlePlace = GooglePlace(googlePlacesApiToken);
  print("Getting place from $destination");

  var result = await googlePlace.search.getFindPlace(destination, InputType.TextQuery, fields: "photos");

  if(result != null && result.status == "OK" && result.candidates != null && result.candidates.length >= 1 && result.candidates.first.photos != null && result.candidates.first.photos.length >= 1){
    // Tenim una foto de google places.
    print("Getting image from $destination using google");
    return googlePlace.photos.get(result.candidates.first.photos.first.photoReference,getPhoneHeight(context).toInt(),getPhoneWidth(context).toInt());
  }else{
    // Fallback ->  agafem una foto de pexels.
    print("Getting image from $destination using pexels");
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