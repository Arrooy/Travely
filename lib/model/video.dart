import 'dart:io';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:travely/utils.dart';

class Video{
  final String url;
  final int height;
  final int width;

  Video(this.url, this.width, this.height);

  static Future<Video> searchVideo(int id) async{
    final response = await http.get('https://api.pexels.com/videos/videos/$id',
        headers: {HttpHeaders.authorizationHeader: pexelToken} );

    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.

      var json = jsonDecode(response.body);
      //Agafem el primer video de la llista de videos ( Hi han varis. hd, fullhd, hls, sd ...)
      var videoFiles = json["video_files"][0];

      return Video(videoFiles["link"], videoFiles["width"], videoFiles["height"]);
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to load song');
    }
  }

  static Future<List<Video>> queryVideos(String query) async{
    final response = await http.get('https://api.pexels.com/videos/search?query=$query&per_page=20&orientation=portrait&size=medium',
        headers: {HttpHeaders.authorizationHeader: pexelToken} );
    List<Video> result = [];

    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      int selectedHeight = 0;
      bool firstVideo = true;
      var json = jsonDecode(response.body);
      for (var vid in json["videos"]){

        Video biggestVideo;

        for (var options in vid["video_files"]){

          // if(firstVideo){
          //
          // }

          if(biggestVideo == null){
            if(selectedHeight == 0){
              selectedHeight = options["height"];
              biggestVideo = new Video(options["link"], options["width"], options["height"]);
            }else{
              if(selectedHeight == options["height"]){
                biggestVideo = new Video(options["link"], options["width"], options["height"]);
              }
            }

          }else{
            if(options["height"] != null){
                if(options["height"] == selectedHeight){
                  biggestVideo = new Video(options["link"], options["width"], options["height"]);
                }
            }
          }
        }
        firstVideo = false;

        result.add(biggestVideo);
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
    return "Video: " + url + " " + width.toString()  + " " + height.toString();
  }
}

