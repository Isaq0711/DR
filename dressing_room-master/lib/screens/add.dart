import 'package:flutter/material.dart';
import 'package:dressing_room/utils/colors.dart';
import 'add_post_screen.dart';
import 'add_votations_screen.dart';
import 'test_api_screen.dart';
import 'package:gap/gap.dart';

class AddPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final buttonWidth = 40.0; // Largura do primeiro botão

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Add Page',
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
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddPostScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.vinho,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                padding: EdgeInsets.symmetric(horizontal: buttonWidth, vertical: 20),
              ),
              child: Text('Add a publication', style: AppTheme.headlinewhite),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddVotationsScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.vinho,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                padding: EdgeInsets.symmetric(horizontal: buttonWidth, vertical: 20),
              ),
              child: Text(' Add a votation   ', style: AppTheme.headlinewhite),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => TestAPIScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.vinho,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                padding: EdgeInsets.symmetric(horizontal: buttonWidth, vertical: 20),
              ),
              child: Text('I.A.R.A', style: AppTheme.headlinewhite),
            ),
          ],
        ),
      ),
    );
  }
}
