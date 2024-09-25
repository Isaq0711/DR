import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:dressing_room/models/user.dart' as model;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:dressing_room/providers/user_provider.dart';
import 'package:dressing_room/widgets/suggestion_card.dart';
import 'package:dressing_room/resources/firestore_methods.dart';
import 'package:gap/gap.dart';
import 'package:flutter/cupertino.dart';
import 'package:dressing_room/screens/seepost.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:dressing_room/screens/comments_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:dressing_room/screens/profile_screen.dart';
import 'package:dressing_room/utils/colors.dart';
import 'package:dressing_room/utils/utils.dart';
import 'package:dressing_room/widgets/like_animation.dart';
import 'package:intl/intl.dart';
import 'package:dressing_room/providers/bottton_nav_controller.dart';
import 'package:provider/provider.dart';
import 'package:dots_indicator/dots_indicator.dart';

class VotationCard extends StatefulWidget {
  final snap;
  final bool isSuggestioncliked;

  VotationCard({
    Key? key,
    required this.snap,
    required this.isSuggestioncliked,
  }) : super(key: key);

  @override
  State<VotationCard> createState() => _VotationCardState();
}

class _VotationCardState extends State<VotationCard> {
  int commentLen = 0;
  late TransformationController _transformationController;
  final events = [];
  bool canScroll = true;
  bool isLikeAnimating = false;
  bool showPecas = false;
  bool isAddedOnFav = false;
  bool existemPecas = true;
  int currentImageIndex = 0;
  bool showinfo = true;
  List<String> descriptions = [];

  @override
  void initState() {
    super.initState();
    fetchCommentLen();
    _transformationController = TransformationController();
    isOnFav(
      widget.snap['votationId'],
    );
    extractDescriptions();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.isSuggestioncliked) {
        _showSuggestionMenu(context);
      }
    });
    checkExistemPecas();
  }

  fetchCommentLen() async {
    try {
      QuerySnapshot snap = await FirebaseFirestore.instance
          .collection('votation')
          .doc(widget.snap['votationId'])
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

  double calculatePercentage(int optionVotes, int totalVotes) {
    if (totalVotes == 0) {
      return 0.0;
    }
    return (optionVotes / totalVotes) * 100;
  }

  void showDeleteItemDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppTheme.nearlyWhite,
          title: Align(
            alignment: Alignment.center,
            child: Text(
              'Você deseja remover essa postagem?',
              style: AppTheme.subheadline,
            ),
          ),
          content: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ElevatedButton(
                child: Text(
                  'Não',
                  style: TextStyle(
                    fontFamily: 'Quicksand',
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(primary: AppTheme.vinho),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              Gap(10),
              ElevatedButton(
                child: Text(
                  'Sim',
                  style: TextStyle(
                    fontFamily: 'Quicksand',
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(primary: AppTheme.vinho),
                onPressed: () async {
                  deleteVotation(widget.snap['votationId']);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  deleteVotation(String votationId) async {
    try {
      await FireStoreMethods().deleteVotation(votationId);
    } catch (err) {}
  }

  Future<void> handleFavAction(String uid) async {
    setState(() {});

    try {
      await FireStoreMethods().toggleFavorite(widget.snap['votationId'], uid);
    } catch (err) {
      showSnackBar(context, err.toString());
    }

    setState(() {});
  }

  Future<void> checkExistemPecas() async {
    try {
      List<dynamic>? options = widget.snap['options'];

      if (options != null &&
          options.isNotEmpty &&
          currentImageIndex < options.length) {
        List<dynamic>? pecasIds = options[currentImageIndex]['pecasID'];
        if (pecasIds != null && pecasIds.isNotEmpty) {
          setState(() {
            existemPecas = true;
          });
        } else {
          existemPecas = false;
        }
      }
    } catch (e) {
      print('Erro ao verificar a existência de peças: $e');
      setState(() {
        existemPecas = false;
      });
    }
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

  void _showSuggestionMenu(BuildContext context) async {
    await showModalBottomSheet(
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
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            child: SizedBox(
                              height: 600.h,
                              child: SuggestionCard(
                                postId: widget.snap['votationId'],
                                uid: widget.snap['uid'],
                                username: widget.snap['username'],
                                description: widget.snap['description'],
                                rating: null,
                                category: 'votations',
                              ),
                            ))
                      ]))
                    ])));
      },
    );

    fetchCommentLen();
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
                            child: Row(
                              children: [
                                Spacer(),
                                Gap(50.h),
                                Center(
                                  child: Text(
                                    'Comentários',
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

                                Spacer(), // Adiciona um espaço depois do texto
                                IconButton(
                                  onPressed: () {
                                    _showSuggestionMenu(context);
                                  },
                                  icon: ImageIcon(
                                    AssetImage(
                                      'assets/SUGGESTION-OUTLINED.png',
                                    ),
                                    color: AppTheme.nearlyBlack,
                                  ),
                                ),
                              ],
                            )),
                        Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            child: SizedBox(
                                height: 550.h,
                                child: CommentsScreen(
                                    postId: widget.snap['votationId'],
                                    description: widget.snap['question'],
                                    userquepostou: widget.snap['uid'],
                                    rating: null,
                                    category: 'votation')))
                      ]))
                    ])));
      },
    );
  }

  void extractDescriptions() {
    List<dynamic> options = widget.snap['options'];
    descriptions =
        options.map((option) => option['description'].toString()).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, _) {
        model.User? user = userProvider.getUser;
        final width = MediaQuery.of(context).size.width;
        if (user == null) {
          return Container();
        }

        return Column(
          children: [
            GestureDetector(
              onDoubleTap: () {
                String votationId = widget.snap['votationId'].toString();
                String uid = user.uid;
                int optionIndex = currentImageIndex;
                FireStoreMethods()
                    .votePost(votationId, uid, optionIndex)
                    .then((res) {
                  setState(() {
                    isLikeAnimating = res == 'success';
                    showinfo = true;
                  });
                });
              },
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    height: 690.h,
                    child: AspectRatio(
                        aspectRatio: 9 / 16,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10.0),
                          child: PageView.builder(
                            itemCount: widget.snap['options'].length,
                            controller:
                                PageController(initialPage: currentImageIndex),
                            physics: events.length >= 2
                                ? const NeverScrollableScrollPhysics()
                                : null,
                            onPageChanged: (index) {
                              setState(() {
                                currentImageIndex = index;
                                checkExistemPecas();
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

                                    context.read<ZoomProvider>().setZoom(false);
                                  },
                                  onPointerMove: (event) {
                                    if (events.length > 1) {
                                      setState(() {
                                        canScroll = false;
                                      });
                                      context
                                          .read<ZoomProvider>()
                                          .setZoom(true);
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
                                          child: GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                showinfo = !showinfo;
                                              });
                                            },
                                            child: Image.network(
                                              widget.snap['options'][index]
                                                  ['photoUrl'],
                                              fit: BoxFit.cover,
                                            ),
                                          ))));
                            },
                          ),
                        )),
                  ),
                  Positioned(
                    top: 5,
                    right: 10,
                    child: Visibility(
                      visible: showinfo,
                      child: Column(
                        children: [
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
                              )),
                          Gap(5.h),
                          SizedBox(
                            width: 35.0,
                            height: 38.0,
                            child: FloatingActionButton(
                                onPressed: () {
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
                                backgroundColor: AppTheme.cinza,
                                elevation: 8.0,
                                shape:
                                    CircleBorder(), // Makes the button more circular
                                child: isAddedOnFav
                                    ? Icon(
                                        Icons.folder_copy_rounded,
                                        color: Colors.black.withOpacity(0.6),
                                        size: 22,
                                      )
                                    : Icon(
                                        Icons.folder_copy_outlined,
                                        color: Colors.black.withOpacity(0.6),
                                        size: 22,
                                      )),
                          ),
                          FirebaseAuth.instance.currentUser!.uid ==
                                  widget.snap['uid']
                              ? SizedBox(
                                  width: 35.0,
                                  height: 38.0,
                                  child: FloatingActionButton(
                                      onPressed: () {
                                        showDeleteItemDialog(context);
                                      },
                                      backgroundColor: AppTheme.cinza,
                                      elevation: 8.0,
                                      shape:
                                          CircleBorder(), // Makes the button more circular
                                      child: Icon(
                                        Icons.delete_outline,
                                        color: Colors.black.withOpacity(0.6),
                                        size: 22,
                                      )),
                                )
                              : SizedBox.shrink()
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                      bottom: 0,
                      left: 0,
                      child: Visibility(
                          visible: showinfo,
                          child: Column(
                            children: [
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
                                                .snap['options']
                                                    [currentImageIndex]
                                                    ['pecasPhotoUrls']!
                                                .length,
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
                                                        isTagclicked: false,
                                                        isSuggestioncliked:
                                                            false,
                                                        postId: widget.snap[
                                                                    'options'][
                                                                currentImageIndex]
                                                            ['pecasID']![index],
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
                                                      widget.snap['options'][
                                                              currentImageIndex]
                                                          [
                                                          'pecasPhotoUrls']![index],
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
                                child: GestureDetector(
                                    onHorizontalDragUpdate: canScroll
                                        ? (details) {
                                            if (details.primaryDelta! > 0) {
                                              Navigator.pop(context);
                                            }
                                          }
                                        : null,
                                    onVerticalDragStart: canScroll
                                        ? (details) {
                                            _showComments(context);
                                          }
                                        : null,
                                    child: Container(
                                        color: AppTheme.cinza,
                                        width: double.infinity,
                                        child: Column(
                                          children: [
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 4),
                                              child: widget.snap['options']
                                                          .length >
                                                      1
                                                  ? DotsIndicator(
                                                      dotsCount: widget
                                                          .snap['options']
                                                          .length,
                                                      position:
                                                          currentImageIndex
                                                              .toInt(),
                                                      decorator: DotsDecorator(
                                                        color: const Color
                                                            .fromARGB(
                                                            255, 112, 112, 112),
                                                        activeColor:
                                                            AppTheme.vinho,
                                                        spacing: EdgeInsets
                                                            .symmetric(
                                                                horizontal:
                                                                    4.0),
                                                        size: Size.square(8.0),
                                                        activeSize:
                                                            Size(16.0, 8.0),
                                                        activeShape:
                                                            RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      4.0),
                                                        ),
                                                      ),
                                                    )
                                                  : SizedBox.shrink(),
                                            ),
                                            Container(
                                              padding: EdgeInsets.symmetric(
                                                vertical: 5,
                                                horizontal: 10,
                                              ),
                                              child: Row(
                                                children: <Widget>[
                                                  CircleAvatar(
                                                    radius: 16,
                                                    backgroundImage:
                                                        NetworkImage(
                                                      widget.snap['profImage']
                                                          .toString(),
                                                    ),
                                                  ),
                                                  Expanded(
                                                    child: Padding(
                                                      padding: EdgeInsets.only(
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
                                                                    isMainn:
                                                                        false,
                                                                  ),
                                                                ),
                                                              );
                                                            },
                                                            child: Text(
                                                              "Enquete de ${widget.snap['username']}",
                                                              style: AppTheme
                                                                  .subtitle,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Align(
                                                alignment: Alignment.center,
                                                child: Text(
                                                  widget.snap['question'],
                                                  style: AppTheme.dividerfont
                                                      .copyWith(
                                                          color: AppTheme
                                                              .nearlyBlack),
                                                )),
                                            Padding(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 10),
                                              child: ListView.builder(
                                                shrinkWrap: true,
                                                itemCount: descriptions.length,
                                                itemBuilder: (context, index) {
                                                  bool isVoted = widget
                                                          .snap['votes']
                                                          ?.any((vote) {
                                                        return vote['uid'] ==
                                                                user.uid &&
                                                            vote['optionDescription'] ==
                                                                descriptions[
                                                                    index];
                                                      }) ??
                                                      false;

                                                  bool hasVoted(
                                                      List<dynamic>? votes,
                                                      String uid) {
                                                    return votes?.any((vote) =>
                                                            vote['uid'] ==
                                                            uid) ??
                                                        false;
                                                  }

                                                  int optionVotes = widget
                                                          .snap['votes']
                                                          ?.where((vote) =>
                                                              vote[
                                                                  'optionDescription'] ==
                                                              descriptions[
                                                                  index])
                                                          ?.length ??
                                                      0;

                                                  int totalVotes = widget
                                                          .snap['votes']
                                                          ?.length ??
                                                      0;

                                                  double percentage =
                                                      calculatePercentage(
                                                          optionVotes,
                                                          totalVotes);

                                                  return InkWell(
                                                    onTap: () {
                                                      String votationId = widget
                                                          .snap['votationId']
                                                          .toString();
                                                      String uid = user.uid;
                                                      int optionIndex = index;
                                                      FireStoreMethods()
                                                          .votePost(votationId,
                                                              uid, optionIndex)
                                                          .then((res) {
                                                        setState(() {
                                                          isLikeAnimating =
                                                              res == 'success';
                                                        });
                                                      });
                                                    },
                                                    child: SizedBox(
                                                      width: 50,
                                                      height: 40.h,
                                                      child: Card(
                                                        shape:
                                                            RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(10),
                                                        ),
                                                        elevation: 5,
                                                        margin:
                                                            EdgeInsets.fromLTRB(
                                                                15, 10, 15, 0),
                                                        color: isVoted
                                                            ? AppTheme
                                                                .nearlyBlack
                                                            : AppTheme.vinho,
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          children: [
                                                            isVoted
                                                                ? Icon(
                                                                    Icons
                                                                        .check_circle_outline,
                                                                    size: 15,
                                                                  )
                                                                : SizedBox
                                                                    .shrink(),
                                                            Gap(2),
                                                            Text(
                                                              hasVoted(
                                                                      widget.snap[
                                                                          'votes'],
                                                                      user.uid)
                                                                  ? '${percentage.toStringAsFixed(0)}% votaram em ${descriptions[index]}'
                                                                  : descriptions[
                                                                      index],
                                                              style: AppTheme
                                                                  .dividerfont
                                                                  .copyWith(
                                                                      color: AppTheme
                                                                          .nearlyWhite,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  );
                                                },
                                              ),
                                            ),
                                            DefaultTextStyle(
                                              style: TextStyle(
                                                  color: AppTheme.nearlyBlack,
                                                  fontFamily: 'Quicksand',
                                                  fontWeight: FontWeight.bold),
                                              child: Padding(
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 24),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    hasVoted(
                                                            widget
                                                                .snap['votes'],
                                                            FirebaseAuth
                                                                .instance
                                                                .currentUser!
                                                                .uid)
                                                        ? InkWell(
                                                            child: Text(
                                                              "Remover voto",
                                                              style: AppTheme
                                                                  .dividerfont,
                                                            ),
                                                            onTap: () {
                                                              String
                                                                  votationId =
                                                                  widget.snap[
                                                                          'votationId']
                                                                      .toString();
                                                              String uid =
                                                                  user.uid;
                                                              FireStoreMethods()
                                                                  .removeVote(
                                                                      votationId,
                                                                      uid);
                                                            },
                                                          )
                                                        : Gap(50.h),
                                                    Stack(children: [
                                                      if (commentLen > 0)
                                                        Positioned(
                                                          right: 3,
                                                          top: 2,
                                                          child: Container(
                                                            padding:
                                                                EdgeInsets.all(
                                                                    2),
                                                            decoration:
                                                                BoxDecoration(
                                                              color: AppTheme
                                                                  .vinho,
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          7),
                                                            ),
                                                            constraints:
                                                                BoxConstraints(
                                                              minWidth: 17,
                                                              minHeight: 17,
                                                            ),
                                                            child: Text(
                                                              '$commentLen',
                                                              style: TextStyle(
                                                                color: Colors
                                                                    .white,
                                                                fontSize: 10,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                            ),
                                                          ),
                                                        ),
                                                      IconButton(
                                                        icon: Icon(
                                                          Icons.comment_rounded,
                                                          color: AppTheme
                                                              .nearlyBlack,
                                                        ),
                                                        onPressed: () {
                                                          _showComments(
                                                              context);
                                                        },
                                                      ),
                                                    ]),
                                                    Text(
                                                      DateFormat.yMMMd().format(
                                                          widget.snap[
                                                                  'datePublished']
                                                              .toDate()),
                                                      style: AppTheme.caption,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ))),
                              )
                            ],
                          ))),
                  AnimatedOpacity(
                    duration: Duration(milliseconds: 200),
                    opacity: isLikeAnimating ? 1 : 0,
                    child: LikeAnimation(
                      isAnimating: isLikeAnimating,
                      child: Icon(
                        Icons.check_box,
                        color: Colors.green,
                        size: 100,
                      ),
                      duration: Duration(
                        milliseconds: 400,
                      ),
                      onEnd: () {
                        setState(() {
                          isLikeAnimating = false;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

bool hasVoted(List<dynamic>? votes, String uid) {
  return votes?.any((vote) => vote['uid'] == uid) ?? false;
}
