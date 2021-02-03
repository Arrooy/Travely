import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:travely/FABBottomAppBar.dart';

import 'package:travely/TravelyMaps.dart';
import 'package:travely/ui_utils.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:travely/TrendingTab.dart';
import 'package:travely/PhotoGrid.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  Widget _animatedWidget = TrendingTab();
  int _lastPage = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          //Nomes es mostra la burger a bookings. El swipe segueix actiu.
          leading: _lastPage == 1 ? null : new Container() ,
          centerTitle: true,
          title: Text(
            "Travely",
            style: GoogleFonts.getFont("Pacifico", fontSize: 32),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: FloatingActionButton(
          heroTag: "travel",
          elevation: 5,
          onPressed: ()  {
            _bottomBarTabSelected(2);
          },
          tooltip: 'Search a flight',
          child: Icon(Icons.flight),
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
        drawer: homeDrawer(context),
        body: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          // Podem escollir entre moltes... https://medium.com/flutterdevs/page-transitions-in-flutter-5236a8afae92
          transitionBuilder: (Widget child, Animation<double> animation) =>
              FadeTransition(
            opacity: animation,
            child: child,
          ),
          child: _animatedWidget,
        ));
  }

  void _bottomBarTabSelected(pageIndex) {
    // Botons de la barra de navegacio
    if (_lastPage == pageIndex) return;

    setState(() {
      switch (pageIndex) {
        case 0:
          // S'ha apretat Trending.
          _animatedWidget = TrendingTab();
          break;
        case 1:
        // S'ha apretat bookings
          _animatedWidget = Container(
              color: Theme.of(context).primaryColor,
              child: Column(children: [
                Expanded(child: PhotoGrid()),
              ]));
          break;
        case 2:
          // S'ha apretat el avio
          _animatedWidget = TravelyMaps();
          break;
        default:
          print("Atenció! S'ha apretat un botó no configurat.");
      }
    });
    _lastPage = pageIndex;
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
