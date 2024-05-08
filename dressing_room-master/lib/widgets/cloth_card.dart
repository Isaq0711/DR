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
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

class ClothCard extends StatefulWidget {
  final snap;

  const ClothCard({
    Key? key,
    required this.snap,
  }) : super(key: key);

  @override
  State<ClothCard> createState() => _ClothCardState();
}

class _ClothCardState extends State<ClothCard> {
  int commentLen = 0;
  bool isOnMyWardrobe = false;
  bool showinfo = true;
  bool isLoading = false;
  bool showreactions = false;
  bool isFavorite = false;
  String? username;
  String? profilePhoto;
  double rating = 0;

  @override
  void initState() {
    super.initState();
    getData();
    isOnWardrobe(widget.snap['clothId']);
    fetchCommentLen();
  }

  getData() async {
    setState(() {
      isLoading = true;
    });
    try {
      var userSnap = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.snap['uid'])
          .get();

      setState(() {
        username = userSnap['username'];
        profilePhoto = userSnap['photoUrl'];
      });
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

  Future<bool> isOnWardrobe(String clothId) async {
    try {
      DocumentSnapshot clothDocument = await FirebaseFirestore.instance
          .collection('wardrobe')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection('clothes')
          .doc(clothId)
          .get();

      if (clothDocument.exists) {
        isOnMyWardrobe = true;
        return true; // O item de vestuário está na coleção 'wardrobe'
      } else {
        isOnMyWardrobe = false;
        return false; // O item de vestuário não está na coleção 'wardrobe'
      }
    } catch (e) {
      // Lidar com erros, como exibir uma mensagem de erro
      showSnackBar(
        context,
        e.toString(),
      );
      return false; // Retorna falso em caso de erro
    }
  }

  fetchCommentLen() async {
    try {
      QuerySnapshot snap = await FirebaseFirestore.instance
          .collection('clothes')
          .doc(widget.snap['clothId'])
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
                                child: CommentsScreen(
                                    postId: widget.snap['clothId'],
                                    category: 'clothes')))
                      ]))
                    ])));
      },
    );
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

  Future<void> handleWardrobeAction(String uid) async {
    setState(() {});

    try {
      await FireStoreMethods()
          .addToWardrobe(widget.snap['clothId'], uid, widget.snap['uid']);
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
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10.0),
                                  child: Image.network(
                                    widget.snap['photoUrl'],
                                    fit: BoxFit.cover,
                                  ),
                                )))),
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
                                  child: isOnMyWardrobe
                                      ? ImageIcon(
                                          AssetImage(
                                            'assets/CLOSET-FILL.png',
                                          ),
                                          color: Colors.black.withOpacity(0.6),
                                        )
                                      : ImageIcon(
                                          AssetImage(
                                            'assets/CLOSET.png',
                                          ),
                                          color: Colors.black.withOpacity(0.6),
                                        ),
                                  backgroundColor: AppTheme.cinza,
                                  onTap: () {
                                    setState(() {
                                      isOnMyWardrobe = !isOnMyWardrobe;
                                      Future.delayed(
                                          Duration(milliseconds: 500), () {
                                        isOnMyWardrobe
                                            ? showSnackBar(
                                                context, 'Added to Wardrobe')
                                            : showSnackBar(context,
                                                'Removed from Wardrobe');
                                      });
                                    });
                                    Future.microtask(() {
                                      handleWardrobeAction(FirebaseAuth
                                          .instance.currentUser!.uid);
                                    });
                                  },
                                ),
                                SpeedDialChild(
                                  child: Icon(
                                    Icons.info_outline,
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
                                                horizontal: 10, vertical: 5),
                                            child: Column(children: [
                                              Row(
                                                children: <Widget>[
                                                  CircleAvatar(
                                                    radius: 16,
                                                    backgroundImage:
                                                        NetworkImage(
                                                      profilePhoto.toString(),
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
                                                            },
                                                            child: Text(
                                                                username
                                                                    .toString(),
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
                                              Gap(4),
                                              Text(
                                                  "Categoria: " +
                                                      widget.snap['category'],
                                                  style: AppTheme.dividerfont),
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
                                                  onPressed: () {
                                                    _showComments(context);
                                                  },
                                                ),
                                              ]),
                                              Text(
                                                DateFormat.yMMMd().format(widget
                                                    .snap['dateAdded']
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
