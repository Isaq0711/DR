import 'package:flutter/material.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'dart:typed_data';
import 'dart:async';
import 'package:dressing_room/providers/user_provider.dart';
import 'package:dressing_room/models/user.dart';
import 'package:provider/provider.dart';
import 'package:dressing_room/widgets/select_image_dialog.dart';
import 'package:dressing_room/utils/colors.dart';
import 'basket_screen.dart';

class TestAPIScreen extends StatefulWidget {
  const TestAPIScreen({Key? key}) : super(key: key);

  @override
  _TestAPIScreenState createState() => _TestAPIScreenState();
}

class _TestAPIScreenState extends State<TestAPIScreen> {
  List<Uint8List>? _files;
  List<Uint8List>? _bigfiles;
  bool isLoading = false;
  int _currentPageIndex = 0;
  PageController _pageController = PageController(initialPage: 0);
  bool _showNetworkImage = false;
  Timer? _timer;
  List<int> selectedIndexes = [];
  late double _panelHeightOpen;
  late double _panelHeightClosed;
  late bool _isPanelVisible;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      _selectBigImage(context);
    });
    _isPanelVisible = false;
  }

  void _showNetworkImageOnLongPress() {
    _timer = Timer(Duration(seconds: 1), () {
      setState(() {
        _showNetworkImage = true;
      });
    });
  }

  void _resetNetworkImage() {
    if (_timer != null && _timer!.isActive) {
      _timer!.cancel();
    }
    setState(() {
      _showNetworkImage = false;
    });
  }

  void _selectImage(BuildContext parentContext) async {
    showDialog(
      context: parentContext,
      builder: (BuildContext context) {
        return SelectImageDialog(
          onImageSelected: (Uint8List file) {
            setState(() {
              _files ??= [];
              _files!.add(file);
            });
          },
        );
      },
    );
  }

  void _selectBigImage(BuildContext parentContext) async {
    showDialog(
      context: parentContext,
      builder: (BuildContext context) {
        return SelectImageDialog(
          onImageSelected: (Uint8List file) {
            setState(() {
              _bigfiles ??= [];
              _bigfiles!.add(file);
            });
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    _panelHeightOpen = MediaQuery.of(context).size.height * 0.7;
    _panelHeightClosed = MediaQuery.of(context).size.height * 0.05;

    return Consumer<UserProvider>(
      builder: (context, userProvider, _) {
        var user = userProvider.getUser;
        if (user != null) {
          return _buildContent(user);
        } else {
          return Container();
        }
      },
    );
  }

  Scaffold _buildContent(User user) {
    return _bigfiles == null
        ? Scaffold(
            body: Container(),
          )
        : Scaffold(
            appBar: AppBar(
              backgroundColor: AppTheme.vinho,
              title: const Text(
                'Test API',
                style: TextStyle(color: Colors.white),
              ),
            ),
            body: Stack(
              children: [
                SingleChildScrollView(
                  child: Column(
                    children: <Widget>[
                      isLoading ? LinearProgressIndicator() : const SizedBox(height: 0.0),
                      const Divider(),
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          _bigfiles != null
                              ? SizedBox(
                                  height: MediaQuery.of(context).size.height * 0.55,
                                  child: PageView.builder(
                                    controller: _pageController,
                                    itemCount: _bigfiles!.length,
                                    onPageChanged: (int index) {
                                      setState(() {
                                        _currentPageIndex = index;
                                      });
                                    },
                                    itemBuilder: (context, pageIndex) {
                                      return ClipRRect(
                                        borderRadius: BorderRadius.circular(10.0),
                                        child: GestureDetector(
                                          onLongPress: () {
                                            _showNetworkImageOnLongPress();
                                          },
                                          onLongPressEnd: (details) {
                                            _resetNetworkImage();
                                          },
                                          child: _showNetworkImage
                                              ? Container(
                                                  height: MediaQuery.of(context).size.height * 0.55,
                                                  width: MediaQuery.of(context).size.width,
                                                  child: Image.network(
                                                    'https://i0.wp.com/inspi.com.br/wp-content/uploads/2019/11/bliss-Charles-ORear.jpg?fit=1000%2C804&ssl=1',
                                                    fit: BoxFit.cover,
                                                  ),
                                                )
                                              : Container(
                                                  height: MediaQuery.of(context).size.height * 0.55,
                                                  width: MediaQuery.of(context).size.width,
                                                  child: Image.memory(
                                                    _bigfiles![pageIndex],
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                        ),
                                      );
                                    },
                                  ),
                                )
                              : Container(),
                          Positioned(
                            top: MediaQuery.of(context).size.height * 0.47,
                            left: 0,
                            right: 0,
                            bottom: 0,
                            child: Container(
                              child: CustomScrollView(
                                scrollDirection: Axis.horizontal,
                                slivers: [
                                  SliverGrid(
                                    gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                                      maxCrossAxisExtent: 180,
                                      crossAxisSpacing: 20,
                                      mainAxisSpacing: 10,
                                    ),
                                    delegate: SliverChildBuilderDelegate(
                                      (BuildContext context, int index) {
                                        return GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              _currentPageIndex = index;
                                              _pageController.animateToPage(
                                                index,
                                                duration: const Duration(milliseconds: 300),
                                                curve: Curves.ease,
                                              );
                                            });
                                          },
                                          child: Container(
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                color: _currentPageIndex == index ? AppTheme.vinho : Colors.transparent,
                                                width: 3.0,
                                              ),
                                              borderRadius: BorderRadius.circular(10.0),
                                            ),
                                            child: ClipRRect(
                                              borderRadius: BorderRadius.circular(10.0),
                                              child: Image.memory(
                                                _bigfiles![index],
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                      childCount: _bigfiles!.length,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: () => _selectBigImage(context),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            const Icon(
                              Icons.add,
                              color: Colors.black,
                            ),
                            const SizedBox(width: 4),
                            const Text(
                              'Add More Photos',
                              style: TextStyle(
                                fontFamily: 'Quicksand',
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: MediaQuery.of(context).size.height * 0.008),
                      Container(
                        height: MediaQuery.of(context).size.height * 0.13,
                        child: CustomScrollView(
                          scrollDirection: Axis.horizontal,
                          slivers: [
                            SliverGrid(
                              gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                                maxCrossAxisExtent: 200,
                                childAspectRatio: 3 / 2,
                                crossAxisSpacing: 20,
                                mainAxisSpacing: 10,
                              ),
                              delegate: SliverChildBuilderDelegate(
                                (BuildContext context, int index) {
                                  return GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _currentPageIndex = index;
                                        _pageController.animateToPage(
                                          index,
                                          duration: const Duration(milliseconds: 300),
                                          curve: Curves.ease,
                                        );
                                      });
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: _currentPageIndex == index ? AppTheme.vinho : Colors.transparent,
                                          width: 3.0,
                                        ),
                                        borderRadius: BorderRadius.circular(10.0),
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(10.0),
                                        child: Image.memory(
                                          _bigfiles![index],
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                                childCount: _bigfiles!.length,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ElevatedButton(
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all<Color>(AppTheme.vinho),
                            ),
                            onPressed: () {
                              // TODO: Implement logic for check out
                            },
                            child: const Text(
                              'TRY OUTFIT',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SlidingUpPanel(
      
                  color: AppTheme.vinho,
                  maxHeight: _panelHeightOpen,
                  minHeight: _panelHeightClosed,
                  parallaxEnabled: true,
                  parallaxOffset: 0.5,
                  panel: BasketScreen(),
                  collapsed: GestureDetector(
                    onTap: () {
                      setState(() {
                        _isPanelVisible = !_isPanelVisible;
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppTheme.vinho,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(24.0),
                          topRight: Radius.circular(24.0),
                        ),
                      ),
                      child: Center(
                        child: Icon(Icons.remove),
                      ),
                    ),
                  ),
                  body: Container(),
                ),
              ],
            ),
          );
  }
}
