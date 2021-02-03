import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:travely/ui_utils.dart';

import 'model/LocationManager.dart';

class TravelyMaps extends StatefulWidget {
  @override
  _TravelyMaps createState() => _TravelyMaps();
}

class _TravelyMaps extends State<TravelyMaps> {
  GoogleMapController mapController;

  // Madrid per començar
  LatLng _center = const LatLng(40.416775, -3.703790);

  void _onMapCreated(GoogleMapController controller) async{
    mapController = controller;

    Position pos = await Provider.of<LocationManager>(context, listen: false)
          .getPosition(LocationAccuracy.high);

    mapController.moveCamera(CameraUpdate.newLatLng(LatLng(pos.latitude,pos.longitude)));
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
        )
    );
  }
}
