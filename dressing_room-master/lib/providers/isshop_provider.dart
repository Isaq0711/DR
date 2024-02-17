import 'package:flutter/material.dart';

class ShopProvider with ChangeNotifier {
  bool _isShop = false;

  bool get isShop => _isShop;

  set isShop(bool value) {
    _isShop = value;
    notifyListeners();
  }
}
