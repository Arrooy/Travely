import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:travely/model/Booking.dart';

class HashtagBar extends StatefulWidget {
  final List<String> hashtagLabels;
  final bool smallBar;
  HashtagBar(this.hashtagLabels, [this.smallBar = true]);
  @override
  _HashtagBarState createState() => _HashtagBarState(this.smallBar);
}

class _HashtagBarState extends State<HashtagBar> {
  ScrollController _scrollController;

  bool _leftFadeActive = false;
  bool _rightFadeActive = false;
  bool _scrollNotAtEdge = false;

  List<Hashtag> hashtags;
  bool _smallBar;

  int _selectedHashtag;

  _HashtagBarState(this._smallBar) : _selectedHashtag = 0;

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

  Widget _buildHashtagBar() {
    return Container(
        alignment: _smallBar ? Alignment.centerLeft : Alignment.center,
        height: 50,
        child: SingleChildScrollView(
            controller: _scrollController,
            scrollDirection: Axis.horizontal,
            child: Row(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: hashtags)));
  }

  @override
  void initState() {
    _scrollController = new ScrollController();
    _scrollController.addListener(_scrollListener);
    _rightFadeActive = !_smallBar;
    _buildHashtags();
    setState(() {});
    super.initState();
  }

  void _buildHashtags() {
    hashtags = <Hashtag>[];
    int index = 0;
    for (var name in widget.hashtagLabels) {
      hashtags.add(Hashtag(
          name,
          index++,
          !_smallBar,
          _onPressed));
    }
  }

  void _onPressed(index, context) {
    Provider.of<TrendingsModel>(context, listen: false).filterSelected = index;

    // hashtags[_selectedHashtag] = Hashtag.update(hashtags[_selectedHashtag], false);
    // hashtags[index] = Hashtag.update(hashtags[index], true);
    //
    // _selectedHashtag = index;
    // setState(() {});
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
      child: _buildHashtagBar(),
      blendMode: BlendMode.dstIn,
    );
  }
}

class Hashtag extends StatelessWidget {
  final String text;
  final bool _addMargin;
  final int index;
  final Function(int, BuildContext) callback;

  Hashtag(this.text, this.index, this._addMargin, this.callback);

  @override
  Widget build(BuildContext context) {

    Widget result;
    if(this._addMargin){
      result = Consumer<TrendingsModel>(
          builder: (ctx,m,c){

            return Container(
                margin: _addMargin ? const EdgeInsets.symmetric(horizontal: 5) : null,
                padding:
                _addMargin ? const EdgeInsets.symmetric(horizontal: 5) : null,
                decoration: BoxDecoration(
                    color: m.filterSelected == index ? Colors.redAccent : Colors.grey,
                    border: Border.all(
                      color: Colors.blueGrey,
                    ),
                    borderRadius: BorderRadius.all(Radius.circular(20))),
                child: c);

          },
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(text),
          )
      );
    }else{
     result = Container(
          margin: _addMargin ? const EdgeInsets.symmetric(horizontal: 5) : null,
          padding:
          _addMargin ? const EdgeInsets.symmetric(horizontal: 5) : null,
          decoration: BoxDecoration(
              color: Colors.grey,
              border: Border.all(
                color: Colors.blueGrey,
              ),
              borderRadius: BorderRadius.all(Radius.circular(20))),

          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(text),
          )
      );
    }

    return GestureDetector(
      onTap: () => this.callback(this.index, context),
      child: result,
    );
  }
}
