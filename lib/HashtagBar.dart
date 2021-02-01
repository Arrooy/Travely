
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class HashtagBar extends StatefulWidget {
  final List<String> hashtagLabels;
  final bool smallBar;
  HashtagBar(this.hashtagLabels, [bool this.smallBar = true]);
  @override
  _HashtagBarState createState() => _HashtagBarState(this.smallBar);
}


class _HashtagBarState extends State<HashtagBar> {
  ScrollController _scrollController;

  bool _leftFadeActive = false;
  bool _rightFadeActive = false;
  bool _scrollNotAtEdge = false;

  List<Widget> hashtags;
  bool _smallBar;

  _HashtagBarState(this._smallBar);

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

    return  Container(
      alignment: _smallBar ? Alignment.centerLeft : Alignment.center,
      height: 50,

      child: SingleChildScrollView(
        controller: _scrollController,

        scrollDirection: Axis.horizontal,
        child: Row(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center ,
            children: hashtags != null ? hashtags : Container()),
      ),
    );
  }

  @override
  void initState() {
    _scrollController = new ScrollController();
    _scrollController.addListener(_scrollListener);
    _rightFadeActive = !_smallBar;
    hashtags = <Widget>[];
    for(var name in widget.hashtagLabels){
      hashtags.add(Hashtag(name,!_smallBar));
    }
    setState(() {});
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
  final bool _addMargin;

  Hashtag(this.text,this._addMargin);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (){
        print("Hashtag Tapped!");
        // context.read<>();
      },
      child: Container(
          margin: _addMargin ? const EdgeInsets.symmetric(horizontal: 5) : null,
          padding: _addMargin ? const EdgeInsets.symmetric(horizontal: 5) : null,
          decoration: BoxDecoration(
              color: Colors.grey,
              border: Border.all(
                color: Colors.blueGrey,
              ),
              borderRadius: BorderRadius.all(Radius.circular(20))),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(text),
          )),
    );
  }
}
