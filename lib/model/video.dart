import 'dart:io';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:travely/utils.dart';

//Guarda per un mateix video, varies resoluccions amb el seu respectiu link.
class Video{
  List<String> url;
  List<int> height;
  List<int> width;

  Video(String url, int width, int height){
    add(url,width,height);
  }

  void add(String url, int width, int height){
    this.url.add(url);
    this.width.add(width);
    this.height.add(height);
  }

  //Retorna la millor resolucio del video basant-se amb la mida del dispositiu.
  Video getBestVideo(int width, int height){

  }

  static Future<List<Video>> queryVideos(String query) async{
    final response = await http.get('https://api.pexels.com/videos/search?query=$query&per_page=20&orientation=portrait&size=medium',
        headers: {HttpHeaders.authorizationHeader: pexelToken} );

    List<Video> result = [];

    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON

      var json = jsonDecode(response.body);

      for (var vid in json["videos"]){
        // print("Video w and h is " + vid["width"].toString() + " " + vid["height"].toString());
        // print("Showing options:");

        Video newVideo;

        for (var options in vid["video_files"]){
          print("Option: " + options["width"].toString() + " " + options["height"].toString());
          if(newVideo == null){
            newVideo = new Video(options["link"], options["width"], options["height"]);
          }else{

            if(options["height"] != null){
              newVideo.add(options["link"], options["width"], options["height"]);
            }
          }

        }
        print("Selected video is " + newVideo.toString());
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
    return "Video: " + url[0] + " " + width[0].toString()  + " " + height[0].toString();
  }
}

