import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:gap/gap.dart';
import 'package:flutter/material.dart';
import 'package:dressing_room/models/user.dart' as model;
import 'package:dressing_room/providers/user_provider.dart';
import 'package:dressing_room/resources/firestore_methods.dart';
import 'package:dressing_room/screens/seepost.dart';
import 'package:dressing_room/screens/comments_screen.dart';
import 'package:dressing_room/screens/profile_screen.dart';
import 'package:dressing_room/utils/colors.dart';
import 'package:dressing_room/widgets/suggestion_card.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:dressing_room/utils/utils.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
  bool showPecas = false;
  final events = [];
  late TransformationController _transformationController;
  bool canScroll = true;
  bool existemPecas = false;
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
    _transformationController = TransformationController();
    isOnFav(
      widget.snap['postId'],
    );
    checkExistemPecas();
  }

  void _zoomToMin() {
    _transformationController.value = Matrix4.identity()..scale(1.0);
  }

  void _showComments(context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Container(
            height: 650.h,
            child: Container(
                decoration: BoxDecoration(
                  color: AppTheme.cinza,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(30),
                  ),
                ),
                width: double.infinity,
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                          child: Column(children: [
                        Container(
                          width: 40,
                          height: 6,
                          margin: const EdgeInsets.only(top: 16, bottom: 4),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(50),
                            color: AppTheme.nearlyWhite,
                          ),
                        ),
                        Gap(5),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          child: Text(
                            'Comments',
                            style: AppTheme.barapp.copyWith(
                              shadows: [
                                Shadow(
                                  blurRadius: 2.0,
                                  color: Colors.black,
                                ),
                              ],
                            ),
                          ),
                        ),
                        Gap(15),
                        Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            child: SizedBox(
                                height: 570.h,
                                child:
                                    widget.snap['username'] != "Anonymous User"
                                        ? CommentsScreen(
                                            postId: widget.snap['postId'],
                                            category: 'posts')
                                        : CommentsScreen(
                                            postId: widget.snap['postId'],
                                            category: 'anonymous_posts')))
                      ]))
                    ])));
      },
    );
  }

  Future<void> checkExistemPecas() async {
    try {
      List<dynamic>? pecasIds = widget.snap['pecasIds'];
      if (pecasIds != null && pecasIds.isNotEmpty) {
        setState(() {
          existemPecas = true;
        });
      } else {
        setState(() {
          existemPecas = false;
        });
      }
    } catch (e) {
      // Lidar com possíveis erros aqui, como exibir uma mensagem de erro ou registrar o erro
      print('Erro ao verificar a existência de peças: $e');
      setState(() {
        existemPecas = false;
      });
    }
  }

  void _showSuggestionMenu(BuildContext context) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Container(
          height: 650.h,
          child: SuggestionCard(
              postId: widget.snap['postId'],
              uid: widget.snap['uid'],
              category: 'posts'),
        );
      },
    );

    fetchCommentLen();
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
      QuerySnapshot snap2 = await FirebaseFirestore.instance
          .collection('posts')
          .doc(widget.snap['postId'])
          .collection('suggestion')
          .get();
      commentLen = snap.docs.length + snap2.docs.length;
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
                      height: 690.h,
                      child: AspectRatio(
                        aspectRatio: 9 / 16,
                        child: PageView.builder(
                          itemCount: widget.snap['photoUrls'].length,
                          controller:
                              PageController(initialPage: currentImageIndex),
                          physics: events.length >= 2
                              ? const NeverScrollableScrollPhysics()
                              : null,
                          onPageChanged: (index) {
                            setState(() {
                              currentImageIndex = index;
                            });
                          },
                          itemBuilder: (context, index) {
                            return Listener(
                                onPointerDown: (event) {
                                  events.add(event.pointer);
                                  print("event add");
                                },
                                onPointerUp: (event) {
                                  events.clear();
                                  print("events cleared");
                                  setState(() {
                                    canScroll = true;
                                    _zoomToMin();
                                  });
                                },
                                onPointerMove: (event) {
                                  if (events.length > 1) {
                                    setState(() {
                                      canScroll = false;
                                    });
                                  }
                                },
                                child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10.0),
                                    child: InteractiveViewer(
                                      transformationController:
                                          _transformationController,
                                      clipBehavior: Clip.none,
                                      minScale: 1,
                                      maxScale: 16,
                                      child: Image.network(
                                        widget.snap['photoUrls'][index],
                                        fit: BoxFit.cover,
                                      ),
                                    )));
                          },
                        ),
                      ),
                    ),
                    Positioned(
                      top: 5,
                      right: 10,
                      child: Visibility(
                        visible: showinfo,
                        child: Column(
                          children: [
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
                                    onTap: () {
                                      _showSuggestionMenu(context);
                                    }),
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
                            Gap(5),
                            Visibility(
                                visible: existemPecas,
                                child: SizedBox(
                                  width: 29.0,
                                  height: 32.0,
                                  child: FloatingActionButton(
                                    onPressed: () {
                                      setState(() {
                                        showPecas = !showPecas;
                                      });
                                    },
                                    backgroundColor: AppTheme.cinza,
                                    elevation: 8.0,
                                    shape:
                                        CircleBorder(), // Makes the button more circular
                                    child: Icon(
                                      CupertinoIcons.tag,
                                      size: 18,
                                      color: AppTheme.nearlyBlack,
                                    ),
                                  ),
                                ))
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                        bottom: 0,
                        left: 0,
                        child: Visibility(
                            visible: showinfo,
                            child: Column(children: [
                              existemPecas
                                  ? Visibility(
                                      visible: showPecas,
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 2,
                                          vertical: 5,
                                        ),
                                        child: Container(
                                          height: 76.h,
                                          width: 340.w,
                                          child: GridView.builder(
                                            scrollDirection: Axis.horizontal,
                                            itemCount: widget
                                                .snap['pecasPhotoUrls']!.length,
                                            gridDelegate:
                                                SliverGridDelegateWithFixedCrossAxisCount(
                                              crossAxisCount: 1,
                                              mainAxisSpacing: 4,
                                            ),
                                            itemBuilder: (context, index) {
                                              return GestureDetector(
                                                onTap: () {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          SeePost(
                                                        postId: widget.snap[
                                                            'pecasIds']![index],
                                                      ),
                                                    ),
                                                  );
                                                },
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10.0),
                                                    color: Colors.white24,
                                                  ),
                                                  child: ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10.0),
                                                    child: Image.network(
                                                      widget.snap[
                                                              'pecasPhotoUrls']![
                                                          index],
                                                      fit: BoxFit.fill,
                                                      height: 76
                                                          .h, // Garante a altura adequada para a imagem
                                                      width: 340.w,
                                                    ),
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      ),
                                    )
                                  : SizedBox.shrink(),
                              SizedBox(
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
                                                        .snap['photoUrls']
                                                        .length,
                                                    position: currentImageIndex
                                                        .toInt(),
                                                    decorator: DotsDecorator(
                                                      color: Colors.grey,
                                                      activeColor:
                                                          AppTheme.vinho,
                                                      spacing: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 4.0),
                                                      size: const Size.square(
                                                          8.0),
                                                      activeSize:
                                                          const Size(16.0, 8.0),
                                                      activeShape:
                                                          RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(4.0),
                                                      ),
                                                    ),
                                                  )
                                                : SizedBox.shrink(),
                                          ),
                                          Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 10,
                                                      vertical: 5),
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
                                                            const EdgeInsets
                                                                .only(
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
                                                                            .snap['uid'],
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
                                                    alignment:
                                                        Alignment.topLeft,
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              left: 4),
                                                      child: Text(
                                                          widget.snap[
                                                                  'description']
                                                              .toString(),
                                                          style: AppTheme
                                                              .subtitle),
                                                    ))
                                              ])),
                                          DefaultTextStyle(
                                            style: TextStyle(
                                                color: AppTheme.nearlyBlack,
                                                fontFamily: 'Quicksand',
                                                fontWeight: FontWeight.bold),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
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
                                                  onRatingUpdate:
                                                      (rating) async {
                                                    String uid = user.uid;
                                                    String postId = widget
                                                        .snap['postId']
                                                        .toString();
                                                    await FireStoreMethods()
                                                        .getUserGrade(postId,
                                                            uid, rating);
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
                                                        decoration:
                                                            BoxDecoration(
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
                                                      color:
                                                          AppTheme.nearlyBlack,
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
                                                  DateFormat.yMMMd().format(
                                                      widget
                                                          .snap['datePublished']
                                                          .toDate()),
                                                  style: AppTheme.caption,
                                                ),
                                                Gap(2),
                                              ],
                                            ),
                                          ),
                                        ],
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                      )))
                            ])))
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
