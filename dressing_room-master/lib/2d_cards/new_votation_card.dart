import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:gap/gap.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/material.dart';
import 'package:dressing_room/models/user.dart' as model;
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:dressing_room/providers/user_provider.dart';
import 'package:dressing_room/resources/firestore_methods.dart';
import 'package:dressing_room/screens/seepost.dart';
import 'package:dressing_room/screens/profile_screen.dart';
import 'package:dressing_room/utils/colors.dart';
import 'package:dressing_room/utils/utils.dart';
import 'package:dressing_room/widgets/like_animation.dart';
import 'package:provider/provider.dart';

class NewVotationCard extends StatefulWidget {
  final snap;

  const NewVotationCard({
    Key? key,
    required this.snap,
  }) : super(key: key);

  @override
  State<NewVotationCard> createState() => _NewVotationCardState();
}

class _NewVotationCardState extends State<NewVotationCard> {
  int commentLen = 0;
  bool isLikeAnimating = false;
  bool showPecas = false;
  bool existemPecas = false;
  Map<String, dynamic>? snapDialog;
  bool isAddedOnFav = false;
  int currentImageIndex = 0;
  List<String> descriptions = [];
  @override
  void initState() {
    super.initState();
    fetchCommentLen();
    snapDialog = widget.snap;
    extractDescriptions();
    isOnFav(widget.snap['votationId']);
    checkExistemPecas();
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

  Future<void> handleFavAction(String uid) async {
    setState(() {});

    try {
      await FireStoreMethods().toggleFavorite(widget.snap['votationId'], uid);
    } catch (err) {
      showSnackBar(context, err.toString());
    }

    setState(() {});
  }

  double calculatePercentage(int optionVotes, int totalVotes) {
    if (totalVotes == 0) {
      return 0.0;
    }
    return (optionVotes / totalVotes) * 100;
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

  deleteVotation(String votationId) async {
    try {
      await FireStoreMethods().deleteVotation(votationId);
    } catch (err) {
      showSnackBar(
        context,
        err.toString(),
      );
    }
  }

  void goToNextImage() {
    setState(() {
      currentImageIndex++;
      if (currentImageIndex >= widget.snap['options'].length) {
        currentImageIndex = 0;
      }
    });
  }

  void goToPreviousImage() {
    setState(() {
      currentImageIndex--;
      if (currentImageIndex < 0) {
        currentImageIndex = widget.snap['options'].length - 1;
      }
    });
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
                          isSuggestioncliked: false,
                          postId: widget.snap['votationId'],
                          isTagclicked: false),
                    ),
                  );
                },
                onDoubleTap: () {
                  showDialog(
                      context: context,
                      builder: (BuildContext context) {
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
                                            height: 500.h,
                                            width: double.infinity,
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(10.0),
                                              child: PageView.builder(
                                                itemCount:
                                                    snapDialog?['options']
                                                            ?.length ??
                                                        0,
                                                controller: PageController(
                                                    initialPage:
                                                        currentImageIndex),
                                                onPageChanged: (index) {
                                                  setState(() {
                                                    currentImageIndex = index;
                                                  });
                                                },
                                                itemBuilder: (context, index) {
                                                  return ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            25.0),
                                                    child: Image.network(
                                                      snapDialog?['options']
                                                                  [index]
                                                              ['photoUrl'] ??
                                                          '',
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
                                            child: DotsIndicator(
                                              dotsCount: snapDialog?['options']
                                                      ?.length ??
                                                  0,
                                              position: currentImageIndex,
                                              decorator: DotsDecorator(
                                                color: AppTheme.cinza,
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
                                            ),
                                          ),
                                          Text("Vote:",
                                              style: AppTheme.subheadline),
                                          Gap(5.sp),
                                          Align(
                                            alignment: Alignment.centerLeft,
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 4),
                                              child: ListView.builder(
                                                shrinkWrap: true,
                                                itemCount: descriptions.length,
                                                itemBuilder: (context, index) {
                                                  bool isVoted =
                                                      snapDialog?['votes']
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

                                                  int optionVotes = snapDialog?[
                                                              'votes']
                                                          ?.where((vote) {
                                                        return vote[
                                                                'optionDescription'] ==
                                                            descriptions[index];
                                                      })?.length ??
                                                      0;

                                                  int totalVotes =
                                                      snapDialog?['votes']
                                                              ?.length ??
                                                          0;

                                                  double percentage =
                                                      calculatePercentage(
                                                          optionVotes,
                                                          totalVotes);

                                                  return InkWell(
                                                    onTap: () async {
                                                      String votationId = widget
                                                          .snap['votationId']
                                                          .toString();
                                                      String uid = user.uid;
                                                      int optionIndex = index;

                                                      // Realiza o voto
                                                      await FireStoreMethods()
                                                          .votePost(votationId,
                                                              uid, optionIndex);

                                                      // Pega os votos atualizados do Firestore
                                                      var updatedSnap =
                                                          await FirebaseFirestore
                                                              .instance
                                                              .collection(
                                                                  'votations')
                                                              .doc(votationId)
                                                              .get();

                                                      setState(() {
                                                        // Atualiza os dados do snapData com os votos atualizados
                                                        snapDialog = updatedSnap
                                                                .data() ??
                                                            {};
                                                      });
                                                    },
                                                    child: SizedBox(
                                                      width: 50,
                                                      height: 35,
                                                      child: Card(
                                                        shape:
                                                            RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(15),
                                                        ),
                                                        elevation: 5,
                                                        margin: const EdgeInsets
                                                            .fromLTRB(
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
                                                                    size: 15)
                                                                : SizedBox
                                                                    .shrink(),
                                                            Gap(2),
                                                            Text(
                                                              hasVoted(
                                                                      snapDialog?[
                                                                          'votes'],
                                                                      user.uid)
                                                                  ? '${percentage.toStringAsFixed(0)}% voted for ${descriptions[index]}'
                                                                  : descriptions[
                                                                      index],
                                                              style: AppTheme
                                                                  .dividerfont
                                                                  .copyWith(
                                                                color: AppTheme
                                                                    .nearlyWhite,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  );
                                                },
                                              ),
                                            ),
                                          ),
                                          Gap(10),
                                        ],
                                      ),
                                    ],
                                  ));
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
                            child: Image.network(
                              widget.snap['options'][0]['photoUrl'],
                              fit: BoxFit.cover,
                            ),
                          ),
                        )),
                    Positioned(
                      top: 10,
                      left: 10,
                      child: Container(
                        padding:
                            EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Opção ${currentImageIndex + 1} de ${widget.snap['options'].length}',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 5,
                      right: 10,
                      child: Column(
                        children: [
                          Gap(5.h),
                          SizedBox(
                            width: 29.0,
                            height: 32.0,
                            child: FloatingActionButton(
                              onPressed: () {
                                setState(() {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => SeePost(
                                          isSuggestioncliked: true,
                                          postId: widget.snap['votationId'],
                                          isTagclicked: false),
                                    ),
                                  );
                                });
                              },
                              backgroundColor: AppTheme.cinza,
                              elevation: 8.0,
                              shape:
                                  CircleBorder(), // Makes the button more circular
                              child: ImageIcon(
                                AssetImage(
                                  'assets/ELECTION.png',
                                ),
                                size: 19,
                                color: AppTheme.nearlyBlack,
                              ),
                            ),
                          ),
                          Gap(5.h),
                          SizedBox(
                            width: 35.0,
                            height: 38.0,
                            child: FloatingActionButton(
                              onPressed: () {},
                              backgroundColor: AppTheme.cinza,
                              elevation: 8.0,
                              shape:
                                  CircleBorder(), // Makes the button more circular
                              child: ImageIcon(
                                AssetImage(
                                  'assets/SUGGESTION-OUTLINED.png',
                                ),
                                color: AppTheme.nearlyBlack,
                                size: 22,
                              ),
                            ),
                          ),
                          Gap(5.h),
                          Visibility(
                              visible: existemPecas,
                              child: SizedBox(
                                width: 35.0,
                                height: 38.0,
                                child: FloatingActionButton(
                                  onPressed: () {
                                    setState(() {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => SeePost(
                                              isSuggestioncliked: false,
                                              postId: widget.snap['votationId'],
                                              isTagclicked: true),
                                        ),
                                      );
                                    });
                                  },
                                  backgroundColor: AppTheme.cinza,
                                  elevation: 8.0,
                                  shape:
                                      CircleBorder(), // Makes the button more circular
                                  child: Icon(
                                    CupertinoIcons.tag,
                                    size: 22,
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
                          )
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
                                                      isMainn: false,
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
                            ])))
                  ],
                ),
              ),
            ));
      },
    );
  }
}
