import 'package:flutter/material.dart';
import 'package:dressing_room/utils/colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:dressing_room/providers/user_provider.dart';
import 'package:dressing_room/screens/comments_screen.dart';
import 'package:intl/intl.dart';
import 'package:dressing_room/widgets/suggestion_card.dart';
import 'package:dressing_room/screens/seepost.dart';
import 'package:flutter/cupertino.dart';
import 'package:dressing_room/models/user.dart' as model;
import 'package:dressing_room/utils/utils.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

class ForumPage extends StatelessWidget {
  int chatQuantity = 7;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            "FÓRUM",
            style: AppTheme.barapp.copyWith(
              shadows: [
                Shadow(
                  blurRadius: 2.0,
                  color: Colors.black, // Cor da sombra
                ),
              ],
            ),
          ),
          centerTitle: true,
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(50.0),
            child: Container(
              width: double.infinity,
              color: Colors.transparent,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 19.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    InkWell(
                      onTap: () {},
                      child: Stack(
                        children: [
                          if (chatQuantity > 0)
                            Positioned(
                              right: 0,
                              top: 0,
                              child: Container(
                                padding: EdgeInsets.all(2),
                                decoration: BoxDecoration(
                                  color: AppTheme.vinho,
                                  borderRadius: BorderRadius.circular(7),
                                ),
                                constraints: BoxConstraints(
                                  minWidth: 20,
                                  minHeight: 20,
                                ),
                                child: Text(
                                  '$chatQuantity',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          InkWell(
                            onTap: () {},
                            child: Column(
                              children: [
                                Gap(10),
                                Row(
                                  children: [
                                    Text(
                                      "CHAT",
                                      style: AppTheme.subheadline
                                          .copyWith(fontSize: 16),
                                    ),
                                    Gap(13),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      children: [
                        Gap(9),
                        Icon(Icons.arrow_forward_ios, color: AppTheme.vinho),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          backgroundColor: Colors.transparent,
        ),
        body: StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection('forum')
                .orderBy('datePublished', descending: true)
                .snapshots(),
            builder: (context,
                AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (ctx, index) => Container(
                        margin: EdgeInsets.symmetric(),
                        child:
                            ForumCard(snap: snapshot.data!.docs[index].data()),
                      ));
            }));
  }
}

class ForumCard extends StatefulWidget {
  final snap;

  const ForumCard({
    Key? key,
    required this.snap,
  }) : super(key: key);

  @override
  State<ForumCard> createState() => _ForumCardState();
}

class _ForumCardState extends State<ForumCard> {
  List<String> getMergedList() {
    List<String> mergedList = [];
    if (widget.snap['pecasPhotoUrls'] != null) {
      mergedList.addAll(List<String>.from(widget.snap['pecasPhotoUrls']));
    }
    if (widget.snap['photoUrls'] != null) {
      mergedList.addAll(List<String>.from(widget.snap['photoUrls']));
    }
    return mergedList;
  }

  int commentLen = 0;
  bool existemPecas = false;
  bool showPecas = false;

  @override
  void initState() {
    super.initState();
    fetchCommentLen();
    checkExistemPecas();
  }

  void _showSuggestionMenu(BuildContext context) async {
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
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            child: SizedBox(
                              height: 600.h,
                              child: SuggestionCard(
                                postId: widget.snap['forumId'],
                                uid: widget.snap['uid'],
                                username: widget.snap['username'],
                                category: 'forum',
                                description: widget.snap['description'],
                                rating: null,
                              ),
                            ))
                      ]))
                    ])));
      },
    );

    fetchCommentLen();
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
                            'Sugestões',
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
                        Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            child: SizedBox(
                                height: 550.h,
                                child: CommentsScreen(
                                    postId: widget.snap['forumId'],
                                    description: widget.snap['description'],
                                    userquepostou: widget.snap['uid'],
                                    rating: "",
                                    category: 'forum')))
                      ]))
                    ])));
      },
    );
  }

  void _showClothes(context) {
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
                child: Expanded(
                    child: Column(
                  children: [
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
                      child: Text('Peças', style: AppTheme.barapp),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 70),
                      child: SizedBox(
                        height: 580.h,
                        child: ListView.builder(
                          itemCount: widget.snap['pecasPhotoUrls']!.length,
                          itemBuilder: (context, index) {
                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => SeePost(
                                      isTagclicked: false,
                                      postId: widget.snap['pecasIds']![index],
                                    ),
                                  ),
                                );
                              },
                              child: Padding(
                                padding: EdgeInsets.all(6.h),
                                child: Material(
                                  borderRadius: BorderRadius.circular(10.0),
                                  elevation: 3.0,
                                  child: Container(
                                    height: 160.h,
                                    decoration: BoxDecoration(
                                      color: Colors.grey[100],
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(10.0),
                                      child: Image.network(
                                        widget.snap['pecasPhotoUrls']![index],
                                        fit: BoxFit.contain,
                                        height: 150.h,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ))));
      },
    );
  }

  fetchCommentLen() async {
    try {
      QuerySnapshot snap = await FirebaseFirestore.instance
          .collection('forum')
          .doc(widget.snap['forumId'])
          .collection('comments')
          .get();
      QuerySnapshot snap2 = await FirebaseFirestore.instance
          .collection('forum')
          .doc(widget.snap['forumId'])
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

  @override
  Widget build(BuildContext context) {
    var mergedList = getMergedList();
    return Consumer<UserProvider>(builder: (context, userProvider, _) {
      model.User? user = userProvider.getUser;

      if (user == null) {
        return Container();
      }

      return Align(
        alignment: Alignment.center,
        child: Container(
          width: 340.w,
          padding: EdgeInsets.all(12),
          margin: EdgeInsets.symmetric(vertical: 5),
          decoration: BoxDecoration(
            color: AppTheme.nearlyWhite,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
              bottomRight: Radius.circular(12),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 10,
                ).copyWith(right: 0),
                child: Row(
                  children: <Widget>[
                    CircleAvatar(
                      radius: 16,
                      backgroundImage: NetworkImage(widget.snap['profImage']),
                    ),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(
                          left: 8,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            InkWell(
                              onTap: () {
                                // Navigator.of(context).push(
                                //   MaterialPageRoute(
                                //     builder: (context) => ProfileScreen(
                                //       uid: widget.widget.snap['uid'],
                                //     ),
                                //   ),
                                // );
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
                    Spacer(),
                    Visibility(
                        visible: existemPecas,
                        child: SizedBox(
                          width: 29.0,
                          height: 32.0,
                          child: FloatingActionButton(
                            onPressed: () {
                              setState(() {
                                _showClothes(context);
                              });
                            },
                            backgroundColor: AppTheme.cinza,
                            elevation: 10.0,
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
              Gap(10),
              Text(widget.snap['description'],
                  style: AppTheme.dividerfont
                      .copyWith(color: AppTheme.nearlyBlack)),
              if (mergedList.isNotEmpty)
                Padding(
                  padding: EdgeInsets.all(2),
                  child: SizedBox(
                    height: 100.h,
                    width: double.infinity,
                    child: GridView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: mergedList.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 1,
                      ),
                      itemBuilder: (context, index) {
                        return Padding(
                            padding: EdgeInsets.all(5),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10.0),
                              child: Image.network(
                                mergedList[index],
                                fit: BoxFit.fill,
                                width: double.infinity,
                                height: double.infinity,
                              ),
                            ));
                      },
                    ),
                  ),
                ),
              Gap(5),
              Row(
                children: [
                  InkWell(
                    onTap: () {
                      _showComments(context);
                    },
                    child: commentLen == 1
                        ? Text(
                            '$commentLen resposta',
                            style: AppTheme.subtitlewhite
                                .copyWith(color: AppTheme.vinho),
                          )
                        : Text(
                            '$commentLen respostas',
                            style: AppTheme.subtitlewhite
                                .copyWith(color: AppTheme.vinho),
                          ),
                  ),
                  Spacer(),
                  SizedBox(
                    width: 37.0,
                    height: 32.0,
                    child: FloatingActionButton(
                      onPressed: () {
                        _showComments(context);
                      },
                      backgroundColor: AppTheme.cinza,
                      elevation: 10.0,
                      shape: CircleBorder(), // Makes the button more circular
                      child: Icon(
                        Icons.comment_outlined,
                        size: 18,
                        color: AppTheme.nearlyBlack,
                      ),
                    ),
                  ),
                  Gap(5),
                  SizedBox(
                    width: 37.0,
                    height: 32.0,
                    child: FloatingActionButton(
                      onPressed: () {
                        _showSuggestionMenu(context);
                      },
                      backgroundColor: AppTheme.cinza,
                      elevation: 10.0,
                      shape: CircleBorder(), // Makes the button more circular
                      child: ImageIcon(
                        AssetImage(
                          'assets/SUGGESTION-OUTLINED.png',
                        ),
                        color: AppTheme.nearlyBlack,
                      ),
                    ),
                  )
                ],
              ),
              Gap(13),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  DateFormat.yMMMd()
                      .format(widget.snap['datePublished'].toDate()),
                  style: AppTheme.caption,
                ),
              )
            ],
          ),
        ),
      );
    });
  }
}

class Forum {
  final String description;
  final String uid;
  final String username;

  final String forumId;
  final DateTime datePublished;
  final List<String>? pecasPhotoUrls;
  final List<String>? pecasIds;
  final List<String> photoUrls;
  final String profImage;

  const Forum({
    required this.description,
    required this.uid,
    required this.username,
    required this.forumId,
    required this.datePublished,
    required this.photoUrls,
    required this.pecasPhotoUrls,
    required this.pecasIds,
    required this.profImage,
  });

  static Forum fromSnap(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map<String, dynamic>;

    return Forum(
      description: snapshot["description"],
      uid: snapshot["uid"],
      forumId: snapshot["forumId"],
      datePublished: snapshot["datePublished"].toDate(),
      username: snapshot["username"],
      photoUrls: List<String>.from(snapshot['photoUrls']),
      profImage: snapshot['profImage'],
      pecasIds: List<String>.from(snapshot['pecasIds']),
      pecasPhotoUrls: List<String>.from(snapshot['pecasPhotoUrls']),
    );
  }

  Map<String, dynamic> toJson() => {
        "description": description,
        "uid": uid,
        "username": username,
        "forumId": forumId,
        "datePublished": datePublished,
        'photoUrls': photoUrls,
        'profImage': profImage,
        'pecasIds': pecasIds,
        'pecasPhotoUrls': pecasPhotoUrls,
      };
}
