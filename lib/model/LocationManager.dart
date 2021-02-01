
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:geolocator/geolocator.dart';

import 'package:travely/GenericDialog.dart';
import 'package:travely/ui_utils.dart';

enum PermissionError {
  locationServicesOff,
  permissionsDeniedForever,
  permissionsDenied,
  allOk
}

// Gestiona la localització de l'usauri.

class LocationManager {
  bool serviceEnabled;
  LocationPermission permission;

  LocationManager() {
    serviceEnabled = false;
  }

  Future<void> init() async {
    await checkPermisions();
  }

  // Revisa si l'usuari té l'ubicació activada i si ha acceptat els permisos.
  Future<PermissionError> checkPermisions() async {
    serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) return PermissionError.locationServicesOff;

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.deniedForever)
      return PermissionError.permissionsDeniedForever;
    if (permission == LocationPermission.denied)
      return PermissionError.permissionsDenied;

    return PermissionError.allOk;
  }

  // Solicita permisos de localització a l'usuari
  Future<PermissionError> requestPermission() async {
    LocationPermission permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always) {
      return PermissionError.allOk;
    } else {
      return PermissionError.permissionsDenied;
    }

  }

  // Obra les settings necesaries. Si l'usuari no té els servies de
  // localització activats, s'obra el menu de settings per acceptar.
  // Si l'usuari ha denegat l'acces, obra les opcions de la app.
  // Per a IOS no es pot fer aixo, directament s'obra settings.
  Future<void> openSettings() async {
  
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
    } else {
      await Geolocator.openAppSettings();
    }
  }

  // Retorna la posicio actual de l'usuari.
  // Accuracy representa la precisio desitjada.
  Future<Position> getPosition(LocationAccuracy accuracy) async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled ||
        permission == LocationPermission.deniedForever ||
        permission == LocationPermission.denied) {
      return null;
    }

    return await Geolocator.getCurrentPosition(desiredAccuracy: accuracy);
  }

  void _enterHome(BuildContext context, Function callback){
    Navigator.pushReplacementNamed(context, '/home',arguments: callback());
  }

  // S'encarreg d'obligar a l'usuari a activar el gps + acceptar localitzacio.
  // un cop tots els requisits son correctes, s'executa el callback
  // i es navega a la ruta home enviant com argument el resultat del callback!
  void mustHaveLocationDialogs(BuildContext context, Function callback) async {

    await init();

    switch (await checkPermisions()) {
      case PermissionError.allOk:
        // Tot correcte. No es mostra cap dialeg.
        _enterHome(context,callback);
        break;
      case PermissionError.permissionsDenied:
      // Mostrem un dialeg indicant que es necessari acceptar.
        GenericDialog.showLocDialog(
            context,
            "Travely needs your location to work",
            "This app uses your location to suggest the best places to travel to.\n\nPlease accept permissions dialog.",
            "Open permission dialog", () async {
          PermissionError result = await requestPermission();
          if (result == PermissionError.allOk) {
            _enterHome(context,callback);
          }else{
            Scaffold.of(context).showSnackBar(snackBar("Please accept the location permissions!","Solve", context, () => mustHaveLocationDialogs(context,callback)));
          }
        },popCallback:(){
          Scaffold.of(context).showSnackBar(snackBar("Unable to SignIn. Please accept the location permissions!","Solve", context, () => mustHaveLocationDialogs(context,callback)));
        });
        break;
      case PermissionError.permissionsDeniedForever:
      // Mostrem un dialeg indicant que es necessari acceptar.
      // Donem l'opcio d'obrir settings.

        GenericDialog.showLocDialog(
            context,
            "Travely needs your location to work",
            "This app uses your location to suggest the best places to travel to.\n\nPlease accept location permissions in your phone settings.",
            "Open system settings",(){
          openSettings();
        },
            popCallback: (){
              Scaffold.of(context).showSnackBar(snackBar("Unable to SignIn.\nPlease accept the location permissions from your system settings!","Open dialog", context, () => mustHaveLocationDialogs(context,callback)));
            });

        break;
      case PermissionError.locationServicesOff:
      // Mostrem un dialeg indicant que es necessari localització
      // Donem opcio d'obrir settings.
        GenericDialog.showLocDialog(
            context,
            "Travely needs location services",
            "This app uses your location to suggest the best places to travel to.\n\nPlease activate the device location!",
            "Open system settings",(){openSettings();},popCallback: (){
          Scaffold.of(context).showSnackBar(snackBar("Unable to SignIn. Please activate the device location!","Open dialog", context, () => mustHaveLocationDialogs(context,callback)));
        });

        break;
    }
  }
}
