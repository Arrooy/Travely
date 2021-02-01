import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:travely/FABBottomAppBar.dart';
import 'package:travely/AnimatedFab.dart';

import 'package:google_place/google_place.dart';
import 'file:///C:/Users/Arroy/StudioProjects/Travely/lib/model/LocationManager.dart';
import 'package:travely/utils.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:travely/TrendingPage.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  Widget _animatedWidget = TrendingPage();
  int _lastPage = 0;

  @override
  Widget build(BuildContext context) {
     return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text("Travely",
          style: GoogleFonts.getFont("Pacifico",fontSize: 32),),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: AnimatedFab(
          // heroTag: "travel",
          onPressed: _bottomBarPlaneButton,
          tooltip: 'Search a flight',
        ),
        bottomNavigationBar: FABBottomAppBar(
            onTabSelected: _bottomBarTabSelected,
            notchedShape: CircularNotchedRectangle(),
            items: [
              FABBottomAppBarItem(
                  iconData: Icons.whatshot,
                  text: 'Trending',
                  tooltipText: 'Best destinations based on your location'),
              FABBottomAppBarItem(
                  iconData: Icons.person,
                  text: 'Bookings',
                  tooltipText: 'Your saved destinations'),
            ],
            selectedColor: Colors.red),


        body: AnimatedSwitcher(
          duration: const Duration(milliseconds:300),
          // Podem escollir entre moltes... https://medium.com/flutterdevs/page-transitions-in-flutter-5236a8afae92
          transitionBuilder: (Widget child,Animation<double> animation) => FadeTransition(
            opacity:animation,
            child: child,
          ),
          child:_animatedWidget,
        )
    );
  }

  void _bottomBarTabSelected(pageIndex){
    // Botons de la barra de navegacio
    if(_lastPage == pageIndex) return;

    setState(() {
     switch(pageIndex){
       case 0:
         _animatedWidget = TrendingPage();
         break;
       case 1:
        _animatedWidget = Container(color:Colors.greenAccent,child:Center(child:Text("user menu")));
         break;
       default:
         print("Atenció! S'ha apretat un botó no configurat.");
     }
    });
    _lastPage = pageIndex;
  }

  Function(int) _bottomBarPlaneButton(buttonIndex){
    // Boto de buscar vols

  }
}
/*
Working places example.
var googlePlace = GooglePlace(googlePlaces);
          var result = await googlePlace.search.getNearBySearch(
              Location(lat: -33.8670522, lng: 151.1957362), 1500,
              type: "restaurant");

          print(result.status);
          print(result.results.length);
          print(result.results.first.name);

 */
