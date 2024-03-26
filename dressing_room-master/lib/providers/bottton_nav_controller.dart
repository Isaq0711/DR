import 'package:flutter/cupertino.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BottonNavController extends ChangeNotifier {
  bool isBottonVisible = true;

  void setBottomVisible(bool value) {
    isBottonVisible = value;
    notifyListeners();
  }
}

class CartCounterProvider extends ChangeNotifier {
  int cartQuantity = 0;

  CartCounterProvider() {
    _fetchCartQuantity();
  }

  Future<void> _fetchCartQuantity() async {
    var cartSnap = await FirebaseFirestore.instance
        .collection('cart')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get();

    var data = cartSnap.data()!;
    cartQuantity = data.length;
    notifyListeners();
  }

  void increment() {
    cartQuantity++;
    notifyListeners();
  }

  void decrement() {
    if (cartQuantity > 0) {
      cartQuantity--;
      notifyListeners();
    }
  }
}
