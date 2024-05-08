import 'package:dressing_room/screens/add.dart';
import 'package:dressing_room/screens/wardrobe_menu.dart';
import 'package:dressing_room/screens/store_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:dressing_room/screens/feed_screen.dart';
import 'package:dressing_room/screens/profile_screen.dart';
import 'package:dressing_room/models/notifications.dart';

const webScreenSize = 600;

List<Widget> homeScreenItems = [
  const FeedScreen(),
  GeolocatorWidget(),
  AddPage(),
  WardrobeMenu(),
  ProfileScreen(uid: FirebaseAuth.instance.currentUser!.uid),
];
