import 'package:flutter/material.dart';
import 'package:dressing_room/models/user.dart';
import 'package:dressing_room/resources/auth_methods.dart';
import 'package:dressing_room/screens/login_screen.dart';

class UserProvider with ChangeNotifier {
  User? _user;
  final AuthMethods _authMethods = AuthMethods();
  bool _isInitialized = false;

  User? get getUser => _user; // alterado para nullable

  Future<void> refreshUser(BuildContext context) async {
    if (!_isInitialized) {
      _isInitialized = true;
      _user = await _authMethods.getUserDetails();
      if (_user == null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen()),
        );
      } else {
        notifyListeners();
      }
    } else {
      _user = await _authMethods.getUserDetails();
      if (_user == null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen()),
        );
      } else {
        notifyListeners();
      }
    }
  }
}
