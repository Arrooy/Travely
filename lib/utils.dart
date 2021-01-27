import 'package:flutter/cupertino.dart';
import 'package:video_player/video_player.dart';

import 'model/video.dart';

final String pexelToken = "563492ad6f91700001000001e69ed8ad08eb4d24867553648a9521a9";
//
// void videoPlayer_callback(VideoPlayerController oldVpc,VideoPlayerController newVpc, Video video) async {
//
//     if ((oldVpc.value.position + Duration(seconds: 1)) >=
//         oldVpc.value.duration) {
//       //Falta 1 seg per acabar el video, carreguem el seguent video
//       currentPlayedVideo += 1;
//
//       if (oldVpc.value.position >=
//           oldVpc.value.duration) {
//         //Ja ha acabat el video. Fem el swap de videos.
//         await _chewieController.dispose();
//         _videoPlayerController1.pause();
//         _videoPlayerController1.seekTo(const Duration());
//         setState(() {
//           _chewieController = new ChewieController(
//               videoPlayerController: _videoPlayerController1,
//               autoPlay: true,
//               showControls: false,
//               placeholder: Container(
//                 color: Colors.red,
//               )
//           );
//         });
//       }
//     }
//
// }

double getPhoneWidth(BuildContext context){
  return MediaQuery.of(context).size.width * MediaQuery.of(context).devicePixelRatio;
}

double getPhoneHeight(BuildContext context){
  final padding = MediaQuery.of(context).padding;
  return MediaQuery.of(context).size.height * MediaQuery.of(context).devicePixelRatio - padding.top - padding.bottom;
}