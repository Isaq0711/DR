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
import 'package:dressing_room/utils/global_variable.dart';
import 'package:dressing_room/utils/utils.dart';
import 'package:dressing_room/widgets/like_animation.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

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
  bool showreactions = false;
  int currentImageIndex = 0;
  bool isFavorite = false;
  double rating = 0;

  @override
  void initState() {
    super.initState();
    fetchCommentLen();
    getInitialRating();
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
        final width = MediaQuery.of(context).size.width;
        if (user == null) {
          return Container();
        }

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
                onHorizontalDragEnd: (details) {
                  if (details.primaryVelocity! > 0) {
                    goToPreviousImage();
                  } else if (details.primaryVelocity! < 0) {
                    goToNextImage();
                  }
                },
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.63,
                      width: double.infinity,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10.0),
                        child: PageView.builder(
                          itemCount: widget.snap['photoUrls'].length,
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
                                widget.snap['photoUrls'][index],
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
                          Icons.star,
                          color: Colors.yellow,
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
                child: widget.snap['photoUrls'].length > 1
                    ? DotsIndicator(
                        dotsCount: widget.snap['photoUrls'].length,
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
                                if (widget.snap['username'] !=
                                    "Anonymous User") {
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
                                widget.snap['username'],
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
                              showModalBottomSheet(
                                context: context,
                                builder: (context) {
                                  return Container(
                                    color: AppTheme.vinho,
                                    padding: EdgeInsets.all(16),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        IconButton(
                                          icon: Icon(Icons.delete),
                                          color: AppTheme
                                              .nearlyWhite, // ou a cor desejada
                                          onPressed: () {
                                            deletePost(widget.snap['postId']
                                                .toString());
                                            deleteAnonymousPost(widget
                                                .snap['postId']
                                                .toString());
                                            // Fechar o container
                                            Navigator.of(context).pop();
                                          },
                                        ),
                                        IconButton(
                                          icon: Icon(Icons.shopping_basket),
                                          color: AppTheme
                                              .nearlyWhite, // ou a cor desejada
                                          onPressed: () {},
                                        ),
                                        IconButton(
                                          icon: Icon(Icons.star),
                                          color: AppTheme
                                              .nearlyWhite, // ou a cor desejada
                                          onPressed: () {},
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              );
                            },
                            icon: const Icon(Icons.more_vert),
                          )
                        : IconButton(
                            color: showreactions == true
                                ? AppTheme.nearlyWhite
                                : AppTheme.nearlyBlack,
                            onPressed: () {
                              setState(() {
                                showreactions = true;
                              });
                            },
                            icon: const Icon(Icons.more_horiz_rounded),
                          ),
                    if (showreactions == true)
                      Padding(
                          padding: EdgeInsets.all(8),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              color:
                                  AppTheme.cinza, // Defina a cor desejada aqui
                            ),
                            child: Row(
                              children: [
                                IconButton(
                                  icon: Icon(Icons.shopping_bag_outlined),
                                  color: AppTheme.nearlyBlack,
                                  onPressed: () {},
                                ),
                                IconButton(
                                  icon: Icon(
                                    Icons.favorite_border,
                                  ),
                                  color: AppTheme.nearlyBlack,
                                  onPressed: () {},
                                ),
                                IconButton(
                                  icon: Icon(
                                    Icons.arrow_circle_up,
                                  ),
                                  color: AppTheme.nearlyBlack,
                                  onPressed: () {},
                                ),
                                IconButton(
                                  icon: Icon(
                                    Icons.share,
                                  ),
                                  color: AppTheme.nearlyBlack,
                                  onPressed: () {},
                                ),
                                IconButton(
                                  icon: const Icon(Icons.more_horiz_rounded),
                                  color: AppTheme.nearlyBlack,
                                  onPressed: () {
                                    setState(() {
                                      showreactions = false;
                                    });
                                  },
                                ),
                              ],
                            ),
                          ))
                  ],
                ),
              ),
              Gap(10),
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(left: 4),
                  child: Container(
                    child: Text(
                      widget.snap['description'].toString(),
                      style: AppTheme.subtitle,
                    ),
                  ),
                ),
              ),
              Gap(10),
              Row(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 4),
                      child: Container(
                        child: Text(
                          "Average Rating of the post: ${widget.snap['grade']}",
                          style: AppTheme.subtitle,
                        ),
                      ),
                    ),
                  ),
                  Icon(Icons.star, color: AppTheme.vinho),
                ],
              ),
              DefaultTextStyle(
                style: TextStyle(
                    color: AppTheme.nearlyBlack,
                    fontFamily: 'Quicksand',
                    fontWeight: FontWeight.bold),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Column(
                      children: [
                        RatingBar.builder(
                          initialRating: rating,
                          minRating: 0,
                          direction: Axis.horizontal,
                          allowHalfRating: true,
                          itemCount: 5,
                          itemPadding: EdgeInsets.symmetric(horizontal: 2.0),
                          itemBuilder: (context, _) => Icon(
                            Icons.star,
                            color: AppTheme.vinho,
                          ),
                          itemSize: 30.0,
                          unratedColor: Colors.grey,
                          onRatingUpdate: (rating) async {
                            print("Rating: $rating");
                            String uid = user.uid;
                            String postId = widget.snap['postId'].toString();
                            await FireStoreMethods()
                                .getUserGrade(postId, uid, rating);
                            setState(() {});
                          },
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.comment_rounded,
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
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Container(
                        alignment: Alignment.centerRight,
                        child: Text(
                          DateFormat.yMMMd()
                              .format(widget.snap['datePublished'].toDate()),
                          style: AppTheme.caption,
                        ),
                      ),
                    ),
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
