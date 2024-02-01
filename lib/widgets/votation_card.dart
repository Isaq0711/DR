import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:dressing_room/models/user.dart' as model;
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
import 'package:dots_indicator/dots_indicator.dart';

class VotationCard extends StatefulWidget {
  final snap;

  const VotationCard({
    Key? key,
    required this.snap,
  }) : super(key: key);

  @override
  State<VotationCard> createState() => _VotationCardState();
}

class _VotationCardState extends State<VotationCard> {
  int commentLen = 0;
  bool isLikeAnimating = false;
  int currentImageIndex = 0;
  List<String> descriptions = [];

  @override
  void initState() {
    super.initState();
    fetchCommentLen();
    extractDescriptions();
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

  double calculatePercentage(int optionVotes, int totalVotes) {
    if (totalVotes == 0) {
      return 0.0;
    }
    return (optionVotes / totalVotes) * 100;
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
    final model.User user = Provider.of<UserProvider>(context).getUser;
    final width = MediaQuery.of(context).size.width;

    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: width > webScreenSize ? Colors.grey : Colors.grey,
        ),
        borderRadius: BorderRadius.circular(10.0),
        color: AppTheme.nearlyWhite,
      ),
      child: Column(
        children: [
          GestureDetector(
            onDoubleTap: () {},
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.5,
                  width: double.infinity,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10.0),
                    child: PageView.builder(
                      itemCount: widget.snap['options'].length,
                      controller:
                          PageController(initialPage: currentImageIndex),
                      onPageChanged: (index) {
                        setState(() {
                          currentImageIndex = index;
                        });
                      },
                      itemBuilder: (context, index) {
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(10.0),
                          child: Image.network(
                            widget.snap['options'][index]['photoUrl'],
                            fit: BoxFit.cover,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                AnimatedOpacity(
                  duration: const Duration(milliseconds: 200),
                  opacity: isLikeAnimating ? 1 : 0,
                  child: LikeAnimation(
                    isAnimating: isLikeAnimating,
                    child: const Icon(
                      Icons.check_box,
                      color: Colors.green,
                      size: 100,
                    ),
                    duration: const Duration(
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
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.5),
            child: widget.snap['options'].length > 1
                ? DotsIndicator(
                    dotsCount: widget.snap['options'].length,
                    position: currentImageIndex.toInt(),
                    decorator: DotsDecorator(
                      color: AppTheme.cinza,
                      activeColor: AppTheme.vinho,
                      spacing: const EdgeInsets.symmetric(horizontal: 4.0),
                      size: const Size.square(8.0),
                      activeSize: const Size(16.0, 8.0),
                      activeShape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4.0),
                      ),
                    ),
                  )
                : SizedBox.shrink(),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              vertical: 2,
              horizontal: 6,
            ).copyWith(right: 0),
            child: Row(
              children: <Widget>[
                CircleAvatar(
                  radius: 16,
                  backgroundImage: NetworkImage(
                    widget.snap['profImage'].toString(),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(
                      left: 8,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        InkWell(
                          onTap: () {
                            if (widget.snap['username'] != "Anonymous User") {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => ProfileScreen(
                                    uid: widget.snap['uid'],
                                  ),
                                ),
                              );
                            }
                          },
                          child: Text(
                            "Votation by ${widget.snap['username']}",
                            style: AppTheme.subtitle,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                widget.snap['uid'].toString() == user.uid
                    ? IconButton(
                        color: AppTheme.nearlyBlack,
                        onPressed: () {
                          showDialog(
                            useRootNavigator: false,
                            context: context,
                            builder: (context) {
                              return Dialog(
                                child: ListView(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 2.5,
                                    horizontal: 2.5,
                                  ),
                                  shrinkWrap: true,
                                  children: [
                                    InkWell(
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 12,
                                          horizontal: 16,
                                        ),
                                        color: AppTheme.nearlyWhite,
                                        child: Text(
                                          'Delete',
                                          style: AppTheme.title,
                                        ),
                                      ),
                                      onTap: () {
                                        deleteVotation(widget.snap['votationId']
                                            .toString());
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        },
                        icon: const Icon(Icons.more_vert),
                      )
                    : Container(),
              ],
            ),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.only(left: 4),
              child: Container(
                  child: ListView.builder(
                shrinkWrap: true,
                itemCount: descriptions.length,
                itemBuilder: (context, index) {
                  bool isVoted = widget.snap['votes']?.any((vote) {
                        return vote['uid'] == user.uid &&
                            vote['optionDescription'] == descriptions[index];
                      }) ??
                      false;

                  bool hasVoted(List<dynamic>? votes, String uid) {
                    return votes?.any((vote) => vote['uid'] == uid) ?? false;
                  }

                  int optionVotes = widget.snap['votes']?.where((vote) {
                        return vote['optionDescription'] == descriptions[index];
                      })?.length ??
                      0;

                  int totalVotes = widget.snap['votes']?.length ?? 0;

                  double percentage =
                      calculatePercentage(optionVotes, totalVotes);

                  return InkWell(
                    onTap: () {
                      String votationId = widget.snap['votationId'].toString();
                      String uid = user.uid;
                      int optionIndex = index;
                      FireStoreMethods()
                          .votePost(votationId, uid, optionIndex)
                          .then((res) {
                        setState(() {
                          isLikeAnimating = res == 'success';
                        });
                        showSnackBar(context, res ?? 'An error occurred');
                      });
                    },
                    child: Container(
                      width: 50,
                      height: 35,
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        elevation: 5,
                        margin: const EdgeInsets.fromLTRB(15, 10, 15, 0),
                        color: isVoted ? AppTheme.nearlyBlack : AppTheme.vinho,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(width: 10),
                            Text(
                              hasVoted(widget.snap['votes'], user.uid)
                                  ? '${percentage.toStringAsFixed(0)}% voted for ${descriptions[index]}'
                                  : descriptions[index],
                              style: TextStyle(
                                color: AppTheme.subtitlewhite.color,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              )),
            ),
          ),
          DefaultTextStyle(
            style: TextStyle(
                color: AppTheme.nearlyBlack,
                fontFamily: 'Quicksand',
                fontWeight: FontWeight.bold),
            child: Row(
              children: <Widget>[
                Column(
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.comment_outlined,
                        color: AppTheme.nearlyBlack,
                      ),
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => CommentsScreen(
                            postId: widget.snap['postId'].toString(),
                          ),
                        ),
                      ),
                    ),
                    Text(
                      ' ${commentLen} ${commentLen == 1 ? 'comment' : 'comments'}',
                      style: TextStyle(color: AppTheme.nearlyBlack),
                    ),
                  ],
                ),
                Expanded(
                  child: Align(
                    alignment: Alignment.bottomRight,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        widget.snap['uid'].toString() == user.uid
                            ? SizedBox()
                            : IconButton(
                                icon: (widget.snap['userFavorites']
                                            ?.contains(widget.snap['postId']) ??
                                        false)
                                    ? const Icon(Icons.star,
                                        color: AppTheme.nearlyBlack)
                                    : const Icon(Icons.star_border,
                                        color: AppTheme.nearlyBlack),
                                onPressed: () {
                                  final userFavorites =
                                      widget.snap['userFavorites'] ??
                                          []; // Create an empty list if null

                                  // Add to favorites
                                  FireStoreMethods().toggleFavorite(
                                    widget.snap['postId'],
                                    user.uid,
                                  );

                                  setState(() {
                                    widget.snap['userFavorites'] =
                                        userFavorites;
                                  });
                                },
                              ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  alignment: Alignment.centerRight,
                  child: Text(
                    DateFormat.yMMMd()
                        .format(widget.snap['datePublished'].toDate()),
                    style: AppTheme.caption,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
