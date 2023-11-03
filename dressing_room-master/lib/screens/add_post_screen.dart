import 'dart:typed_data';
import 'package:dressing_room/responsive/mobile_screen_layout.dart';
import 'package:dressing_room/responsive/responsive_layout.dart';
import 'package:dressing_room/responsive/web_screen_layout.dart';
import 'package:flutter/material.dart';
import 'package:dressing_room/providers/user_provider.dart';
import 'package:dressing_room/resources/firestore_methods.dart';
import 'package:dressing_room/utils/colors.dart';
import 'package:dressing_room/utils/utils.dart';
import 'package:dressing_room/widgets/select_image_dialog.dart';
import 'package:dressing_room/models/user.dart';
import 'package:provider/provider.dart';

class AddPostScreen extends StatefulWidget {
  const AddPostScreen({Key? key}) : super(key: key);

  @override
  _AddPostScreenState createState() => _AddPostScreenState();
}

class _AddPostScreenState extends State<AddPostScreen> {
  bool isAnonymous = false;
  List<Uint8List>? _files;
  bool isLoading = false;
  final TextEditingController _descriptionController = TextEditingController();
  PageController _pageController = PageController(initialPage: 0);
  int _currentPageIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      _selectImage(context);
    });
  }

   _selectImage(BuildContext parentContext) async {
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

 void postImages(String uid, String username, String profImage) async {
  setState(() {
    isLoading = true;
  });

  try {
    if (isAnonymous) {
      String res = await FireStoreMethods().uploadAnonymousPost(
        _descriptionController.text,
        _files!, 
        uid,
      );
      if (res == "success") {
        showSnackBar(
          context,
          'Posted!',
        );
        clearImages();
      } else {
        showSnackBar(context, res);
      }
    } else {
      String res = await FireStoreMethods().uploadPost(
        _descriptionController.text,
        _files!,
        uid,
        username,
        profImage,
      );
      if (res == "success") {
        showSnackBar(
          context,
          'Posted!',
        );
        clearImages();
      } else {
        showSnackBar(context, res);
      }
    }
  } catch (err) {
    showSnackBar(
      context,
      err.toString(),
    );
  }

  setState(() {
    isLoading = false;
  });
}

  void clearImages() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (context) => const ResponsiveLayout(
          mobileScreenLayout: MobileScreenLayout(),
          webScreenLayout: WebScreenLayout(),
        ),
      ),
      (route) => false,
    );
  }

  @override
  void dispose() {
    super.dispose();
    _descriptionController.dispose();
    _pageController.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
    return _files == null
        ? Scaffold(
            body: Container(),
          )
        : Scaffold(
            appBar: AppBar(
              backgroundColor: AppTheme.nearlyWhite,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                color: AppTheme.nearlyBlack,
                onPressed: clearImages,
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () => postImages(
                    user.uid!,
                    user.username,
                    user.photoUrl,
                  ),
                  child: const Text(
                    "Post",
                    style: TextStyle(
                      color: Colors.blueAccent,
                      fontWeight: FontWeight.bold,
                      fontSize: 16.0,
                    ),
                  ),
                ),
              ],
            ),
                body: Column(
                  children: <Widget>[
                    isLoading ? const LinearProgressIndicator() : const SizedBox(height: 0.0),
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        const Text('Anonymous Post', style: AppTheme.subheadline),
                        Switch(
                          value: isAnonymous,
                          activeColor: AppTheme.vinho,
                          activeTrackColor: Colors.grey,
                          inactiveTrackColor: Colors.grey,
                          onChanged: (value) {
                            setState(() {
                              isAnonymous = value;
                            });
                          },
                        ),
                      ],
                    ),
                    Flexible(
                      child: Stack(
                        children: [
                          PageView.builder(
                            controller: _pageController,
                            itemCount: _files!.length,
                            onPageChanged: (int index) {
                              setState(() {
                                _currentPageIndex = index;
                              });
                            },
                            itemBuilder: (context, pageIndex) {
                              return SizedBox(
                                height: MediaQuery.of(context).size.height * 0.5,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10.0),

                                  child: Image.memory(
                                    _files![pageIndex],
                                    fit: BoxFit.cover,
                                    height: double.infinity,
                                    width: double.infinity,
                                  ),
                                ),
                              );
                            },
                          ),
                          if (_currentPageIndex > 0)
                            Positioned(
                              top: MediaQuery.of(context).size.height / 2 - 15.0,
                              left: 16.0,
                              child: GestureDetector(
                                onTap: () {
                                  _pageController.animateToPage(_currentPageIndex - 1, duration: const Duration(milliseconds: 300), curve: Curves.ease);
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: AppTheme.vinho,
                                  ),
                                  child: const Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Icon(
                                      Icons.arrow_back_ios,
                                      color: Colors.white,
                                      size: 20.0,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          if (_currentPageIndex < (_files?.length ?? 0) - 1)
                            Positioned(
                              top: MediaQuery.of(context).size.height / 2 - 15.0,
                              right: 16.0,
                              child: GestureDetector(
                                onTap: () {
                                  _pageController.animateToPage(_currentPageIndex + 1, duration: const Duration(milliseconds: 300), curve: Curves.ease);
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: AppTheme.vinho,
                                  ),
                                  child: const Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Icon(
                                      Icons.arrow_forward_ios,
                                      color: Colors.white,
                                      size: 20.0,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () => _selectImage(context),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          const Icon(
                            Icons.add,
                            color: Colors.black,
                          ),
                          const SizedBox(width: 4),
                          const Text(
                            'Add More',
                            style: TextStyle(
                              fontFamily: 'Quicksand',
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          SizedBox(width: 20),
                        ],
                      ),
                    ),
                    if (_files!.length > 1)
               
                      Container(
                        height: MediaQuery.of(context).size.height * 0.15,
                        child: CustomScrollView(
                      scrollDirection: Axis.horizontal,
                      slivers: [
                        SliverGrid(
                          gridDelegate:
                              SliverGridDelegateWithMaxCrossAxisExtent(
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
                                    _files![index],
                                    fit: BoxFit.cover,
                                  ),
                                ),
                               ) );
                            },
                            childCount: _files!.length,
                          ),
                        ),
                      ],
                    ),
                  ),
                    SizedBox(
                      height: 100.0,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextField(
                          controller: _descriptionController,
                          style: AppTheme.title,
                          decoration: const InputDecoration(
                            hintText: "Write a caption...",
                            hintStyle: AppTheme.title,
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
      }
    
  
}
