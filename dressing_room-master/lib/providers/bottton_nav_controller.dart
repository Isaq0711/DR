import 'package:flutter/cupertino.dart';

class BottonNavController extends ChangeNotifier {
  bool isBottonVisible = true;

  void setBottomVisible(bool value) {
    isBottonVisible = value;
    notifyListeners();
  }
}
