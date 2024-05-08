import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dressing_room/widgets/suggestion_comment_card.dart';
import 'package:flutter/material.dart';
import 'package:dressing_room/models/user.dart';
import 'package:dressing_room/providers/user_provider.dart';
import 'package:gap/gap.dart';
import 'package:dressing_room/resources/firestore_methods.dart';
import 'package:dressing_room/utils/colors.dart';
import 'package:dressing_room/utils/utils.dart';
import 'package:flutter/cupertino.dart';

import 'package:dressing_room/widgets/comment_card.dart';
import 'package:provider/provider.dart';

class CommentsScreen extends StatefulWidget {
  final postId;
  final category;
  const CommentsScreen({Key? key, required this.postId, required this.category})
      : super(key: key);

  @override
  _CommentsScreenState createState() => _CommentsScreenState();
}

class _CommentsScreenState extends State<CommentsScreen> {
  late Stream<QuerySnapshot<Map<String, dynamic>>> _commentStream;
  late Stream<QuerySnapshot<Map<String, dynamic>>> _suggestionStream;
  final TextEditingController commentEditingController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    _commentStream = FirebaseFirestore.instance
        .collection(widget.category)
        .doc(widget.postId)
        .collection('comments')
        .snapshots();
    _suggestionStream = FirebaseFirestore.instance
        .collection(widget.category)
        .doc(widget.postId)
        .collection('suggestion')
        .snapshots();
  }

  void showDeleteItemDialog(BuildContext context, int index, String snapshot) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppTheme.nearlyWhite,
          title: Align(
            alignment: Alignment.center,
            child: Text(
              'Do you want to delete this item?',
              style: AppTheme.subheadline,
            ),
          ),
          content: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ElevatedButton(
                child: Text(
                  'No',
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
                  'Yes',
                  style: TextStyle(
                    fontFamily: 'Quicksand',
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(primary: AppTheme.vinho),
                onPressed: () async {
                  deleteComment(snapshot);

                  // Close the dialog
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> postCommentAndCreateNotification(
    String uid,
    String name,
    String profilePic,
  ) async {
    try {
      String res = await FireStoreMethods().postComment(
        widget.postId,
        commentEditingController.text,
        uid,
        name,
        profilePic,
        widget.category,
      );

      if (res != 'success') {
        showSnackBar(context, res);
      } else {
        setState(() {
          commentEditingController.text = '';
        });
      }
    } catch (err) {
      showSnackBar(context, err.toString());
    }
  }

  void deleteComment(String commentId) async {
    try {
      String res = await FireStoreMethods()
          .deleteComment(widget.postId, commentId, widget.category);
      if (res == 'success') {
        showSnackBar(context, 'Comment deleted');
      } else {
        showSnackBar(context, res);
      }
    } catch (err) {
      showSnackBar(context, err.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, _) {
        User? user = userProvider.getUser;

        if (user == null) {
          return Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
        return Scaffold(
          resizeToAvoidBottomInset: false,
          body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: _commentStream,
            builder: (context, commentSnapshot) {
              if (commentSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              List<DocumentSnapshot<Map<String, dynamic>>> comments =
                  commentSnapshot.data!.docs;

              return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: _suggestionStream,
                builder: (context, suggestionSnapshot) {
                  if (suggestionSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  List<DocumentSnapshot<Map<String, dynamic>>> suggestion =
                      suggestionSnapshot.data!.docs;

                  List<DocumentSnapshot<Map<String, dynamic>>> allDocuments = [
                    ...suggestion,
                    ...comments
                  ];

                  allDocuments.sort((a, b) =>
                      (b.data()!['datePublished'] as Timestamp)
                          .compareTo(a.data()!['datePublished'] as Timestamp));

                  return Scrollbar(
                      thickness: 7,
                      thumbVisibility: true,
                      child: ListView.builder(
                        itemCount: allDocuments.length,
                        itemBuilder: (context, index) {
                          final documentData = allDocuments[index].data();

                          if (documentData!.containsKey('commentId')) {
                            // Find the index of the comment in the comments list
                            int commentIndex = comments.indexWhere((comment) =>
                                comment.id == allDocuments[index].id);
                            return CommentCard(
                              snap: comments[commentIndex],
                              onDelete: () => showDeleteItemDialog(context,
                                  commentIndex, comments[commentIndex].id),
                            );
                          } else {
                            // Find the index of the suggestion in the suggestions list
                            int suggestionIndex = suggestion.indexWhere(
                                (suggestion) =>
                                    suggestion.id == allDocuments[index].id);
                            return SuggestionCommentCard(
                              snap: suggestion[suggestionIndex],
                              onDelete: () => showDeleteItemDialog(
                                  context,
                                  suggestionIndex,
                                  suggestion[suggestionIndex].id),
                            );
                          }
                        },
                      ));
                },
              );
            },
          ),
          bottomNavigationBar: SafeArea(
            child: Container(
              height: kToolbarHeight,
              margin: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              padding: const EdgeInsets.only(left: 16, right: 8),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundImage: NetworkImage(user!.photoUrl),
                    radius: 18,
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 16, right: 8),
                      child: TextField(
                        controller: commentEditingController,
                        style: AppTheme.title,
                        decoration: InputDecoration(
                          hintText: 'Comment as ${user.username}',
                          hintStyle: AppTheme.subtitle,
                          border: InputBorder.none,
                        ),
                        maxLines: null,
                        textInputAction: TextInputAction.newline,
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () => postCommentAndCreateNotification(
                      user!.uid,
                      user.username,
                      user.photoUrl,
                    ),
                    child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 8),
                        child: Icon(Icons.send, color: AppTheme.nearlyBlack)),
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
