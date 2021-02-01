import 'package:firebase_database/firebase_database.dart';

Object getFirebaseReference(String name) {
  var ref = FirebaseDatabase().reference().child(name);
  return ref;
}

