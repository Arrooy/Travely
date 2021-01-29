import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';


class TravelyMaps extends StatefulWidget {
  @override
  _TravelyMaps createState() => _TravelyMaps();
}

class _TravelyMaps extends State<TravelyMaps> {

  GoogleMapController mapController;

  final LatLng _center = const LatLng(20.5937, 78.9629);

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    return  GoogleMap(
          onMapCreated: _onMapCreated,
          initialCameraPosition: CameraPosition(
            target: _center,
            zoom: 4,
          ),

    );
  }
}
