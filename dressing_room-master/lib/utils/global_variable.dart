import 'package:dressing_room/screens/add.dart';
import 'package:dressing_room/screens/basket_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:dressing_room/screens/feed_screen.dart';
import 'package:dressing_room/screens/profile_screen.dart';
import 'package:dressing_room/screens/shopping_cart.dart';
import 'package:dressing_room/screens/basket_screen.dart';

const webScreenSize = 600;

List<Widget> homeScreenItems = [
  const FeedScreen(),
  ShoppingCart(),
  AddPage(),
  BasketScreen(), // NotificationPage(uid: FirebaseAuth.instance.currentUser!.uid,),
  ProfileScreen(
    uid: FirebaseAuth.instance.currentUser!.uid,
  ),
];
