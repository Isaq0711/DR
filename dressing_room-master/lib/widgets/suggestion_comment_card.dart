import 'package:dressing_room/screens/seepost.dart';
import 'package:flutter/material.dart';
import 'package:dressing_room/utils/colors.dart';
import 'package:intl/intl.dart';
import 'package:dressing_room/models/user.dart' as model;
import 'package:dressing_room/screens/profile_screen.dart';
import 'package:gap/gap.dart';
import 'package:dressing_room/providers/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:dressing_room/utils/utils.dart';

class SuggestionCommentCard extends StatefulWidget {
  final dynamic snap;
  final VoidCallback onDelete; // Adicione onDelete como um parâmetro

  SuggestionCommentCard({Key? key, required this.snap, required this.onDelete})
      : super(key: key);

  @override
  _SuggestionCommentCardState createState() => _SuggestionCommentCardState();
}

class _SuggestionCommentCardState extends State<SuggestionCommentCard> {
  String? username;
  String? profilePhoto;
  bool isLoading = false;

  @override
  void initState() {
    getData();
  }

  getData() async {
    setState(() {
      isLoading = true;
    });
    try {
      var userSnap = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.snap.data()['uid'])
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

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, _) {
        model.User? user = userProvider.getUser;
        if (user == null) {
          return Container();
        }
        if (isLoading) {
          return Center(
            child: CircularProgressIndicator(
              color: Colors.blueAccent,
            ),
          );
        }
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InkWell(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => ProfileScreen(
                          uid: widget.snap.data()['uid'],
                          isMainn: false,
                        ),
                      ),
                    );
                  },
                  child: CircleAvatar(
                    backgroundImage: NetworkImage(
                      profilePhoto!,
                    ),
                    radius: 9,
                  )),
              Gap(8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    InkWell(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => ProfileScreen(
                                uid: widget.snap.data()['uid'],
                                isMainn: false,
                              ),
                            ),
                          );
                        },
                        child: Text(
                          username! + " sugeriu: ",
                          style: AppTheme.subtitle,
                        )),
                    Gap(4),
                    Padding(
                        padding: EdgeInsets.symmetric(horizontal: 5),
                        child: SizedBox(
                            height: 100.h,
                            child: RawScrollbar(
                                thumbVisibility: true,
                                thumbColor: Colors.grey,
                                radius: Radius.circular(20),
                                thickness: 5,
                                scrollbarOrientation:
                                    ScrollbarOrientation.bottom,
                                child: GridView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount:
                                      widget.snap.data()['photoUrls'].length,
                                  gridDelegate:
                                      SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 1,
                                  ),
                                  itemBuilder: (context, index) {
                                    return ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: InkWell(
                                            child: Image.network(
                                              widget.snap.data()['photoUrls']
                                                  [index],
                                              fit: BoxFit.fill,
                                            ),
                                            onTap: () {
                                              widget.snap.data()['postIds']
                                                          [index] !=
                                                      ""
                                                  ? Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) =>
                                                            SeePost(
                                                          isTagclicked: false,
                                                          postId: widget.snap
                                                                  .data()[
                                                              'postIds'][index],
                                                        ),
                                                      ),
                                                    )
                                                  : showDialog(
                                                      context: context,
                                                      builder: (BuildContext
                                                          context) {
                                                        return Dialog(
                                                            backgroundColor:
                                                                AppTheme
                                                                    .nearlyWhite,
                                                            child: Column(
                                                                mainAxisSize:
                                                                    MainAxisSize
                                                                        .min,
                                                                children: [
                                                                  Gap(5.h),
                                                                  Text(
                                                                    "Upload Feito",
                                                                    style: AppTheme
                                                                        .barapp,
                                                                  ),
                                                                  Gap(5.h),
                                                                  ClipRRect(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            10),
                                                                    child: Image
                                                                        .network(
                                                                      widget.snap
                                                                              .data()['photoUrls']
                                                                          [
                                                                          index],
                                                                      fit: BoxFit
                                                                          .fill,
                                                                    ),
                                                                  ),
                                                                  Gap(30.h),
                                                                ]));
                                                      });
                                            }));
                                  },
                                )))),
                    widget.snap.data()['text'] == ''
                        ? SizedBox.shrink()
                        : Text(
                            widget.snap.data()['text'],
                            style: AppTheme.title,
                          ),
                    Gap(4),
                    Text(
                      DateFormat.yMMMd().format(
                        widget.snap.data()['datePublished'].toDate(),
                      ),
                      style: AppTheme.caption,
                    ),
                  ],
                ),
              ),
              if (widget.snap['uid'].toString() == user.uid)
                IconButton(
                  icon: Icon(Icons.delete_rounded, color: Colors.grey),
                  onPressed: widget.onDelete,
                ), // Adicione o IconButton de exclusão
            ],
          ),
        );
      },
    );
  }
}
