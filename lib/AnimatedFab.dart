import 'package:flutter/material.dart';

class AnimatedFab extends StatefulWidget {
  final Function(int) onPressed;
  final String tooltip;
  final IconData icon;

  AnimatedFab({this.onPressed, this.tooltip, this.icon});

  @override
  _AnimatedFabState createState() => _AnimatedFabState();
}

class _AnimatedFabState extends State<AnimatedFab>
    with SingleTickerProviderStateMixin {

  bool isOpened = false;
  bool planeVisible = true;
  bool crossVisible = false;

  AnimationController _animationController;
  Animation<Color> _buttonColor;
  Animation<double> _translateButton;

  Curve _curve = Curves.easeOut;

  @override
  initState() {
    _animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 500))
          ..addListener(() {
            setState(() {});
          });

    _buttonColor = ColorTween(
      begin: Colors.green,
      end: Colors.red,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Interval(
        0.00,
        1.00,
        curve: Curves.linear,
      ),
    ));

    _translateButton = Tween<double>(
      begin: 0,
      end: -60,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Interval(
        0.0,
        0.75,
        curve: _curve,
      ),
    ));
    super.initState();
  }

  @override
  dispose() {
    _animationController.dispose();
    super.dispose();
  }

  animate() {
    if (!isOpened) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }

    if(!isOpened) planeVisible = false;
    else crossVisible = false;

    isOpened = !isOpened;
  }

  Widget _secondOption() {
    return FloatingActionButton(
      onPressed: widget.onPressed(1),
      heroTag: null,
      tooltip: 'test',
      child: Icon(Icons.image),
    );
  }

  Widget _firstOption() {
    return FloatingActionButton(
      onPressed: widget.onPressed(0),
      heroTag: null,
      tooltip: 'test',
      child: Icon(Icons.inbox),
    );
  }

  Widget toggle() {
    return FloatingActionButton(
        backgroundColor: _buttonColor.value,
        onPressed: animate,
        tooltip: widget.tooltip,
        heroTag: null,
        elevation: 5,
        child: Stack(children: [
          AnimatedOpacity(
            opacity: crossVisible ? 1.0 : 0.0,
            duration: Duration(milliseconds: 250),
            onEnd: () {
              planeVisible = !crossVisible;
            },
            child: Icon(Icons.close),
          ),
          AnimatedOpacity(
              opacity: planeVisible ? 1.0 : 0.0,
              duration: Duration(milliseconds: 250),
              onEnd: () {
                crossVisible = !planeVisible;
              },
              child: Icon(Icons.flight)),
        ]));
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Transform(
          transform: Matrix4.translationValues(
            0.0,
            _translateButton.value * 2.0,
            0.0,
          ),
          child: _secondOption(),
        ),
        Transform(
          transform: Matrix4.translationValues(
            0.0,
            _translateButton.value,
            0.0,
          ),
          child: _firstOption(),
        ),
        toggle(),
      ],
    );
  }
}
