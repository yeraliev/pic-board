import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/foundation.dart';


class UserProvider extends ChangeNotifier {
  firebase_auth.User? _user;
  final firebase_auth.FirebaseAuth _auth = firebase_auth.FirebaseAuth.instance;

  UserProvider() {
    _auth.userChanges().listen((firebase_auth.User? user) {
      _user = user;
      notifyListeners();
    });
  }

  firebase_auth.User? get user => _user;
}