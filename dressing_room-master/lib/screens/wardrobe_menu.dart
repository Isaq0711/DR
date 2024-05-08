import 'package:dressing_room/screens/handle_outside_media.dart';
import 'package:dressing_room/screens/tinder_like_page.dart';
import 'package:flutter/material.dart';
import 'package:dressing_room/utils/colors.dart';
import 'add_cloth_screen.dart';
import 'package:gap/gap.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:dressing_room/screens/outfit_screen.dart';
import 'package:dressing_room/screens/my_wardrobe.dart';

class WardrobeMenu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final buttonWidth = 40.0; // Largura do primeiro botão

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "WARDROBE MENU",
          style: AppTheme.barapp.copyWith(
            shadows: [
              Shadow(
                blurRadius: 2.0,
                color: Colors.black, //
              ),
            ],
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GridView.count(
                  shrinkWrap: true,
                  crossAxisCount: 2,
                  padding: EdgeInsets.all(20.0),
                  crossAxisSpacing: 20.0,
                  mainAxisSpacing: 20.0,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => Wardrobe(isDialog: false)),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.vinho,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ImageIcon(
                            AssetImage(
                              'assets/CLOSET-FILL.png',
                            ),
                            size: 40,
                            color: AppTheme.nearlyWhite,
                          ),
                          Gap(10),
                          Text('My wardrobe',
                              style: AppTheme.subheadlinewhite,
                              textAlign: TextAlign.center),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => AddClothScreen()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.vinho,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_circle,
                            size: 40,
                            color: AppTheme.nearlyWhite,
                          ),
                          Gap(10),
                          Text('Add cloth',
                              style: AppTheme.subheadlinewhite,
                              textAlign: TextAlign.center),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TinderScreen(
                                uid: FirebaseAuth.instance.currentUser!.uid),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.vinho,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ImageIcon(
                            AssetImage(
                              'assets/CABIDE.png',
                            ),
                            size: 55,
                            color: AppTheme.nearlyWhite,
                          ),
                          Gap(10),
                          Text('Plan a look',
                              style: AppTheme.subheadlinewhite,
                              textAlign: TextAlign.center),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => HandleOutsideMedia()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.vinho,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.calendar_month_sharp,
                            size: 40,
                            color: AppTheme.nearlyWhite,
                          ),
                          Gap(10),
                          Text('Calendário', style: AppTheme.subheadlinewhite),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
