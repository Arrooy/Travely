import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:travely/HashtagBar.dart';
import 'package:travely/TrendPage.dart';

import 'model/Booking.dart';
import 'model/LocationManager.dart';

class TrendingTab extends StatelessWidget {

  @override
  Widget build(BuildContext context) {

      return FutureBuilder <bool>(
          future: Provider.of<TrendingsModel>(context,listen: false).requestAndUpdateData(context),
          builder: (BuildContext context,  AsyncSnapshot<bool> snapshot) {
            List<Widget> children;
            if (snapshot.hasData && snapshot.data) {

                return Stack(children: [

                  PageView.builder(
                    scrollDirection: Axis.vertical,

                    itemBuilder: (context, position) {
                      // Modifiquem el model amb el trend page actual.
                      Provider.of<TrendingsModel>(context, listen: false).newTrendPageIndex = position;

                      //Pintem el trendPage
                      return TrendPage();
                    },
                  ),
                  HashtagBar(Provider.of<TrendingsModel>(context, listen:false).options, false),
                ]);

            } else if (snapshot.hasError ||(snapshot.data != null &&  !snapshot.data)) {
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
                  child: Text('Awaiting destinations...'),
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
  }
}