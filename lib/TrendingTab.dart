import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:travely/HashtagBar.dart';
import 'package:travely/TrendPage.dart';
import 'package:travely/ui_utils.dart';

import 'model/Booking.dart';

import 'dart:async';
import 'model/LocationManager.dart';

class TrendingTab extends StatefulWidget {
  TrendingTab(key1):super(key:key1);


  @override
  _TrendingTabState createState() => _TrendingTabState();
}

class _TrendingTabState extends State<TrendingTab> {

 Future _trendingModelReady;

  @override
  void initState() {
    super.initState();
    _trendingModelReady = Provider.of<TrendingsModel>(context, listen: false).requestAndUpdateData(context);
  }

  @override
  Widget build(BuildContext context) {

    return FutureBuilder <bool>(
        future: _trendingModelReady,
        builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
          if (snapshot.hasData && snapshot.data) {
            return Stack(children: [
              PageView.builder(
                controller: Provider
                    .of<TrendingsModel>(context, listen: false)
                    .pageViewController,
                scrollDirection: Axis.vertical,
                itemBuilder: (context, position) {
                  // Modifiquem el model amb el trend page actual.
                  Provider
                      .of<TrendingsModel>(context, listen: false)
                      .newTrendPageIndex(position,context);

                  //Pintem el trendPage
                  return TrendPage();
                },
              ),
              HashtagBar(Provider
                  .of<TrendingsModel>(context, listen: false)
                  .options, false),
            ]);
          } else
          if (snapshot.hasError || (snapshot.data != null && !snapshot.data)) {
            return futureError(snapshot.error);
          }

          return futureLoading('Awaiting destinations...');
        });
  }

}
