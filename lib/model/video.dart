import 'dart:io';
import 'dart:convert';
import 'dart:math';

import 'package:http/http.dart' as http;
import 'package:travely/utils.dart';

//Guarda per un mateix video, varies resoluccions amb el seu respectiu link.
class Video {
  List<String> url;
  List<int> height;
  List<int> width;
  int selectedVideo;

  Video(String url, int width, int height) {
    add(url, width, height);
    selectedVideo = -1;
  }

  void add(String url, int width, int height) {
    if (this.url == null) {
      this.url = [];
      this.width = [];
      this.height = [];
    }

    this.url.add(url);
    this.width.add(width);
    this.height.add(height);
  }

  //Retorna la url amb la millor resolucio del video basant-se amb la mida del dispositiu.
  String getBestVideo(int width, int height) {
    double minDistance = double.infinity;
    int minIndex = -1;
    for (var i = 0; i < url.length; i++) {
      double distance = sqrt(pow(width - this.width[i], 2) + pow(height - this.height[i], 2));
      print("Getting best video. video size: " + this.width[i].toString() + " " + this.height[i].toString() + " Distance is $distance");
      if (distance < minDistance) {
        // Tallem la iteració si ja hem trobat al candidat perfecte.
        if (distance == 0) {
          selectedVideo = i;
          print("SELECTED! Distance is "  + distance.toString());
          return this.url[i];
        }
        //De lo contrari, nomes el guardem si la mida es inferior a la de la pantalla
        if(width > this.width[i] && height > this.height[i]) {
          minDistance = distance;
          minIndex = i;
        }
      }
    }
    
    if(minIndex == -1){
      print("NO SHA TROBAT CAP VIDEO INTERESANT. MIREM EL SEGUENT!");
      return "";
    }

    print("SELECTED! Distance is "  + sqrt(pow(width - this.width[minIndex], 2) + pow(height - this.height[minIndex], 2)).toString());

    selectedVideo = minIndex;
    // Retornem el millor candidat trobat.
    return this.url[minIndex];
  }

  int getSelectedWidth() {
    return this.width[selectedVideo];
  }

  int getSelectedHeight() {
    return this.height[selectedVideo];
  }

  String getSelectedUrl() {
    return this.url[selectedVideo];
  }

  static Future<List<Video>> queryVideos(String query) async {
    final response = await http.get(
        'https://api.pexels.com/videos/search?query=$query&per_page=20&orientation=portrait&size=medium',
        headers: {HttpHeaders.authorizationHeader: pexelToken});

    List<Video> result = [];

    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON
      var json = jsonDecode(response.body);

      for (var vid in json["videos"]) {
        Video newVideo;
        for (var options in vid["video_files"]) {

          if (newVideo == null) {
            newVideo =
                new Video(options["link"], options["width"], options["height"]);
          } else {
            if (options["height"] != null) {
              newVideo.add(
                  options["link"], options["width"], options["height"]);
            }
          }
        }
        result.add(newVideo);
      }
      return result;
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to load song');
    }
  }

  @override
  String toString() {
    return "Video: " +
        url[0] +
        " " +
        width[0].toString() +
        " " +
        height[0].toString();
  }
}
