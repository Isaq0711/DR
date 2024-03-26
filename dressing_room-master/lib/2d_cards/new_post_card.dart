import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/cupertino.dart';
import 'package:gap/gap.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:typed_data';
import 'package:dots_indicator/dots_indicator.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:dressing_room/resources/storage_methods.dart';
import 'package:flutter/material.dart';
import 'package:dressing_room/models/user.dart' as model;
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:dressing_room/providers/user_provider.dart';
import 'package:dressing_room/resources/firestore_methods.dart';
import 'package:dressing_room/screens/seepost.dart';
import 'package:dressing_room/screens/profile_screen.dart';
import 'package:dressing_room/utils/colors.dart';
import 'package:dressing_room/utils/utils.dart';
import 'package:provider/provider.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class NewPostCard extends StatefulWidget {
  final snap;

  const NewPostCard({
    Key? key,
    required this.snap,
  }) : super(key: key);

  @override
  State<NewPostCard> createState() => _NewPostCardState();
}

class _NewPostCardState extends State<NewPostCard> {
  int commentLen = 0;
  bool isLikeAnimating = false;
  bool isAddedOnFav = false;
  bool showreactions = false;
  int currentImageIndex = 0;
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

  Future<void> handleFavAction(String uid) async {
    setState(() {});

    try {
      await FireStoreMethods().toggleFavorite(widget.snap['postId'], uid);
    } catch (err) {
      showSnackBar(context, err.toString());
    }

    setState(() {});
  }

  Future<Uint8List?> downloadFile(String url) async {
    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        Uint8List bytes = response.bodyBytes;
        return bytes;
      } else {
        throw Exception("Falha ao baixar o arquivo");
      }
    } catch (e) {
      throw Exception("Erro durante o download: $e");
    }
  }

  Future<File> saveBytesToFile(Uint8List bytes) async {
    Directory tempDir = await getTemporaryDirectory();
    File tempFile = File('${tempDir.path}/temp_image.png');
    await tempFile.writeAsBytes(bytes);
    return tempFile;
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
                      builder: (context) =>
                          SeePost(postId: widget.snap['postId']),
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
                                  child: ListView(
                                    children: [
                                      Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          SizedBox(
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                0.7,
                                            width: double.infinity,
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(10.0),
                                              child: PageView.builder(
                                                itemCount: widget
                                                    .snap['photoUrls'].length,
                                                controller: PageController(
                                                    initialPage:
                                                        currentImageIndex),
                                                onPageChanged: (index) {
                                                  setState(() {
                                                    position = index;
                                                  });
                                                },
                                                itemBuilder: (context, index) {
                                                  return ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            25.0),
                                                    child: Image.network(
                                                      widget.snap['photoUrls']
                                                          [index],
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
                                            child: widget.snap['photoUrls']
                                                        .length >
                                                    1
                                                ? DotsIndicator(
                                                    dotsCount: widget
                                                        .snap['photoUrls']
                                                        .length,
                                                    position: position,
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
                                          Text("Rate this post:",
                                              style: AppTheme.subheadline),
                                          Gap(5.sp),
                                          RatingBar.builder(
                                            initialRating: rating,
                                            minRating: 0,
                                            direction: Axis.horizontal,
                                            allowHalfRating: true,
                                            itemCount: 5,
                                            itemPadding: EdgeInsets.symmetric(
                                                horizontal: 2.0),
                                            itemBuilder: (context, _) => Icon(
                                              shadows: <Shadow>[
                                                Shadow(
                                                    color: AppTheme.nearlyBlack,
                                                    blurRadius: 10.0)
                                              ],
                                              Icons.star,
                                              color: AppTheme.vinho,
                                            ),
                                            itemSize: 30.0,
                                            unratedColor: Colors.grey,
                                            onRatingUpdate: (rating) async {
                                              print("Rating: $rating");
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
                                        ],
                                      ),
                                    ],
                                  ));
                            },
                          ),
                        );
                      }).then((value) {
                    getInitialRating();
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
                                  widget.snap['photoUrls'][0],
                                  fit: BoxFit.cover,
                                ),
                              )),
                        )),
                    widget.snap['photoUrls'].length > 1
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
                                '${currentImageIndex + 1} / ${widget.snap['photoUrls'].length}',
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
                          Visibility(
                            visible:
                                widget.snap['username'] == "Anonymous User",
                            child: Icon(
                              shadows: <Shadow>[
                                Shadow(
                                  color: AppTheme.nearlyBlack,
                                  blurRadius: 5.0,
                                ),
                              ],
                              Icons.person,
                              color: AppTheme.vinho,
                            ),
                          ),
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
                                child: Icon(
                                  CupertinoIcons.arrow_up,
                                  color: Colors.black.withOpacity(0.6),
                                ),
                                backgroundColor: AppTheme.cinza,
                                labelStyle: TextStyle(fontSize: 18.0),
                                onTap: () async {
                                  if (widget.snap['photoUrls'] != null) {
                                    String imageUrl = widget.snap['photoUrls']
                                        [currentImageIndex];
                                    try {
                                      Uint8List? imageBytes =
                                          await downloadFile(imageUrl);
                                      if (imageBytes != null) {
                                        File tempFile =
                                            await saveBytesToFile(imageBytes);
                                        Uint8List? processedImage =
                                            await removeBg(tempFile.path);

                                        if (processedImage != null) {
                                          String processedImageUrl =
                                              await StorageMethods()
                                                  .uploadImageToStorage('posts',
                                                      processedImage, true);

                                          List<String> photoUrls = List.from(
                                              widget.snap['photoUrls']);

                                          photoUrls[currentImageIndex] =
                                              processedImageUrl;

                                          // Atualiza a lista no Firestore
                                          await FirebaseFirestore.instance
                                              .collection('posts')
                                              .doc(widget.snap['postId'])
                                              .update({
                                            'photoUrls': photoUrls,
                                          });

                                          await tempFile.delete();
                                        }
                                      }
                                    } catch (e) {
                                      showSnackBar(context,
                                          'Erro ao processar a imagem: $e');
                                    }
                                  } else {
                                    showSnackBar(
                                        context, 'Nenhuma imagem selecionada');
                                  }
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
                                              if (widget.snap['username'] !=
                                                  "Anonymous User") {
                                                Navigator.of(context).push(
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        ProfileScreen(
                                                      uid: widget.snap['uid'],
                                                    ),
                                                  ),
                                                );
                                              }
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
                                ],
                              ),
                              //DESCRIÇÃOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOO
                              // Align(
                              //   alignment: Alignment.topLeft,
                              //   child: Text(
                              //     widget.snap['description'].toString(),
                              //     style: AppTheme.subtitlewhite.copyWith(
                              //       shadows: [
                              //         Shadow(
                              //           blurRadius: 3.0,
                              //           color:
                              //               Colors.black, // Cor da sombra
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
