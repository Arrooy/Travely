import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:travely/TrendPagePreview.dart';
import 'package:travely/model/Booking.dart';
import 'package:travely/tequila.dart';
import 'package:travely/ui_utils.dart';

import 'model/LocationManager.dart';

class TravelyMaps extends StatefulWidget {
  TravelyMaps(key1):super(key:key1);

  @override
  _TravelyMaps createState() => _TravelyMaps();
}

class _TravelyMaps extends State<TravelyMaps> {
  GoogleMapController mapController;
  Set<Marker> _markers = {};
  Future _userLocationFuture;

  Position _userPosition;
  List<String> _nearAirports;

  bool _mutex = false;

  @override
  void initState() {
    _userLocationFuture = Provider.of<LocationManager>(context, listen: false).getPosition(LocationAccuracy.high);
    super.initState();
  }

  void _onMapCreated(GoogleMapController controller) async{
    mapController = controller;

    _populateMapWithBookings();
  }

  void addMarker(LatLng pos, String destination, int price, Booking bk){
    Marker marker = Marker(
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      markerId: MarkerId("$destination"),
      position: pos ,
      infoWindow: InfoWindow(title: "$destination - $price€", snippet: 'Click here to see more information', onTap: (){
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => TrendPagePreview(bk)),
        );
      }),
      onTap: () async{
        await mapController.animateCamera(CameraUpdate.newLatLng(pos));
      },
    );
    _markers.add(marker);
  }

  @override
  Widget build(BuildContext context) {
    return  FutureBuilder<Position>(
      future: _userLocationFuture ,
      builder: (context, snapshot){
        if(snapshot.hasData && snapshot.connectionState == ConnectionState.done){
          _userPosition = snapshot.data;
          return GoogleMap(
            zoomControlsEnabled: false,
            myLocationEnabled: true,
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(
              target:LatLng(snapshot.data.latitude,snapshot.data.longitude),
              zoom: 5,
            ),
            onCameraIdle: (){
              _populateMapWithBookings();
            },

            markers: _markers,
          );
        }
        return futureLoading("Loading maps");
      });
  }

  void _populateMapWithBookings() async{
    // Mutex evita cridar multiples cops la funció.
    if(!_mutex){
      _mutex = true;

      LatLngBounds bounds = await mapController.getVisibleRegion();

      if(_nearAirports == null) _nearAirports = await Tequila.searchAirportsNearPos(_userPosition, 5);

      List<dynamic> viewLocations = await Tequila.searchCitiesInView(bounds, 20);

      List<Booking> bookings = await Tequila.searchFlightsToDestinations(_nearAirports, flyToDestinations: viewLocations[0], positions: viewLocations[1], dayRange: 7);

      for (var bk in bookings){
        addMarker(LatLng(bk.position.latitude, bk.position.longitude),bk.destination,bk.price,bk);
      }

      setState(() {});
      _mutex = false;
    }

  }
}
