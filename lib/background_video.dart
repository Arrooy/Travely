import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:travely/utils.dart';

import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';

import 'model/video.dart';

class BackgroundVideo extends StatefulWidget {
  final String _firstVideoName = "assets/videos/firstVideo.mp4";
  final String _videoQuery;

  BackgroundVideo(this._videoQuery);

  Future<VideoPlayerController> Function(int) createController;
  Future<void> Function(VideoPlayerController) swapChewieController;

  @override
  _BackgroundVideoState createState() => _BackgroundVideoState();
}

class _BackgroundVideoState extends State<BackgroundVideo> {
  ChewieController _chewieController;

  VideoPlayerController _currentController;
  VideoPlayerController _nextVideoPlayerController;

  List<Video> _videos;

  VoidCallback _listener;

  bool _oneTime = true;
  bool _oneSwap = true;
  int _currentVideoIndex = -1;

  @override
  void initState() {
    initializeVideos();
    widget.swapChewieController = (VideoPlayerController vpc) async {
      if (_chewieController != null) {
        _chewieController.dispose();
        print("Chewie Controller disposed!");
      }

      if(vpc != null) {
        vpc.pause();
        vpc.seekTo(const Duration());
      }

      _chewieController = ChewieController(
          videoPlayerController: vpc,
          autoPlay: true,
          showControls: false,
          placeholder: Container(
            color: Colors.red,
          ));

      _oneTime = true;
    };

    widget.createController = (int videoIndex) async {
      VideoPlayerController vpc;
      print("Creating controller with index " + videoIndex.toString());

      if (videoIndex == -1) {
        vpc = VideoPlayerController.asset(widget._firstVideoName);
        await vpc.initialize();
        vpc.setVolume(0.0);
      } else {
        // Si intentem carregar el segon video sense tenirlo buffered, fem excepcio.
        if (_videos == null) throw Exception('Failed to load song');

        vpc = VideoPlayerController.network(_videos[videoIndex].url[0]);

        await vpc.initialize();

        print("Network video $videoIndex is ready! Url is " +
            _videos[videoIndex].url[0]);
        vpc.setVolume(0.0);
      }

      _listener = () async {
        if (!mounted) {
          return;
        }

        if (_currentController == null) {
          print("Current controller es null! returning.");
          return;
        }

        // Crea el seguent controlador (buffering del seguent video).
        // Evitem carregar el seguent video durant el primer segon de reproduccio
        // (Per evitar cridar createController abans de que aquest sigui definit.)
        if (_videos != null &&
            _oneTime &&
            _currentController.value.position > Duration(seconds: 1)) {
          _oneTime = false;
          print(
              "Inside listener. Ja hi han els videos. Creant next controller...");

          if (videoIndex + 1 >= _videos.length) videoIndex = -1;
          _nextVideoPlayerController =
              await widget.createController(videoIndex + 1);
        }

        if (_currentController.value.position >=
            _currentController.value.duration) {
          print("Video finished!My video index  is $videoIndex");
          print(_currentController.value.position.toString() +
              " " +
              _currentController.value.duration.toString());

          if (_oneSwap) {
            _oneSwap = false;

            print(
                "Inside listener. S'ha acabat el video, fent swap amb el controlador antic. Soc index $videoIndex");

            await widget.swapChewieController(_nextVideoPlayerController);

            _currentController = _nextVideoPlayerController;
            setState(() {
              _currentVideoIndex = videoIndex + 1;
            });

            _oneSwap = true;
          }
        }
      };

      vpc.addListener(_listener);

      return vpc;
    };
    initializePlayer();
    //
    super.initState();
  }

  Future<void> initializeVideos() async {
    _videos = await Video.queryVideos(widget._videoQuery);

    print("External videos ready!");
    print(_videos);
  }

  Future<void> initializePlayer() async {
    // Inicialment reproduim un video desde la memoria per accelerar l'app.
    // Amb -1 indiquem que s'ha de reproduir el video local.
    _currentController = await widget.createController(-1);
    await widget.swapChewieController(_currentController);

    setState(() {});
  }

  double calculateScaleFactor(int videoWidth, int videoHeight){
    double phoneWidth  = getPhoneWidth(context);
    double phoneHeight = getPhoneHeight(context);
    double scaleFactorW = 1;
    double scaleFactorH = 1;

    if(videoHeight < phoneHeight){
      //S'ha de fer scaling vertical
      scaleFactorH = phoneHeight / videoHeight;
    }

    if(videoWidth < phoneWidth){
      // S'ha de fer scaling horitzontal
      scaleFactorW = phoneWidth / videoWidth;
    }

    // Retorna el scaling més restrictiu
    return scaleFactorH > scaleFactorW ? scaleFactorH : scaleFactorW;
  }

  @override
  Widget build(BuildContext context) {

    double scaleFactor = 1;

    if(_chewieController != null )
    scaleFactor = calculateScaleFactor(_chewieController.videoPlayerController.value.size.width.toInt(), _chewieController.videoPlayerController.value.size.height.toInt());


    if(_currentVideoIndex != -1){
      if(_chewieController.videoPlayerController.value.size.width.toInt() != _videos[_currentVideoIndex].width || _chewieController.videoPlayerController.value.size.height.toInt() != _videos[_currentVideoIndex].height)
        throw Exception("Chewie controller video size is diferent from API size.");
    }

    return _chewieController != null &&
            _chewieController.videoPlayerController.value.initialized
        ? Center(
            child: Transform.scale(
                origin: Offset(0.0, 0.0),
                scale:scaleFactor,
                child: Chewie(controller: _chewieController)))
        : Container(
            color: Colors.white,
          );
    // : Center(
    //     child: Column(
    //     mainAxisAlignment: MainAxisAlignment.center,
    //     children: const [
    //       CircularProgressIndicator(),
    //       SizedBox(height: 20),
    //       Text('Loading'),
    //     ],
    //   ));
  }

  @override
  void dispose() {
    _currentController.dispose();
    _chewieController.dispose();

    super.dispose();
  }
}
