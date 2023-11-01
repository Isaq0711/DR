import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:dressing_room/utils/colors.dart';
import 'package:dressing_room/utils/global_variable.dart';
class MobileScreenLayout extends StatefulWidget {
  const MobileScreenLayout({Key? key}) : super(key: key);

  @override
  State<MobileScreenLayout> createState() => _MobileScreenLayoutState();
}

class _MobileScreenLayoutState extends State<MobileScreenLayout> {
  int _page = 0;
  late PageController pageController; // for tabs animation

  @override
  void initState() {
    super.initState();
    pageController = PageController();
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
    // Navigates to the FeedPage by changing the page index
    pageController.jumpToPage(0);
  }

  void navigationTapped(int page) {
    // Animating Page
    pageController.jumpToPage(page);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        children: homeScreenItems,
        controller: pageController,
        onPageChanged: onPageChanged,
      ),
      bottomNavigationBar: CupertinoTabBar(
        backgroundColor: AppTheme.vinho,
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(
              Icons.home,
              color: (_page == 0) ? AppTheme.nearlyWhite : Colors.grey,
            ),
            label: '',
            backgroundColor: AppTheme.nearlyWhite,
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.shopping_cart,
              color: (_page == 1) ? AppTheme.nearlyWhite : Colors.grey,
            ),
            label: '',
            backgroundColor: AppTheme.nearlyWhite,
          ),
          BottomNavigationBarItem(
            icon: SizedBox.shrink(), // Remove o ícone "add" original
            label: '',
            backgroundColor: AppTheme.nearlyWhite,
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.notification_add,
              color: (_page == 3) ? AppTheme.nearlyWhite : Colors.grey,
            ),
            label: '',
            backgroundColor: AppTheme.nearlyWhite,
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.person,
              color: (_page == 4) ? AppTheme.nearlyWhite : Colors.grey,
            ),
            label: '',
            backgroundColor: AppTheme.nearlyWhite,
          ),
        ],
        onTap: navigationTapped,
        currentIndex: _page,
      ),
      floatingActionButton: Container(
        margin: EdgeInsets.only(bottom: 16.0),
        child: Align(
          alignment: Alignment.bottomCenter,
          child: FractionallySizedBox(
            widthFactor: 0.5, // Define a largura do botão como metade da tela
            child: FlutterActionButton(
              onPressed: () {
                navigationTapped(2);
              },
              child: Icon(Icons.add, size: 25),
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}

class FlutterActionButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Widget child;

  const FlutterActionButton({
    Key? key,
    required this.onPressed,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 4.0,
      shape: CircleBorder(),
      clipBehavior: Clip.hardEdge,
      color: AppTheme.vinho,
      child: InkWell(
        onTap: onPressed,
        child: Padding(
          padding: EdgeInsets.all(10.0),
          child: child,
        ),
      ),
    );
  }
}
