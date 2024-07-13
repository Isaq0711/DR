import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/cupertino.dart';
import 'package:gap/gap.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/material.dart';
import 'package:dressing_room/models/user.dart' as model;
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:dressing_room/providers/user_provider.dart';
import 'package:dressing_room/resources/firestore_methods.dart';
import 'package:dressing_room/screens/seepost.dart';
import 'package:dressing_room/screens/store_screen.dart';
import 'package:dressing_room/utils/colors.dart';
import 'package:dressing_room/utils/utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

class NewProductCard extends StatefulWidget {
  final snap;

  const NewProductCard({
    Key? key,
    required this.snap,
  }) : super(key: key);

  @override
  State<NewProductCard> createState() => _NewProductCardState();
}

class _NewProductCardState extends State<NewProductCard> {
  int commentLen = 0;
  bool isLikeAnimating = false;
  bool isAddedOnCart = false;
  bool isAddedOnFav = false;
  int selectedSize = 0;
  Map<String, List<String>> categorySizes = {
    'Pernas': ['34', '36', '38', '40', '42', '44'],
    'Pés': ['34', '35', '36', '37', '38', '39', '40', '41', '42'],
    'Tronco': ['PP', 'P', 'M', 'G', 'GG', 'XGG'],
    'Body (corpo inteiro)': ['PP', 'P', 'M', 'G', 'GG', 'XGG'],
    'Top (cabeça)': ['P', 'M', 'G'],
    "Mão": [],
    "Pulso": [],
    "Pescoço": [],
    "Cintura": ['34', '36', '38', '40', '42', '44'],
    'Rosto': [],
  };
  bool showreactions = false;
  int currentImageIndex = 0;
  bool isFavorite = false;
  List<String> availableSizes = [];

  double rating = 0;

  @override
  void initState() {
    super.initState();
    generateAvailableSizes();
    fetchCommentLen();
    isOnFav(
      widget.snap['productId'],
    );
    isOnCart(
      widget.snap['productId'],
    );
  }

  void generateAvailableSizes() {
    List<dynamic>? sizesIndices =
        widget.snap['variations'][0]['sizesAvailable'] as List<dynamic>;

    if (sizesIndices.isNotEmpty) {
      String selectedCategory = widget.snap['category'];

      availableSizes = sizesIndices.map((index) {
        return categorySizes[selectedCategory]![index];
      }).toList();
    }
  }

  Future<bool> isOnCart(String productId) async {
    try {
      DocumentSnapshot cartDoc = await FirebaseFirestore.instance
          .collection('cart')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .get();

      if (cartDoc.exists) {
        Map<String, dynamic> cartData = cartDoc.data() as Map<String, dynamic>;
        if (cartData.containsKey(productId)) {
          isAddedOnCart = true;
        }
      }
    } catch (e) {
      showSnackBar(
        context,
        e.toString(),
      );
    }
    return false;
  }

  Future<bool> isOnFav(String postId) async {
    try {
      DocumentSnapshot fav = await FirebaseFirestore.instance
          .collection('favorites')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection('userFavorites')
          .doc(postId)
          .get();

      if (fav.exists) {
        setState(() {
          isAddedOnFav = true; // Defina o estado inicial do ícone
        });
        return true;
      } else {
        setState(() {
          isAddedOnFav = false; // Defina o estado inicial do ícone
        });
        return false;
      }
    } catch (e) {
      showSnackBar(
        context,
        e.toString(),
      );
      return false;
    }
  }

  fetchCommentLen() async {
    try {
      QuerySnapshot snap = await FirebaseFirestore.instance
          .collection('posts')
          .doc(widget.snap['postId'])
          .collection('comments')
          .get();
      commentLen = snap.docs.length;
    } catch (err) {
      showSnackBar(
        context,
        err.toString(),
      );
    }
    setState(() {});
  }

  deletePost(String postId) async {
    try {
      await FireStoreMethods().deletePost(postId);
    } catch (err) {
      showSnackBar(
        context,
        err.toString(),
      );
    }
  }

  Future<void> handleCartAction(String uid) async {
    setState(() {});

    try {
      if (!isAddedOnCart) {
        String res = await FireStoreMethods()
            .removeFromCart(uid, widget.snap['productId'], context);

        if (res == "success") {
          showSnackBar(context, 'Removed from cart');
          isAddedOnCart = false;
        } else {
          showSnackBar(context, res);
        }
      } else {
        String res = await FireStoreMethods().uploadtoCart(
            widget.snap['description'],
            uid,
            widget.snap['username'],
            widget.snap['productId'],
            widget.snap['type'],
            widget.snap['variations'][0]['variationdescription'],
            availableSizes[selectedSize],
            widget.snap['variations'][0]['photoUrls'][0],
            widget.snap['variations'][0]['price'],
            context);

        if (res == "success") {
          showSnackBar(context, 'Added to cart');
          isAddedOnCart = true;
        } else {
          showSnackBar(context, res);
        }
      }
    } catch (err) {
      showSnackBar(context, err.toString());
    }

    setState(() {});
  }

  Future<void> handleFavAction(String uid) async {
    setState(() {});

    try {
      await FireStoreMethods().toggleFavorite(widget.snap['productId'], uid);
    } catch (err) {
      showSnackBar(context, err.toString());
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, _) {
        model.User? user = userProvider.getUser;

        if (user == null) {
          return Container();
        }

        return Card(
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
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SeePost(
                          isTagclicked: false,
                          postId: widget.snap['productId']),
                    ),
                  );
                },
                onDoubleTap: () {
                  showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        int position = currentImageIndex;
                        return Dialog(
                          backgroundColor: AppTheme.nearlyWhite,
                          child: StatefulBuilder(
                            builder:
                                (BuildContext context, StateSetter setState) {
                              return Padding(
                                padding: EdgeInsets.all(8),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    SizedBox(
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.7,
                                      width: double.infinity,
                                      child: ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                        child: PageView.builder(
                                          itemCount:
                                              widget.snap['variations'].length,
                                          controller: PageController(
                                              initialPage: currentImageIndex),
                                          onPageChanged: (index) {
                                            setState(() {
                                              position = index;
                                            });
                                          },
                                          itemBuilder: (context, index) {
                                            return ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(25.0),
                                              child: Image.network(
                                                widget.snap['variations'][index]
                                                    ['photoUrls'][0],
                                                fit: BoxFit.cover,
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 4.5),
                                      child: widget.snap['variations'].length >
                                              1
                                          ? DotsIndicator(
                                              dotsCount: widget
                                                  .snap['variations'].length,
                                              position: position,
                                              decorator: DotsDecorator(
                                                color: Colors.grey,
                                                activeColor: AppTheme.vinho,
                                                spacing:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 4.0),
                                                size: const Size.square(8.0),
                                                activeSize:
                                                    const Size(16.0, 8.0),
                                                activeShape:
                                                    RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          4.0),
                                                ),
                                              ),
                                            )
                                          : SizedBox.shrink(),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(10.0),
                                      child: Center(
                                        child: ElevatedButton(
                                          onPressed: () {},
                                          child: Padding(
                                            padding: const EdgeInsets.all(12.0),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Text(
                                                  'Add to Cart',
                                                  style:
                                                      TextStyle(fontSize: 16),
                                                ),
                                                Gap(8),
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
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                            ),
                                          ),
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              );
                            },
                          ),
                        );
                      });
                },
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                        width: double.infinity,
                        height: double.infinity,
                        child: AspectRatio(
                          aspectRatio: 9 / 16,
                          child: ClipRRect(
                              borderRadius: BorderRadius.circular(10.0),
                              child: ClipRRect(
                                child: Image.network(
                                  widget.snap['variations'][0]['photoUrls'][0],
                                  fit: BoxFit.cover,
                                ),
                              )),
                        )),
                    widget.snap['variations'].length > 1
                        ? Positioned(
                            top: 10,
                            left: 10,
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  vertical: 4, horizontal: 8),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.6),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                'Variação ${currentImageIndex + 1} de ${widget.snap['variations'].length}',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          )
                        : Container(),
                    Positioned(
                      top: 5,
                      right: 10,
                      child: Column(
                        children: [
                          Gap(5.h),
                          SpeedDial(
                            direction: SpeedDialDirection.down,
                            child: Icon(
                              Icons.more_vert_rounded,
                              size: 28,
                            ),
                            buttonSize: Size(1.0, 29.0),
                            closeManually: false,
                            curve: Curves.bounceIn,
                            overlayColor: Colors.black,
                            overlayOpacity: 0.5,
                            backgroundColor: AppTheme.cinza,
                            foregroundColor: Colors.black,
                            elevation: 8.0,
                            shape: CircleBorder(),
                            children: [
                              SpeedDialChild(
                                child: isAddedOnFav
                                    ? Icon(
                                        CupertinoIcons.heart_fill,
                                        color: Colors.black.withOpacity(0.6),
                                      )
                                    : Icon(
                                        CupertinoIcons.heart,
                                        color: Colors.black.withOpacity(0.6),
                                      ),
                                backgroundColor: AppTheme.cinza,
                                onTap: () {
                                  setState(() {
                                    isAddedOnFav = !isAddedOnFav;
                                    Future.delayed(Duration(milliseconds: 500),
                                        () {
                                      isAddedOnFav
                                          ? showSnackBar(
                                              context, 'Added to Favorites')
                                          : showSnackBar(context,
                                              'Removed from Favorites');
                                    });
                                  });
                                  Future.microtask(() {
                                    handleFavAction(
                                        FirebaseAuth.instance.currentUser!.uid);
                                  });
                                },
                              ),
                              SpeedDialChild(
                                child: isAddedOnCart
                                    ? Icon(
                                        Icons.shopping_cart,
                                        color: Colors.black.withOpacity(0.6),
                                      )
                                    : Icon(
                                        Icons.shopping_cart_outlined,
                                        color: Colors.black.withOpacity(0.6),
                                      ),
                                backgroundColor: AppTheme.cinza,
                                labelStyle: TextStyle(fontSize: 18.0),
                                onTap: () {
                                  setState(() {
                                    isAddedOnCart = !isAddedOnCart;
                                  });
                                  Future.microtask(() {
                                    handleCartAction(
                                        FirebaseAuth.instance.currentUser!.uid);
                                  });
                                },
                              ),
                              SpeedDialChild(
                                child: Icon(
                                  CupertinoIcons.bag,
                                  color: Colors.black.withOpacity(0.6),
                                ),
                                backgroundColor: AppTheme.cinza,
                                labelStyle: TextStyle(fontSize: 18.0),
                                onTap: () => print('THIRD CHILD'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 26, vertical: 5),
                            child: Column(children: [
                              Row(
                                children: <Widget>[
                                  Container(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.3),
                                          spreadRadius:
                                              2, // Espalhamento da sombra
                                          blurRadius: 5, // Difusão da sombra
                                          offset: Offset(
                                              0, 3), // Deslocamento da sombra
                                        ),
                                      ],
                                    ),
                                    child: CircleAvatar(
                                      radius: 16,
                                      backgroundImage: NetworkImage(
                                        widget.snap['profImage'].toString(),
                                      ),
                                      backgroundColor: Colors
                                          .transparent, // Define o fundo como transparente
                                    ),
                                  ),
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                        left: 8,
                                      ),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          InkWell(
                                            onTap: () {
                                              Navigator.of(context).push(
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      StoreScreen(
                                                    storeId: widget.snap['uid'],
                                                  ),
                                                ),
                                              );
                                            },
                                            child: Text(
                                              widget.snap['username'],
                                              style: AppTheme.subtitlewhite
                                                  .copyWith(
                                                shadows: [
                                                  Shadow(
                                                    blurRadius: 3.0,
                                                    color: Colors
                                                        .black, // Cor da sombra
                                                    offset: Offset(2.0,
                                                        2.0), // Deslocamento X e Y da sombra
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Spacer(),
                                  Text(
                                    '\$${widget.snap['variations'][0]['price'].toString()}',
                                    style: AppTheme.subtitlewhite.copyWith(
                                      shadows: [
                                        Shadow(
                                          blurRadius: 3.0,
                                          color: Colors.black, // Cor da sombra
                                          offset: Offset(2.0,
                                              2.0), // Deslocamento X e Y da sombra
                                        ),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                              // Align(
                              //   alignment: Alignment.topLeft,
                              //   child: Text(
                              //     widget.snap['description'].toString(),
                              //     style: AppTheme.subtitlewhite.copyWith(
                              //       shadows: [
                              //         Shadow(
                              //           blurRadius: 3.0,
                              //           color: Colors.black, // Cor da sombra
                              //           offset: Offset(2.0,
                              //               2.0), // Deslocamento X e Y da sombra
                              //         ),
                              //       ],
                              //     ),
                              //   ),
                              // )
                            ])))
                  ],
                ),
              ),
            ));
      },
    );
  }
}
