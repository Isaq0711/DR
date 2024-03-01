import 'package:dressing_room/providers/bottton_nav_controller.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:dressing_room/utils/colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:dressing_room/utils/global_variable.dart';

class MobileScreenLayout extends StatefulWidget {
  const MobileScreenLayout({Key? key}) : super(key: key);

  @override
  State<MobileScreenLayout> createState() => _MobileScreenLayoutState();
}

class _MobileScreenLayoutState extends State<MobileScreenLayout> {
  int _page = 0;
  late PageController pageController;

  @override
  void initState() {
    super.initState();
    pageController = PageController();
    ;
  }

  @override
  void dispose() {
    super.dispose();
    pageController.dispose();
  }

  void onPageChanged(int page) {
    setState(() {
      _page = page;
    });
  }

  void navigateToFeedPage() {
    pageController.jumpToPage(0);
  }

  void navigationTapped(int page) {
    pageController.jumpToPage(page);
    print(FirebaseAuth.instance.currentUser!.uid);
  }

  @override
  Widget build(BuildContext context) {
    bool isBottomVisible = context.watch<BottonNavController>().isBottonVisible;
    return Scaffold(
        body: PageView(
          children: homeScreenItems,
          controller: pageController,
          onPageChanged: onPageChanged,
          physics: (_page == 0)
              ? NeverScrollableScrollPhysics()
              : PageScrollPhysics(),
        ),
        bottomNavigationBar: Visibility(
            visible: isBottomVisible,
            child: Container(
              decoration: BoxDecoration(
                color: AppTheme.cinza,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(18),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey,
                    spreadRadius: 2,
                    blurRadius: 5,
                  ),
                ],
              ),
              child: BottomNavigationBar(
                showSelectedLabels: false,
                showUnselectedLabels: false,
                elevation: 0,
                items: <BottomNavigationBarItem>[
                  BottomNavigationBarItem(
                    icon: Icon(
                      (_page == 0) ? Icons.home : Icons.home_outlined,
                      color: AppTheme.vinho,
                      size: 24.h,
                    ),
                    label: '',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(
                      (_page == 1)
                          ? Icons.notification_add
                          : Icons.notification_add_outlined,
                      color: AppTheme.vinho,
                      size: 24.h,
                    ),
                    label: '',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(
                      (_page == 2)
                          ? Icons.add_circle
                          : Icons.add_circle_outline,
                      color: AppTheme.vinho,
                      size: 24.h,
                    ),
                    label: '',
                  ),
                  BottomNavigationBarItem(
                    icon: ImageIcon(
                      (_page == 3)
                          ? AssetImage('assets/CLOSET-FILL.png')
                          : AssetImage('assets/CLOSET.png'),
                      color: AppTheme.vinho,
                      size: 24.h,
                    ),
                    label: '',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(
                      (_page == 4) ? Icons.person : Icons.person_outline,
                      color: AppTheme.vinho,
                      size: 24.h,
                    ),
                    label: '',
                  ),
                ],
                onTap: navigationTapped,
                currentIndex: _page,
                backgroundColor: Colors.transparent,
                type: BottomNavigationBarType.fixed,
              ),
            )));
  }
}
