import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:gap/gap.dart';
import 'package:flutter/material.dart';
import 'package:dressing_room/models/user.dart' as model;
import 'package:dressing_room/providers/user_provider.dart';
import 'package:dressing_room/resources/firestore_methods.dart';
import 'package:dressing_room/screens/comments_screen.dart';
import 'package:dressing_room/screens/profile_screen.dart';
import 'package:dressing_room/utils/colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:dressing_room/utils/global_variable.dart';
import 'package:dressing_room/utils/utils.dart';
import 'package:dressing_room/widgets/like_animation.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:gap/gap.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:typed_data';
import 'dart:io';
import 'package:dressing_room/resources/storage_methods.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

class PostCard extends StatefulWidget {
  final snap;

  const PostCard({
    Key? key,
    required this.snap,
  }) : super(key: key);

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  int commentLen = 0;
  bool isLikeAnimating = false;
  bool showinfo = true;
  int currentImageIndex = 0;
  bool isAddedOnFav = false;
  bool isFavorite = false;
  double rating = 0;

  @override
  void initState() {
    super.initState();
    fetchCommentLen();
    getInitialRating();
    isOnFav(
      widget.snap['postId'],
    );
  }

  void _showComments(context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(10.0)),
      ),
      builder: (BuildContext bc) {
        return SizedBox(
          height: 450.h,
          child: CommentsScreen(postId: widget.snap['postId']),
        );
      },
    );
  }

  Future<void> handleFavAction(String uid) async {
    setState(() {});

    try {
      await FireStoreMethods().toggleFavorite(widget.snap['postId'], uid);
    } catch (err) {
      showSnackBar(context, err.toString());
    }

    setState(() {});
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
        isAddedOnFav = true;
        return true;
      } else {
        isAddedOnFav = false;
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

  getInitialRating() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    model.User? user = userProvider.getUser;
    if (user != null) {
      String uid = user.uid;
      String postId = widget.snap['postId'].toString();
      // Obtenha a nota diretamente do Firebase
      double initialRating = await FireStoreMethods().getUserGrade(
        postId,
        uid,
      );
      setState(() {
        rating = initialRating;
      });
    }
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

  deleteAnonymousPost(String postId) async {
    try {
      await FireStoreMethods().deleteAnonymousPost(postId);
    } catch (err) {
      showSnackBar(
        context,
        err.toString(),
      );
    }
  }

  double getLikePercentage() {
    int totalReactions =
        widget.snap['likes'].length + widget.snap['dislikes'].length;
    if (totalReactions == 0) {
      return 0.0;
    }
    double likePercentage =
        (widget.snap['likes'].length / totalReactions) * 100;
    return likePercentage;
  }

  void goToNextImage() {
    setState(() {
      currentImageIndex++;
      if (currentImageIndex >= widget.snap['photoUrls'].length) {
        currentImageIndex = 0;
      }
    });
  }

  void goToPreviousImage() {
    setState(() {
      currentImageIndex--;
      if (currentImageIndex < 0) {
        currentImageIndex = widget.snap['photoUrls'].length - 1;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, _) {
        model.User? user = userProvider.getUser;

        if (user == null) {
          return Container();
        }

        return Container(
          child: Column(
            children: [
              GestureDetector(
                onTap: () {
                  setState(() {
                    showinfo = !showinfo;
                  });
                },
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                        height: 670.h,
                        child: AspectRatio(
                          aspectRatio: 9 / 16,
                          child: InteractiveViewer(
                            panEnabled: true,
                            minScale: 0.1,
                            maxScale: 4,
                            child: PageView.builder(
                              itemCount: widget.snap['photoUrls'].length,
                              controller: PageController(
                                  initialPage: currentImageIndex),
                              onPageChanged: (index) {
                                setState(() {
                                  currentImageIndex = index;
                                });
                              },
                              itemBuilder: (context, index) {
                                return ClipRRect(
                                  borderRadius: BorderRadius.circular(10.0),
                                  child: Image.network(
                                    widget.snap['photoUrls'][index],
                                    fit: BoxFit.cover,
                                  ),
                                );
                              },
                            ),
                          ),
                        )),
                    Positioned(
                      top: 5,
                      right: 10,
                      child: Column(
                        children: [
                          Visibility(
                            visible: showinfo,
                            child: SpeedDial(
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
                                      Future.delayed(
                                          Duration(milliseconds: 500), () {
                                        isAddedOnFav
                                            ? showSnackBar(
                                                context, 'Added to Favorites')
                                            : showSnackBar(context,
                                                'Removed from Favorites');
                                      });
                                    });
                                    Future.microtask(() {
                                      handleFavAction(FirebaseAuth
                                          .instance.currentUser!.uid);
                                    });
                                  },
                                ),
                                SpeedDialChild(
                                  child: Icon(
                                    CupertinoIcons.arrow_up,
                                    color: Colors.black.withOpacity(0.6),
                                  ),
                                  backgroundColor: AppTheme.cinza,
                                  labelStyle: TextStyle(fontSize: 18.0),
                                  onTap: () => print('THIRD CHILD'),
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
                          )
                        ],
                      ),
                    ),
                    // Positioned(
                    //   top: 5,
                    //   left: 10,
                    //   child: Row(
                    //     children: [
                    //       Align(
                    //         alignment: Alignment.centerLeft,
                    //         child: Padding(
                    //           padding: const EdgeInsets.only(left: 4),
                    //           child: Container(
                    //             child: Text(
                    //               "Average: ${widget.snap['grade']}",
                    //               style: AppTheme.subtitlewhite.copyWith(
                    //                 shadows: [
                    //                   Shadow(
                    //                     blurRadius: 3.0,
                    //                     color: Colors.black, // Cor da sombra
                    //                     offset: Offset(1.0,
                    //                         1.0), // Deslocamento X e Y da sombra
                    //                   ),
                    //                 ],
                    //               ),
                    //             ),
                    //           ),
                    //         ),
                    //       ),
                    //       Gap(2),
                    //       Icon(
                    //         size: 13,
                    //         Icons.star,
                    //         color: AppTheme.vinho,
                    //         shadows: [
                    //           Shadow(
                    //             color: Colors.black.withOpacity(0.3),
                    //             offset: Offset(0, 2),
                    //             blurRadius: 4,
                    //           )
                    //         ],
                    //       ),
                    //     ],
                    //   ),
                    // ),
                    Positioned(
                        bottom: 0,
                        left: 0,
                        child: Visibility(
                            visible: showinfo,
                            child: SizedBox(
                                width: MediaQuery.of(context).size.width,
                                child: Container(
                                    color: AppTheme.cinza,
                                    width: double.infinity,
                                    child: Column(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 4.5),
                                          child: widget.snap['photoUrls']
                                                      .length >
                                                  1
                                              ? DotsIndicator(
                                                  dotsCount: widget
                                                      .snap['photoUrls'].length,
                                                  position:
                                                      currentImageIndex.toInt(),
                                                  decorator: DotsDecorator(
                                                    color: Colors.grey,
                                                    activeColor: AppTheme.vinho,
                                                    spacing: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 4.0),
                                                    size:
                                                        const Size.square(8.0),
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
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 10, vertical: 5),
                                            child: Column(children: [
                                              Row(
                                                children: <Widget>[
                                                  CircleAvatar(
                                                    radius: 16,
                                                    backgroundImage:
                                                        NetworkImage(
                                                      widget.snap['profImage']
                                                          .toString(),
                                                    ),
                                                    backgroundColor: Colors
                                                        .transparent, // Define o fundo como transparente
                                                  ),
                                                  Expanded(
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                        left: 8,
                                                      ),
                                                      child: Column(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: <Widget>[
                                                          InkWell(
                                                            onTap: () {
                                                              if (widget.snap[
                                                                      'username'] !=
                                                                  "Anonymous User") {
                                                                Navigator.of(
                                                                        context)
                                                                    .push(
                                                                  MaterialPageRoute(
                                                                    builder:
                                                                        (context) =>
                                                                            ProfileScreen(
                                                                      uid: widget
                                                                              .snap[
                                                                          'uid'],
                                                                    ),
                                                                  ),
                                                                );
                                                              }
                                                            },
                                                            child: Text(
                                                                widget.snap[
                                                                    'username'],
                                                                style: AppTheme
                                                                    .subtitle),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Gap(10),
                                              Align(
                                                  alignment: Alignment.topLeft,
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 4),
                                                    child: Text(
                                                        widget
                                                            .snap['description']
                                                            .toString(),
                                                        style:
                                                            AppTheme.subtitle),
                                                  ))
                                            ])),
                                        DefaultTextStyle(
                                          style: TextStyle(
                                              color: AppTheme.nearlyBlack,
                                              fontFamily: 'Quicksand',
                                              fontWeight: FontWeight.bold),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: <Widget>[
                                              RatingBar.builder(
                                                initialRating: rating,
                                                minRating: 0,
                                                direction: Axis.horizontal,
                                                allowHalfRating: true,
                                                itemCount: 5,
                                                itemPadding:
                                                    EdgeInsets.symmetric(
                                                        horizontal: 2.0),
                                                itemBuilder: (context, _) =>
                                                    Icon(
                                                  Icons.star,
                                                  color: AppTheme.vinho,
                                                ),
                                                itemSize: 30.0,
                                                unratedColor: Colors.grey,
                                                onRatingUpdate: (rating) async {
                                                  String uid = user.uid;
                                                  String postId = widget
                                                      .snap['postId']
                                                      .toString();
                                                  await FireStoreMethods()
                                                      .getUserGrade(
                                                          postId, uid, rating);
                                                  setState(() {});
                                                },
                                              ),
                                              Stack(children: [
                                                if (commentLen > 0)
                                                  Positioned(
                                                    right: 3,
                                                    top: 2,
                                                    child: Container(
                                                      padding:
                                                          EdgeInsets.all(2),
                                                      decoration: BoxDecoration(
                                                        color: AppTheme.vinho,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(7),
                                                      ),
                                                      constraints:
                                                          BoxConstraints(
                                                        minWidth: 17,
                                                        minHeight: 17,
                                                      ),
                                                      child: Text(
                                                        '$commentLen',
                                                        style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 10,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                        textAlign:
                                                            TextAlign.center,
                                                      ),
                                                    ),
                                                  ),
                                                IconButton(
                                                  icon: Icon(
                                                    Icons.comment_rounded,
                                                    color: AppTheme.nearlyBlack,
                                                  ),
                                                  // onPressed: () =>
                                                  //     Navigator.of(context)
                                                  //         .push(
                                                  //   MaterialPageRoute(
                                                  //     builder: (context) =>
                                                  //         CommentsScreen(
                                                  //       postId: widget
                                                  //           .snap['postId']
                                                  //           .toString(),
                                                  //     ),
                                                  //   ),
                                                  onPressed: () {
                                                    _showComments(context);
                                                  },
                                                ),
                                              ]),
                                              Text(
                                                DateFormat.yMMMd().format(widget
                                                    .snap['datePublished']
                                                    .toDate()),
                                                style: AppTheme.caption,
                                              ),
                                              Gap(2),
                                            ],
                                          ),
                                        ),
                                      ],
                                      mainAxisAlignment: MainAxisAlignment.end,
                                    ))))),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
