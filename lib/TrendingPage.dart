import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class TrendingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return  Stack(children: [
      PageView.builder(
        scrollDirection: Axis.vertical,
        itemBuilder: (context, position) {
          return Container(child:
          Center(child:Text("Hi im view $position"))
            // color: position % 2 == 0 ? Colors.pink : Colors.cyan,
          );
        },
      ),
      HashtagBar()
    ]);
  }
}

class HashtagBar extends StatefulWidget {
  @override
  _HashtagBarState createState() => _HashtagBarState();
}

class _HashtagBarState extends State<HashtagBar> {
  ScrollController _scrollController;

  bool _leftFadeActive = false;
  bool _rightFadeActive = true;
  bool _scrollNotAtEdge = false;

  void _scrollListener() {
    if (_scrollController.offset >=
        _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange) {
      _scrollNotAtEdge = false;
      setState(() {
        _leftFadeActive = true;
        _rightFadeActive = false;
      });
      return;
    }
    if (_scrollController.offset <=
        _scrollController.position.minScrollExtent &&
        !_scrollController.position.outOfRange) {
      _scrollNotAtEdge = false;
      setState(() {
        _leftFadeActive = false;
        _rightFadeActive = true;
      });
      return;
    }

    if (!_scrollController.position.atEdge && !_scrollNotAtEdge) {
      //Afegim els 2 fades.
      _scrollNotAtEdge = true;
      setState(() {
        _leftFadeActive = true;
        _rightFadeActive = true;
      });
    }
  }

  Widget _buildHashtags() {

    return Container(
      alignment: Alignment.center,
      height: 50,

      child: SingleChildScrollView(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        child: Row(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center ,
            children: <Widget>[
              Hashtag("Hi"),
              Hashtag("Hello"),Hashtag("Hi"),
              Hashtag("Hello"),
              Hashtag("Hi"),
              Hashtag("Hello"),Hashtag("Hi"),
              Hashtag("Hello"),
              Hashtag("Hi"),
              Hashtag("Hello"),Hashtag("Hi"),
              Hashtag("Hello"),

            ]),
      ),
    );
  }
  @override
  void initState() {
    _scrollController = new ScrollController();
    _scrollController.addListener(_scrollListener);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ShaderMask(

      shaderCallback: (Rect bounds) {

        return LinearGradient(

          begin: Alignment.centerLeft,

          end: Alignment.centerRight,
          // Fem que la zona transparent sigui mes petita afegint zones negres al centre.
          // Amb els dos bools _leftFadeActive _rightFadeActive controlem
          // Els degradats amb el scroll controller.
          colors: <Color>[
            _leftFadeActive ? Colors.transparent : Colors.black,
            Colors.black,
            Colors.black,
            Colors.black,
            Colors.black,
            Colors.black,
            Colors.black,
            _rightFadeActive ? Colors.transparent : Colors.black
          ],
        ).createShader(bounds);
      },
      child: _buildHashtags(),
      blendMode: BlendMode.dstIn,
    );
  }

}

class Hashtag extends StatelessWidget {
  final String text;
  Hashtag(this.text);

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: const EdgeInsets.symmetric(horizontal: 5),
        padding: const EdgeInsets.symmetric(horizontal: 5),
        decoration: BoxDecoration(
            border: Border.all(
              color: Colors.green,
            ),
            borderRadius: BorderRadius.all(Radius.circular(20))),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(text),
        ));
  }
}