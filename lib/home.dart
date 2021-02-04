import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'package:travely/FABBottomAppBar.dart';
import 'file:///C:/Users/Arroy/StudioProjects/Travely/lib/NotUsed/AnimatedFab.dart';

import 'package:google_place/google_place.dart';
import 'package:travely/TravelyMaps.dart';
import 'package:travely/model/LocationManager.dart';
import 'package:travely/ui_utils.dart';
import 'package:travely/utils.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:travely/TrendingTab.dart';
import 'package:travely/PhotoGrid.dart';


class Home extends StatefulWidget {
  final PageStorageKey mykey = new PageStorageKey("aKey");

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _currentTab = 0;

  final List<Widget> pages = <Widget>[
    TrendingTab(new PageStorageKey<String>("key1")),
    PhotoGrid(new PageStorageKey<String>("key2")),
    TravelyMaps(new PageStorageKey<String>("key3"))
  ];

  final PageStorageBucket _bucket = PageStorageBucket();

  @override
  Widget build(BuildContext context) {
    print("REBUILDING HOME");
    return Scaffold(
        appBar: AppBar(
          //Nomes es mostra la burger a bookings. El swipe segueix actiu.
          leading: _currentTab == 1 ? null : new Container(),
          centerTitle: true,
          title: Text(
            "Travely",
            style: GoogleFonts.getFont("Pacifico", fontSize: 32),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: FloatingActionButton(
          heroTag: "travel",
          backgroundColor: _currentTab == 2 ? Colors.red : Colors.grey,
          elevation: 5,
          onPressed: () {
            _bottomBarTabSelected(2);
          },
          tooltip: 'Search a flight',
          child: Icon(Icons.flight),
        ),
        bottomNavigationBar: FABBottomAppBar(
            noButtonSelected: _currentTab == 2,
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
        body: PageStorage(
          child: pages[_currentTab],
          bucket: _bucket,
          key: widget.mykey,
        )
    );
  }

  void _bottomBarTabSelected(pageIndex) {
    // Botons de la barra de navegacio
    setState(() {
      _currentTab = pageIndex;
    });
  }
}

