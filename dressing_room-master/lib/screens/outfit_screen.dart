import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:dressing_room/utils/colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:gap/gap.dart';
import 'package:dressing_room/utils/utils.dart';
import 'package:dressing_room/resources/storage_methods.dart';
import 'package:dressing_room/widgets/select_image_dialog.dart';

class OutfitScreen extends StatefulWidget {
  final String uid;

  const OutfitScreen({Key? key, required this.uid}) : super(key: key);

  @override
  _OutfitScreenState createState() => _OutfitScreenState();
}

class _OutfitScreenState extends State<OutfitScreen> {
  var userData = {};
  List<String> places = ["home", "job", "mall"];
  final TextEditingController _usernameController = TextEditingController();

  bool isLoading = false;

  List<String> shirtImages = [
    'https://i.pinimg.com/originals/bb/c3/5e/bbc35e5e40de2799464a1fd65047021b.png',
  ];

  List<String> pantsImages = [
    'https://cdn-icons-png.flaticon.com/512/808/808726.png',
    // Add more pants image URLs as needed
  ];

  List<String> shoesImages = [
    'https://static.nike.com/a/images/t_default/c8303f03-237e-4978-8872-60187b9c0883/custom-nike-dunk-high-by-you-shoes.png',
  ];

  PageController _shirtController = PageController();
  PageController _pantsController = PageController();
  PageController _shoesController = PageController();

  @override
  void initState() {
    super.initState();
    getData();
  }

  getData() async {
    setState(() {
      isLoading = true;
    });
    try {
      var userSnap = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.uid)
          .get();

      userData = userSnap.data()!;

      setState(() {});
    } catch (e) {
      showSnackBar(
        context,
        e.toString(),
      );
    }
    setState(() {
      isLoading = false;
    });
  }

  Widget buildImageList(List<String> images, PageController controller) {
    return SizedBox(
      height: 120.h,
      child: PageView.builder(
        controller: controller,
        itemCount: images.length,
        itemBuilder: (context, index) {
          return Stack(
            alignment: Alignment.center,
            children: [
              Image.network(
                images[index],
                fit: BoxFit.contain,
                width: 700.h,
              ),
              Positioned(
                left: 45,
                child: IconButton(
                  icon: Icon(Icons.arrow_back, color: Colors.black),
                  onPressed: () {
                    if (index > 0) {
                      controller.previousPage(
                        duration: Duration(milliseconds: 300),
                        curve: Curves.ease,
                      );
                    }
                  },
                ),
              ),
              Positioned(
                right: 45,
                child: IconButton(
                  icon: Icon(Icons.arrow_forward, color: Colors.black),
                  onPressed: () {
                    if (index < images.length - 1) {
                      controller.nextPage(
                        duration: Duration(milliseconds: 300),
                        curve: Curves.ease,
                      );
                    }
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const Center(
            child: CircularProgressIndicator(),
          )
        : Scaffold(
            appBar: AppBar(
              iconTheme: IconThemeData(color: AppTheme.vinho),
              backgroundColor: Colors.transparent,
              actions: [
                IconButton(
                    onPressed: () {},
                    icon: Icon(
                      shadows: <Shadow>[
                        Shadow(color: AppTheme.nearlyBlack, blurRadius: 5.0)
                      ],
                      CupertinoIcons.info,
                    ))
              ],
            ),
            body: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: AppTheme.vinho,
                            child: Icon(Icons.wb_sunny, color: Colors.white),
                          ),
                          SizedBox(width: 8),
                          Column(
                            children: [
                              Text(
                                'Sunny',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              Text(
                                '30°C',
                                style: TextStyle(
                                    fontSize: 16, color: Colors.black),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Gap(8),
                      FloatingActionButton.extended(
                        onPressed: () {
                          setState(() {
                            // Your logic here
                          });
                        },
                        backgroundColor: AppTheme.vinho,
                        elevation: 2.0,
                        label: Text("PLAN", style: AppTheme.subtitlewhite),
                        icon: Icon(Icons.calendar_today, color: Colors.white),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          side: BorderSide(color: AppTheme.darkerText),
                        ),
                      ),
                    ],
                  ),
                ),
                Gap(30),
                Center(
                  child: Text(
                    '${DateFormat('MMMM').format(DateTime.now())} ${DateTime.now().day}th ',
                    style: AppTheme.subheadline,
                  ),
                ),
                Gap(30),

                // Image displays for shirts, pants, and shoes
                Column(
                  children: [
                    buildImageList(shirtImages, _shirtController),
                    Gap(20.h),
                    buildImageList(pantsImages, _pantsController),
                    Gap(20.h),
                    buildImageList(shoesImages, _shoesController),
                    Gap(20.h),
                  ],
                ),
              ],
            ),
            bottomNavigationBar: BottomAppBar(
              height: 40.h,
              color: Colors.transparent,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 70.0), // Temporary solution
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.close,
                        color: AppTheme.vinho,
                      ),
                      onPressed: () {
                        setState(() {});
                      },
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.check,
                        color: AppTheme.vinho,
                      ),
                      onPressed: () {
                        setState(() {});
                      },
                    ),
                  ],
                ),
              ),
            ),
          );
  }
}
