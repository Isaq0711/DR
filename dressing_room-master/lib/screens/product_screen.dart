import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gap/gap.dart';
import 'package:flutter/material.dart';
import 'package:dressing_room/models/user.dart' as model;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:dressing_room/providers/user_provider.dart';
import 'package:dressing_room/resources/firestore_methods.dart';
import 'package:dressing_room/screens/comments_screen.dart';
import 'package:dressing_room/screens/profile_screen.dart';
import 'package:dressing_room/utils/colors.dart';
import 'package:dressing_room/utils/global_variable.dart';
import 'package:dressing_room/utils/utils.dart';
import 'package:dressing_room/widgets/like_animation.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'shopping_cart.dart';
import 'package:dots_indicator/dots_indicator.dart';

class ProductScreen extends StatefulWidget {
  final dynamic snap;

  const ProductScreen({
    Key? key,
    required this.snap,
  }) : super(key: key);

  @override
  _ProductScreenState createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  int selectedSize = 0;

  Map<String, List<String>> categorySizes = {
    'TOP': ['XS', 'S', 'M', 'L', 'XL'],
    'BOTTOM': ['34', '36', '38', '40', '42', '44'],
    'SHOES': ['34', '35', '36', '37', '38', '39', '40', '41', '42'],
    'COATS': ['PP', 'P', 'M', 'G', 'GG'],
  };

  PageController _pageController = PageController(initialPage: 0);

  int _currentPageIndex = 0;
  int _currentPhotoIndex = 0; // Added declaration

  @override
  void initState() {
    super.initState();
  }

  void goToNextImage() {
    setState(() {
      if (widget.snap['variation'] != null &&
          _currentPhotoIndex <
              widget.snap['variation'][_currentPageIndex]['photos'].length -
                  1) {
        _currentPhotoIndex++;
      } else {
        _currentPhotoIndex = 0;
      }
    });
  }

  void goToPreviousImage() {
    setState(() {
      if (widget.snap['variation'] != null && _currentPhotoIndex > 0) {
        _currentPhotoIndex--;
      } else {
        _currentPhotoIndex =
            widget.snap['variation'][_currentPageIndex]['photos'].length - 1;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, _) {
        model.User? user = userProvider.getUser;
        List<String> availableSizes =
            widget.snap['sizesAvailable'].map((index) {
          return categorySizes[widget.snap['selectedCategory']]![index];
        }).toList();
        var size = MediaQuery.of(context).size;

        if (user == null) {
          return Container();
        }

        return Scaffold(
          appBar: AppBar(
            elevation: 0,
            backgroundColor: Colors.transparent,
            leading: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(
                Icons.arrow_back_rounded,
                color: AppTheme.nearlyBlack,
              ),
            ),
            actions: [
              IconButton(
                onPressed: () {},
                icon: const Icon(
                  Icons.favorite_border,
                  color: AppTheme.nearlyBlack,
                ),
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(
                  Icons.shopping_bag_outlined,
                  color: AppTheme.nearlyBlack,
                ),
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(
                  Icons.share_outlined,
                  color: AppTheme.nearlyBlack,
                ),
              ),
            ],
            title: Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppTheme.cinza,
                  radius: 15,
                  backgroundImage: NetworkImage(
                    widget.snap['profImage'].toString(),
                  ),
                ),
                SizedBox(width: 10),
                Text(
                  widget.snap['username'],
                  style: AppTheme.subtitle,
                )
              ],
            ),
          ),
          body: ListView(
            children: [
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.grey,
                    ),
                    color: AppTheme.nearlyWhite,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onDoubleTap: () {},
                        onHorizontalDragEnd: (details) {
                          if (details.primaryVelocity! > 0) {
                            goToPreviousImage();
                          } else if (details.primaryVelocity! < 0) {
                            goToNextImage();
                          }
                        },
                        child: SizedBox(
                          width: size.width,
                          height: size.height * 0.45,
                          child: Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8.0),
                                child: Image.network(
                                  widget.snap['variations'][_currentPageIndex]
                                          ['photoUrls'][_currentPhotoIndex]
                                      .toString(),
                                  width: size.width,
                                  fit: BoxFit.cover,
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.5),
                          child: widget
                                      .snap['variations']
                                          [_currentPageIndex]!['photoUrls']
                                      .length >
                                  1
                              ? DotsIndicator(
                                  dotsCount: widget
                                          .snap['variations']
                                              [_currentPageIndex]!['photoUrls']
                                          .length ??
                                      0,
                                  position: _currentPhotoIndex,
                                  decorator: DotsDecorator(
                                    color: AppTheme.cinza,
                                    activeColor: AppTheme.vinho,
                                    spacing: const EdgeInsets.symmetric(
                                        horizontal: 4.0),
                                    size: const Size.square(8.0),
                                    activeSize: const Size(16.0, 8.0),
                                    activeShape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(4.0),
                                    ),
                                  ),
                                )
                              : SizedBox.shrink(),
                        ),
                      ),
                      SizedBox(
                        width: size.width,
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      widget.snap['description'],
                                      style: AppTheme.subheadline,
                                    ),
                                  ),
                                  Gap(10),
                                  Text(
                                    '\$${widget.snap['variations'][_currentPageIndex]['price'].toString()}',
                                    style: AppTheme.subheadlinevinho,
                                  ),
                                ],
                              ),
                              Gap(
                                size.height * 0.006,
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                    left: 10.0, top: 18.0, bottom: 10.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "Select Variation",
                                      style: AppTheme.title,
                                    ),
                                    Text(
                                      '${widget.snap['variations'][_currentPageIndex]['itemCount'].toString()}' +
                                          " Items available",
                                      style: AppTheme.caption,
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                height: size.height * 0.1,
                                child: GridView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: widget.snap['variations'].length,
                                  gridDelegate:
                                      SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 1,
                                    crossAxisSpacing: 8.0,
                                  ),
                                  itemBuilder: (context, index) {
                                    return GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          _currentPageIndex = index;
                                        });
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: AnimatedContainer(
                                          width: size.width * 0.15,
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                              color: _currentPageIndex == index
                                                  ? AppTheme.vinho
                                                  : Colors.transparent,
                                              width: 2,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          duration:
                                              const Duration(milliseconds: 200),
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            child: Image.network(
                                              widget.snap['variations']
                                                      ['photoUrls'][0]
                                                  .toString(),
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              Gap(
                                size.height * 0.003,
                              ),
                              Text(
                                  "Variation selected: " +
                                      '${widget.snap['variations'][_currentPageIndex]['variationdescription']}',
                                  style: AppTheme.caption),
                              Gap(
                                size.height * 0.006,
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                    left: 10.0, top: 10.0, bottom: 9.0),
                                child: Text(
                                  "Select Size",
                                  style: AppTheme.title,
                                ),
                              ),
                              SizedBox(
                                  width: size.width * 0.9,
                                  height: size.height * 0.08,
                                  child: ListView.builder(
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    scrollDirection: Axis.horizontal,
                                    itemCount: availableSizes.length,
                                    itemBuilder: (ctx, index) {
                                      var currentSize = availableSizes[index];
                                      return GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            selectedSize = index;
                                          });
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.all(10.0),
                                          child: AnimatedContainer(
                                            width: size.width * 0.12,
                                            decoration: BoxDecoration(
                                              color: selectedSize == index
                                                  ? AppTheme.vinho
                                                  : Colors.transparent,
                                              border: Border.all(
                                                color: AppTheme.vinho,
                                                width: 2,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(15),
                                            ),
                                            duration: const Duration(
                                                milliseconds: 200),
                                            child: Center(
                                              child: Text(
                                                currentSize,
                                                style: TextStyle(
                                                  fontSize: 17,
                                                  fontWeight: FontWeight.w500,
                                                  color: selectedSize == index
                                                      ? Colors.white
                                                      : Colors.black,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  )),
                              Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Center(
                                  child: ElevatedButton(
                                    onPressed: () {
                                      showModalBottomSheet(
                                        context: context,
                                        builder: (context) {
                                          return Container(
                                            color: AppTheme.cinza,
                                            padding: EdgeInsets.all(16),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Row(
                                                  children: [
                                                    Icon(
                                                      Icons.check_circle,
                                                      color: AppTheme.vinho,
                                                    ),
                                                    Gap(
                                                      size.width * 0.01,
                                                    ),
                                                    Text(
                                                      "Added to cart",
                                                      style: AppTheme.subtitle,
                                                    )
                                                  ],
                                                ),
                                                Gap(
                                                  size.height * 0.02,
                                                ),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Container(
                                                      width: size.width * 0.45,
                                                      decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8),
                                                        color: AppTheme.vinho,
                                                      ),
                                                      child: TextButton(
                                                        onPressed: () {
                                                          Navigator.pop(
                                                              context);
                                                        },
                                                        child: Text(
                                                            'Continue Shopping',
                                                            style: AppTheme
                                                                .subtitlewhite),
                                                      ),
                                                    ),
                                                    Container(
                                                      width: size.width * 0.45,
                                                      decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8),
                                                        color: AppTheme.vinho,
                                                      ),
                                                      child: TextButton(
                                                        onPressed: () {
                                                          Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                                builder:
                                                                    (context) =>
                                                                        ShoppingCart(
                                                                          uid: FirebaseAuth
                                                                              .instance
                                                                              .currentUser!
                                                                              .uid,
                                                                        )),
                                                          );
                                                        },
                                                        child: Text(
                                                            'Go to Cart',
                                                            style: AppTheme
                                                                .subtitlewhite),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                      );
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.all(12.0),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            'Add to Cart',
                                            style: TextStyle(fontSize: 16),
                                          ),
                                          SizedBox(width: 8),
                                          Icon(
                                            Icons.shopping_cart,
                                            size: 20,
                                          ),
                                        ],
                                      ),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      primary: AppTheme.vinho,
                                      onPrimary: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
