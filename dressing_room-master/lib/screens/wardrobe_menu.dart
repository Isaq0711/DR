import 'package:flutter/material.dart';
import 'package:dressing_room/utils/colors.dart';
import 'add_cloth_screen.dart';
import 'package:gap/gap.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:dressing_room/screens/outfit_screen.dart';

class WardrobeMenu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final buttonWidth = 40.0; // Largura do primeiro botão

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Wardrobe Menu',
          style: AppTheme.subheadlinewhite,
        ),
        backgroundColor: AppTheme.vinho,
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Gap(MediaQuery.of(context).size.width * 0.4),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.vinho,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                padding:
                    EdgeInsets.symmetric(horizontal: buttonWidth, vertical: 20),
              ),
              child: Text('See my wardrobe', style: AppTheme.headlinewhite),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddClothScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.vinho,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                padding:
                    EdgeInsets.symmetric(horizontal: buttonWidth, vertical: 20),
              ),
              child: Text('Add cloth', style: AppTheme.headlinewhite),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.vinho,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                padding:
                    EdgeInsets.symmetric(horizontal: buttonWidth, vertical: 20),
              ),
              child: Text('Plan a look', style: AppTheme.headlinewhite),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => OutfitScreen(
                        uid: FirebaseAuth.instance.currentUser!.uid),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.vinho,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                padding:
                    EdgeInsets.symmetric(horizontal: buttonWidth, vertical: 20),
              ),
              child: Text('Calendário', style: AppTheme.headlinewhite),
            ),
          ],
        ),
      ),
    );
  }
}
