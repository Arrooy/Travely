import 'package:flutter/cupertino.dart';

final String pexelApiToken = "563492ad6f91700001000001e69ed8ad08eb4d24867553648a9521a9";

// MAPS: https://itsshivam.medium.com/guide-to-integrate-google-maps-with-flutter-db86d033ea25
// APIS: https://console.developers.google.com/apis/library?filter=category:maps&project=root-amulet-303207
final String  googleMapsAndroidToken = "AIzaSyA5Ay_HG2-RyeqtbQCViQE3XZkm4dk_taE";
final String  googleMapsIOSToken = "AIzaSyAiC37U7llwtHc0cU8lVhpRIsQWJjDlP_8";

// En teoria ha de ser multiplataforma.
final String googlePlacesApiToken = "AIzaSyAc4XLMDlLVeSatFQLqoTxuwjakIyWqFwo";

//https://tequila.kiwi.com/portal/my-solutions
final String tequilaApiToken = "nS0OLaxhbQ79iNHAcvMdZDM1Lmv6Qn8_";
String tequilaBaseURL = "https://tequila-api.kiwi.com";

double getPhoneWidth(BuildContext context){
  return MediaQuery.of(context).size.width * MediaQuery.of(context).devicePixelRatio;
}

double getPhoneHeight(BuildContext context){
  final padding = MediaQuery.of(context).padding;
  return MediaQuery.of(context).size.height * MediaQuery.of(context).devicePixelRatio - padding.top - padding.bottom;
}