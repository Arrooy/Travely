import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:travely/HashtagBar.dart';
import 'package:travely/TrendPage.dart';

import 'model/LocationManager.dart';

class TrendingPage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {

    return  Stack(children: [

      PageView.builder(
        scrollDirection: Axis.vertical,

        itemBuilder: (context, position) {

          print("PAGE BUILD! $position");
          return FutureBuilder <String>(
              future: _calculation,
              builder: (BuildContext context,  AsyncSnapshot<String> snapshot) {
                List<Widget> children;
                if (snapshot.hasData) {

                    return TrendPage();

                } else if (snapshot.hasError) {
                  children = <Widget>[
                    Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 60,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Text('Error: ${snapshot.error}'),
                    )
                  ];
                } else {
                  children = <Widget>[
                    SizedBox(
                      child: CircularProgressIndicator(),
                      width: 60,
                      height: 60,
                    ),
                    const Padding(
                      padding: EdgeInsets.only(top: 16),
                      child: Text('Awaiting result...'),
                    )
                  ];

                }
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: children,
                  ),
                );
              });
        },
      ),
      HashtagBar(["Popular Destinations","Cheapest Travels",
          "Weekend Scape",
          "Best Quality",
          "Short Flight"], false)
    ]);
  }

  Future<Widget> _buildView(context, position) async{
    LocationManager locationManager = Provider.of<LocationManager>(context, listen: false);
    Position pos = await locationManager.getPosition(LocationAccuracy.low);

  }

  final Future<String> _calculation = Future<String>.delayed(
    Duration(seconds: 2),
        () => 'Data Loaded',
  );
}