import 'dart:math';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:travely/ui_utils.dart';

import 'model/LocationManager.dart';

class TravelyMaps extends StatefulWidget {
  TravelyMaps(key1):super(key:key1);

  @override
  _TravelyMaps createState() => _TravelyMaps();
}

class _TravelyMaps extends State<TravelyMaps> {
  GoogleMapController mapController;
  Map<MarkerId, Marker> markers = <MarkerId, Marker>{}; // MAP OF MARKS
  int _markerIdCounter = 0;
  // Madrid per començar
  LatLng _center = const LatLng(40.416775, -3.703790);

  void _onMapCreated(GoogleMapController controller) async{
    mapController = controller;

    Position pos = await Provider.of<LocationManager>(context, listen: false)
          .getPosition(LocationAccuracy.high);

    mapController.moveCamera(CameraUpdate.newLatLng(LatLng(pos.latitude,pos.longitude)));
    for(var i  = 0 ;  i < 20 ; i++)_add();
  }

  void _add() {
    var markerIdVal = _markerIdCounter.toString();
    final MarkerId markerId = MarkerId(markerIdVal);
    _markerIdCounter ++;
    // creating a new MARKER
    final Marker marker = Marker(
      markerId: markerId,
      position: LatLng(
        _center.latitude + sin(_markerIdCounter * pi / 6.0) / 20.0,
        _center.longitude + cos(_markerIdCounter * pi / 6.0) / 20.0,
      ),
      infoWindow: InfoWindow(title: markerIdVal, snippet: '*'),
      onTap: () {
        print("MARKER taapped");
        // _onMarkerTapped(markerId);
      },
    );

    setState(() {
      // adding a new marker to map
      markers[markerId] = marker;
    });
  }

  @override
  Widget build(BuildContext context) {
    return  GoogleMap(
        zoomControlsEnabled: false,
        myLocationEnabled: true,
        onMapCreated: _onMapCreated,
        initialCameraPosition: CameraPosition(
          target:_center,//,
          zoom: 5,
        ),
      markers: Set<Marker>.of(markers.values),
    );
  }
}
