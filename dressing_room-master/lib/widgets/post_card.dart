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
  int currentImageIndex = 0;
  bool isFavorite = false;
 

  @override
  void initState() {
    super.initState();
    fetchCommentLen();
  
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

  double getDislikePercentage() {
    int totalReactions =
        widget.snap['likes'].length + widget.snap['dislikes'].length;
    if (totalReactions == 0) {
      return 0.0;
    }
    double dislikePercentage =
        (widget.snap['dislikes'].length / totalReactions) * 100;
    return dislikePercentage;
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
      // boundary needed for web
      decoration: BoxDecoration(
        border: Border.all(
          color: width > webScreenSize ? Colors.grey : Colors.grey,
        ),
        borderRadius: BorderRadius.circular(10.0),
        color: AppTheme.nearlyWhite,
      ),
      
      child: Column(
        children: [
          // HEADER SECTION OF THE POST
      

          // IMAGE SECTION OF THE POST
          
        GestureDetector(
 onDoubleTap: () {
 
},

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
      height: MediaQuery.of(context).size.height * 0.5,
      width: double.infinity,
       child: ClipRRect(
      borderRadius: BorderRadius.circular(10.0),
      child: PageView.builder(
        itemCount: widget.snap['photoUrls'].length,
        controller: PageController(initialPage: currentImageIndex),
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
                            fit: BoxFit.cover,)
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
  child: widget.snap['photoUrls'].length > 1 ? DotsIndicator(
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
  ) : SizedBox.shrink(),
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
                                        deletePost(widget.snap['postId']
                                            .toString());
                                        deleteAnonymousPost(
                                            widget.snap['postId'].toString());
                                        // remove the dialog box
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
                child: Text(
                  widget.snap['description'].toString(),
                  style: AppTheme.subtitle,
                ),
              ),
            ),
          ),
          // LIKE, COMMENT SECTION OF THE POST
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
                      icon: widget.snap['likes'].contains(user.uid)
                          ? const Icon(
                              Icons.thumb_up_sharp,
                              color: Colors.green,
                            )
                          : const Icon(
                              Icons.thumb_up_sharp,
                              color: AppTheme.nearlyBlack,
                            ),
                      onPressed: () {
                        // Verifica se o usuário já deu dislike antes de permitir dar like
                        if (!widget.snap['dislikes'].contains(user.uid)) {
                          FireStoreMethods().likePost(
                            widget.snap['postId'].toString(),
                            user.uid,
                            widget.snap['likes'],
                          );
                        
                        }
                      },
                    ),
                    Text(
                      '${getLikePercentage().toStringAsFixed(0)}%',
                      style: TextStyle(color: AppTheme.nearlyBlack),
                    ),
                  ],
                ),
                Column(
                  children: [
                    IconButton(
                      icon: widget.snap['dislikes'].contains(user.uid)
                          ? const Icon(
                              Icons.thumb_down_sharp,
                              color: Colors.red,
                            )
                          : const Icon(
                              Icons.thumb_down_sharp,
                              color: AppTheme.nearlyBlack,
                            ),
                      onPressed: () {
                        // Verifica se o usuário já deu like antes de permitir dar dislike
                        if (!widget.snap['likes'].contains(user.uid)) {
                          FireStoreMethods().dislikePost(
                            widget.snap['postId'].toString(),
                            user.uid,
                            widget.snap['dislikes'],
                          );
                         
                        }
                      },
                    ),
                    Text(
                      '${getDislikePercentage().toStringAsFixed(0)}%',
                      style: TextStyle(color: AppTheme.nearlyBlack),
                    ),
                  ],
                ),
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
   icon: Icon(
    isFavorite ? Icons.star : Icons.star_border,
    color: AppTheme.nearlyBlack,
  ),
  onPressed: () async {
    String uid = user.uid;
    String postId = widget.snap['postId'].toString();
    String result = await FireStoreMethods().toggleFavorite(postId, uid);

    setState(() {
      isFavorite = !isFavorite;
    });

    showSnackBar(
      context,
      result,
    );
  },
),
          Text( '',
                   ),
                    ],
                  ),
                ),
                ),
              ],
            ),
          ),

          // DATA
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
                    style: AppTheme.caption ,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
 });
  }
}