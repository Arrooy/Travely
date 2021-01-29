import 'package:flutter/cupertino.dart';

final String pexelToken = "563492ad6f91700001000001e69ed8ad08eb4d24867553648a9521a9";


// MAPS: https://itsshivam.medium.com/guide-to-integrate-google-maps-with-flutter-db86d033ea25
// APIS: https://console.developers.google.com/apis/library?filter=category:maps&project=root-amulet-303207
final String  googleMapsAndroidToken = "AIzaSyA5Ay_HG2-RyeqtbQCViQE3XZkm4dk_taE";
final String  googleMapsIOSToken = "AIzaSyAiC37U7llwtHc0cU8lVhpRIsQWJjDlP_8";

//https://tequila.kiwi.com/portal/my-solutions
final String tequilaApi = "nS0OLaxhbQ79iNHAcvMdZDM1Lmv6Qn8_";

double getPhoneWidth(BuildContext context){
  return MediaQuery.of(context).size.width * MediaQuery.of(context).devicePixelRatio;
}

double getPhoneHeight(BuildContext context){
  final padding = MediaQuery.of(context).padding;
  return MediaQuery.of(context).size.height * MediaQuery.of(context).devicePixelRatio - padding.top - padding.bottom;
}