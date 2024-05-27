import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dressing_room/screens/basket_screen.dart';
import 'package:dressing_room/screens/favorites_screen.dart';
import 'package:dressing_room/screens/product_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:dressing_room/screens/store_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:dressing_room/resources/auth_methods.dart';
import 'package:dressing_room/resources/firestore_methods.dart';
import 'package:dressing_room/screens/login_screen.dart';
import 'package:dressing_room/utils/colors.dart';
import 'package:dressing_room/utils/utils.dart';
import 'package:gap/gap.dart';
import 'package:two_dimensional_scrollables/two_dimensional_scrollables.dart';
import 'edit_profile_screen.dart';
import 'seepost.dart';
import 'package:dressing_room/widgets/follow_button.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProfileScreen extends StatefulWidget {
  final String uid;

  ProfileScreen({Key? key, required this.uid}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  var userData = {};
  int postLen = 0;
  int followers = 0;
  int following = 0;
  int tabviews = 0;
  bool isFollowing = false;
  bool isLoading = false;
  final double drawerWidth = 300.0;
  bool isDrawerOpen = false;
  String selectedOption = "public";

  @override
  void initState() {
    super.initState();

    getData();
  }

  getData() async {
    setState(() {
      isLoading = true;
    });
    try {
      var userSnap = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.uid)
          .get();

      var postSnap = await FirebaseFirestore.instance
          .collection('posts')
          .where('uid', isEqualTo: widget.uid)
          .get();

      var votationSnap = await FirebaseFirestore.instance
          .collection('votations')
          .where('uid', isEqualTo: widget.uid)
          .get();

      postLen = postSnap.docs.length + votationSnap.docs.length;
      userData = userSnap.data()!;
      followers = userSnap.data()!['followers'].length;
      following = userSnap.data()!['following'].length;
      tabviews = userSnap.data()!['tabviews'].length;
      isFollowing = userSnap
          .data()!['followers']
          .contains(FirebaseAuth.instance.currentUser!.uid);
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

  void openDrawer() {
    setState(() {
      isDrawerOpen = true;
    });
  }

  void closeDrawer() {
    setState(() {
      isDrawerOpen = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? Center(
            child: CircularProgressIndicator(),
          )
        : GestureDetector(
            onTap: closeDrawer,
            child: Stack(
              children: [
                Scaffold(
                  appBar: AppBar(
                    title: Text(
                      "Profile",
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
                    backgroundColor: Colors.transparent,
                    actions: [
                      if (FirebaseAuth.instance.currentUser!.uid == widget.uid)
                        IconButton(
                          icon: Icon(
                            shadows: <Shadow>[
                              Shadow(
                                  color: AppTheme.nearlyBlack, blurRadius: 3.0)
                            ],
                            CupertinoIcons.list_bullet,
                            color: AppTheme.nearlyBlack,
                          ),
                          onPressed: openDrawer,
                        ),
                    ],
                    iconTheme: IconThemeData(color: AppTheme.vinho),
                  ),
                  body: ListView(children: [
                    Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          InkWell(
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return Dialog(
                                    backgroundColor: Colors.transparent,
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        CircleAvatar(
                                          backgroundColor: Colors.grey,
                                          backgroundImage: NetworkImage(
                                            userData['photoUrl'],
                                          ),
                                          radius: 119,
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              );
                            },
                            child: CircleAvatar(
                              backgroundColor: Colors.grey,
                              backgroundImage: NetworkImage(
                                userData['photoUrl'],
                              ),
                              radius: 45,
                            ),
                          ),
                          Gap(16.h),
                          Text(
                            userData['username'],
                            style: AppTheme.title,
                          ),
                          Gap(16.h),
                          Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              buildStatColumn(postLen, "lojas"),
                              buildStatColumn(followers, "seguidores"),
                              buildStatColumn(following, "seguindo"),
                            ],
                          ),
                          Gap(16.h),
                          if (FirebaseAuth.instance.currentUser!.uid ==
                              widget.uid)
                            Container()
                          else if (isFollowing)
                            FollowButton(
                              text: 'Unfollow',
                              backgroundColor: AppTheme.vinho,
                              textColor: AppTheme.nearlyWhite,
                              borderColor: Colors.grey,
                              function: () async {
                                await FireStoreMethods().followUser(
                                  FirebaseAuth.instance.currentUser!.uid,
                                  userData['uid'],
                                );

                                setState(() {
                                  isFollowing = false;
                                  followers--;
                                });
                              },
                            )
                          else
                            FollowButton(
                              text: 'Follow',
                              backgroundColor: AppTheme.vinho,
                              textColor: AppTheme.nearlyWhite,
                              borderColor: Colors.grey,
                              function: () async {
                                await FireStoreMethods().followUser(
                                  FirebaseAuth.instance.currentUser!.uid,
                                  userData['uid'],
                                );

                                setState(() {
                                  isFollowing = true;
                                  followers++;
                                });
                              },
                            ),
                          DefaultTabController(
                              length: 4,
                              initialIndex: 0,
                              child: Column(children: [
                                Container(
                                    color: Colors.transparent,
                                    child: RawScrollbar(
                                      mainAxisMargin: 5,
                                      trackVisibility: false,
                                      thumbVisibility: true,
                                      interactive: false,
                                      scrollbarOrientation:
                                          ScrollbarOrientation.top,
                                      child: TabBar(
                                        tabAlignment: TabAlignment.center,
                                        dividerColor: AppTheme.nearlyWhite,
                                        isScrollable: true,
                                        indicatorColor: AppTheme.vinhoroxeado,
                                        labelColor: AppTheme.vinho,
                                        labelStyle: AppTheme.caption.copyWith(
                                          shadows: [
                                            Shadow(
                                              blurRadius: .5,
                                              color: Colors.black,
                                            ),
                                          ],
                                        ),
                                        unselectedLabelColor:
                                            AppTheme.nearlyWhite,
                                        tabs: [
                                          Tab(
                                            icon: Icon(
                                              Icons.public,
                                            ),
                                          ),

                                          Tab(
                                            icon: ImageIcon(
                                              AssetImage('assets/ELECTION.png'),
                                            ),
                                          ),
                                          Tab(
                                            icon: ImageIcon(
                                              AssetImage(
                                                  'assets/CLOSET-FILL.png'),
                                            ),
                                          ),
                                          Tab(
                                            icon: Icon(
                                              CupertinoIcons.heart_fill,
                                            ),
                                          ),
                                          // if (showAll)
                                          //   for (Map<String, dynamic> tabText
                                          //       in userData['tabviews'])
                                          //     Tab(text: tabText.keys.first),
                                        ],
                                      ),
                                    )),
                                Gap(20.h),
                                SizedBox(
                                    height: 450.h,
                                    child: TabBarView(children: [
                                      Column(
                                        children: [
                                          Padding(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 3),
                                            child: FutureBuilder(
                                              future: Future.wait([
                                                FirebaseFirestore.instance
                                                    .collection('posts')
                                                    .where('uid',
                                                        isEqualTo: widget.uid)
                                                    .get(),
                                                FirebaseFirestore.instance
                                                    .collection(
                                                        'anonymous_posts')
                                                    .where('uid',
                                                        isEqualTo: widget.uid)
                                                    .get(),
                                              ]),
                                              builder: (context, snapshot) {
                                                if (snapshot.connectionState ==
                                                    ConnectionState.waiting) {
                                                  return Center(
                                                    child:
                                                        CircularProgressIndicator(),
                                                  );
                                                }

                                                var posts = (snapshot.data![0]
                                                        as QuerySnapshot)
                                                    .docs;
                                                var anonymousPosts =
                                                    (snapshot.data![1]
                                                            as QuerySnapshot)
                                                        .docs;

                                                var allPosts;

                                                if (FirebaseAuth.instance
                                                        .currentUser!.uid ==
                                                    widget.uid) {
                                                  allPosts = [
                                                    ...posts,
                                                    ...anonymousPosts
                                                  ];
                                                } else {
                                                  allPosts = [...posts];
                                                }

                                                return SizedBox(
                                                  height: 300.h,
                                                  child: GridView.builder(
                                                    gridDelegate:
                                                        SliverGridDelegateWithFixedCrossAxisCount(
                                                      crossAxisCount: 3,
                                                      mainAxisSpacing: 3.h,
                                                      crossAxisSpacing: 6.h,
                                                    ),
                                                    itemCount: allPosts.length,
                                                    itemBuilder:
                                                        (context, index) {
                                                      DocumentSnapshot snap =
                                                          allPosts[index];
                                                      bool isAnonymousPost =
                                                          anonymousPosts
                                                              .contains(snap);

                                                      return GestureDetector(
                                                        onTap: () {
                                                          Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                              builder: (context) =>
                                                                  SeePost(
                                                                      postId: snap[
                                                                          'postId']),
                                                            ),
                                                          );
                                                        },
                                                        child: ClipRRect(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(10),
                                                          child: Container(
                                                            decoration:
                                                                BoxDecoration(
                                                              color:
                                                                  Colors.grey,
                                                            ),
                                                            child:
                                                                isAnonymousPost
                                                                    ? Stack(
                                                                        children: [
                                                                          Image(
                                                                            image:
                                                                                NetworkImage(snap['photoUrls'][0]),
                                                                            fit:
                                                                                BoxFit.fill,
                                                                            width:
                                                                                double.infinity,
                                                                            // image: NetworkImage('https://cdn-icons-png.flaticon.com/512/4123/4123763.png'),
                                                                          ),
                                                                          Positioned(
                                                                            top:
                                                                                2,
                                                                            right:
                                                                                2,
                                                                            child:
                                                                                SizedBox(
                                                                              height: 25,
                                                                              child: Image(
                                                                                image: NetworkImage('https://cdn-icons-png.flaticon.com/512/4123/4123763.png'),
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      )
                                                                    : Image(
                                                                        image: NetworkImage(snap['photoUrls']
                                                                            [
                                                                            0]),
                                                                        fit: BoxFit
                                                                            .fill,
                                                                      ),
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                  ),
                                                );
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                      Column(children: [
                                        Padding(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 3),
                                        ),
                                        FutureBuilder(
                                          future: FirebaseFirestore.instance
                                              .collection('votations')
                                              .where('uid',
                                                  isEqualTo: widget.uid)
                                              .get(),
                                          builder: (context, snapshot) {
                                            if (snapshot.connectionState ==
                                                ConnectionState.waiting) {
                                              return Center(
                                                child:
                                                    CircularProgressIndicator(),
                                              );
                                            }
                                            if (!snapshot.hasData ||
                                                (snapshot.data as QuerySnapshot)
                                                    .docs
                                                    .isEmpty) {
                                              return NoContent();
                                            }

                                            return SizedBox(
                                              height: 300.h,
                                              child: GridView.builder(
                                                gridDelegate:
                                                    SliverGridDelegateWithFixedCrossAxisCount(
                                                  crossAxisCount: 3,
                                                  mainAxisSpacing: 3.h,
                                                  crossAxisSpacing: 6.h,
                                                ),
                                                itemCount: (snapshot.data!
                                                        as QuerySnapshot)
                                                    .docs
                                                    .length,
                                                scrollDirection:
                                                    Axis.horizontal,
                                                itemBuilder: (context, index) {
                                                  DocumentSnapshot snap =
                                                      (snapshot.data!
                                                              as QuerySnapshot)
                                                          .docs[index];

                                                  return GestureDetector(
                                                    onTap: () {
                                                      Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder: (context) =>
                                                              SeePost(
                                                                  postId: snap[
                                                                      'votationId']),
                                                        ),
                                                      );
                                                    },
                                                    child: ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10),
                                                      child: Container(
                                                        decoration:
                                                            BoxDecoration(
                                                          color: Colors.grey,
                                                        ),
                                                        child: Image(
                                                          image: NetworkImage(
                                                              snap['options'][0]
                                                                  ['photoUrl']),
                                                          fit: BoxFit.fill,
                                                        ),
                                                      ),
                                                    ),
                                                  );
                                                },
                                              ),
                                            );
                                          },
                                        ),
                                      ]),
                                      Column(
                                        children: [
                                          Padding(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 16),
                                          ),

                                          // Padding(
                                          //   padding: EdgeInsets.symmetric(
                                          //       horizontal: 16),
                                          //   child: Row(
                                          //     children: [
                                          //       Text(
                                          //         "Favorites",
                                          //         style: AppTheme.subheadline,
                                          //       ),
                                          //     ],
                                          //   ),
                                          // ),
                                          // FutureBuilder(
                                          //   future: FirebaseFirestore.instance
                                          //       .collection('favorites')
                                          //       .doc(widget
                                          //           .uid) // Use the user's ID as the document ID
                                          //       .collection('userFavorites')
                                          //       .get(),
                                          //   builder: (context, snapshot) {
                                          //     if (snapshot.connectionState ==
                                          //         ConnectionState.waiting) {
                                          //       return Center(
                                          //         child:
                                          //             CircularProgressIndicator(),
                                          //       );
                                          //     }

                                          //     List<QueryDocumentSnapshot>
                                          //         favorites = (snapshot.data!
                                          //                 as QuerySnapshot)
                                          //             .docs;

                                          //     return SizedBox(
                                          //       height: 150,
                                          //       child: ListView.builder(
                                          //         itemCount: favorites.length,
                                          //         scrollDirection:
                                          //             Axis.horizontal,
                                          //         itemBuilder:
                                          //             (context, index) {
                                          //           dynamic snap =
                                          //               favorites[index];

                                          //           return GestureDetector(
                                          //             onTap: () {
                                          //               Navigator.push(
                                          //                 context,
                                          //                 MaterialPageRoute(
                                          //                   builder: (context) =>
                                          //                       SeePost(
                                          //                           postId: snap[
                                          //                               'postId']),
                                          //                 ),
                                          //               );
                                          //             },
                                          //             child: Padding(
                                          //               padding:
                                          //                   EdgeInsets.all(
                                          //                       8.0),
                                          //               child: ClipRRect(
                                          //                 borderRadius:
                                          //                     BorderRadius
                                          //                         .circular(
                                          //                             10),
                                          //                 child: Container(
                                          //                   width: 150,
                                          //                   decoration:
                                          //                       BoxDecoration(
                                          //                     color:
                                          //                         Colors.grey,
                                          //                   ),
                                          //                   child: Image(
                                          //                     image: NetworkImage(
                                          //                         snap['photoUrls']
                                          //                             [0]),
                                          //                     fit: BoxFit
                                          //                         .cover,
                                          //                   ),
                                          //                 ),
                                          //               ),
                                          //             ),
                                          //           );
                                          //         },
                                          //       ),
                                          //     );
                                          //   },
                                          // ),
                                          Padding(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 3),
                                          ),
                                          FutureBuilder(
                                            future: FirebaseFirestore.instance
                                                .collection('clothes')
                                                .where('uid',
                                                    isEqualTo: widget.uid)
                                                .get(),
                                            builder: (context, snapshot) {
                                              if (snapshot.connectionState ==
                                                  ConnectionState.waiting) {
                                                return Center(
                                                  child:
                                                      CircularProgressIndicator(),
                                                );
                                              }
                                              if (!snapshot.hasData ||
                                                  (snapshot.data
                                                          as QuerySnapshot)
                                                      .docs
                                                      .isEmpty) {
                                                return NoContent();
                                              }
                                              List<QueryDocumentSnapshot>
                                                  cloth = (snapshot.data!
                                                          as QuerySnapshot)
                                                      .docs;

                                              return SizedBox(
                                                height: 300.h,
                                                child: GridView.builder(
                                                  gridDelegate:
                                                      SliverGridDelegateWithFixedCrossAxisCount(
                                                    crossAxisCount: 3,
                                                    mainAxisSpacing: 3.h,
                                                    crossAxisSpacing: 6.h,
                                                  ),
                                                  itemCount: cloth.length,
                                                  itemBuilder:
                                                      (context, index) {
                                                    dynamic snap = cloth[index];

                                                    return GestureDetector(
                                                      onTap: () {
                                                        Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                            builder: (context) =>
                                                                SeePost(
                                                                    postId: snap[
                                                                        'clothId']),
                                                          ),
                                                        );
                                                      },
                                                      child: ClipRRect(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10),
                                                        child: Image(
                                                          image: NetworkImage(
                                                              snap['photoUrl']),
                                                          fit: BoxFit.fill,
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                ),
                                              );
                                            },
                                          ),
                                        ],
                                      ),
                                      Column(
                                        children: [
                                          userData['tabviews'].isEmpty
                                              ? NoContent()
                                              : SizedBox(
                                                  height: 450.h,
                                                  child: GridView.builder(
                                                    gridDelegate:
                                                        SliverGridDelegateWithFixedCrossAxisCount(
                                                      crossAxisCount: 3,
                                                      mainAxisSpacing: 8.h,
                                                      crossAxisSpacing: 8.h,
                                                      childAspectRatio: 1.0,
                                                    ),
                                                    itemCount:
                                                        userData['tabviews']
                                                            .length,
                                                    itemBuilder:
                                                        (context, index) {
                                                      Map<String, dynamic>
                                                          tabView =
                                                          userData['tabviews']
                                                              [index];
                                                      String tabName =
                                                          tabView.keys.first;
                                                      List<dynamic> postIds =
                                                          tabView[tabName];
                                                      [
                                                        0
                                                      ]; // Assuming postId is the identifier to fetch image URL
                                                      return FutureBuilder(
                                                          future:
                                                              FirebaseFirestore
                                                                  .instance
                                                                  .collection(
                                                                      'posts')
                                                                  .doc(postIds[
                                                                      0])
                                                                  .get(),
                                                          builder: (context,
                                                              AsyncSnapshot<
                                                                      DocumentSnapshot>
                                                                  snapshot) {
                                                            if (snapshot
                                                                    .connectionState ==
                                                                ConnectionState
                                                                    .waiting) {
                                                              return Center(
                                                                child:
                                                                    CircularProgressIndicator(), // Display a loading indicator while fetching data
                                                              );
                                                            } else if (snapshot
                                                                .hasError) {
                                                              return Text(
                                                                  'Error: ${snapshot.error}');
                                                            } else {
                                                              String imageUrl =
                                                                  snapshot.data![
                                                                      'photoUrls'][0];

                                                              return Stack(
                                                                children: [
                                                                  ClipRRect(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            10),
                                                                    child:
                                                                        InkWell(
                                                                      child: Image
                                                                          .network(
                                                                        imageUrl,
                                                                        fit: BoxFit
                                                                            .fill,
                                                                        width: double
                                                                            .infinity,
                                                                      ),
                                                                      onTap:
                                                                          () {
                                                                        showDialog(
                                                                          context:
                                                                              context,
                                                                          builder:
                                                                              (BuildContext context) {
                                                                            return Dialog(
                                                                              backgroundColor: AppTheme.cinza,
                                                                              child: Column(
                                                                                mainAxisSize: MainAxisSize.min,
                                                                                children: [
                                                                                  Gap(20),
                                                                                  Text(tabName, style: AppTheme.barapp),
                                                                                  Gap(15),
                                                                                  SizedBox(
                                                                                    height: 300.h,
                                                                                    child: FutureBuilder(
                                                                                      future: Future.wait(postIds.map((postId) {
                                                                                        return FirebaseFirestore.instance.collection('posts').doc(postId).get();
                                                                                      }).toList()),
                                                                                      builder: (context, AsyncSnapshot<List<DocumentSnapshot>> snapshot) {
                                                                                        if (snapshot.connectionState == ConnectionState.waiting) {
                                                                                          return Center(
                                                                                            child: CircularProgressIndicator(), // Display a loading indicator while fetching data
                                                                                          );
                                                                                        } else if (snapshot.hasError) {
                                                                                          return Text('Error: ${snapshot.error}');
                                                                                        } else {
                                                                                          List<String> imageUrls = snapshot.data!.map((doc) => doc['photoUrls'][0] as String).toList();

                                                                                          return GridView.builder(
                                                                                            shrinkWrap: true, // Ensures the GridView takes minimal space
                                                                                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                                                                              crossAxisCount: 3,
                                                                                              mainAxisSpacing: 8.h,
                                                                                              crossAxisSpacing: 8.h,
                                                                                              childAspectRatio: 1.0,
                                                                                            ),
                                                                                            itemCount: imageUrls.length,
                                                                                            itemBuilder: (context, index) {
                                                                                              return GestureDetector(
                                                                                                onTap: () {
                                                                                                  Navigator.push(
                                                                                                    context,
                                                                                                    MaterialPageRoute(
                                                                                                      builder: (context) => SeePost(postId: postIds[index]),
                                                                                                    ),
                                                                                                  );
                                                                                                },
                                                                                                child: ClipRRect(
                                                                                                  borderRadius: BorderRadius.circular(10),
                                                                                                  child: Image.network(
                                                                                                    imageUrls[index],
                                                                                                    fit: BoxFit.fill,
                                                                                                  ),
                                                                                                ),
                                                                                              );
                                                                                            },
                                                                                          );
                                                                                        }
                                                                                      },
                                                                                    ),
                                                                                  ),
                                                                                ],
                                                                              ),
                                                                            );
                                                                          },
                                                                        );
                                                                      },
                                                                    ),
                                                                  ),
                                                                  Positioned(
                                                                      top: 0,
                                                                      right: 3,
                                                                      child: FirebaseAuth.instance.currentUser!.uid ==
                                                                              widget.uid
                                                                          ? GestureDetector(
                                                                              onTap: () {
                                                                                Navigator.push(
                                                                                  context,
                                                                                  MaterialPageRoute(builder: (context) => EditProfileScreen(uid: FirebaseAuth.instance.currentUser!.uid)),
                                                                                );
                                                                              },
                                                                              child: Container(
                                                                                  decoration: BoxDecoration(
                                                                                    color: AppTheme.vinho,
                                                                                    borderRadius: BorderRadius.circular(16.0), // Borda arredondada com metade da altura para criar um círculo
                                                                                  ),
                                                                                  child: Padding(
                                                                                    padding: EdgeInsets.all(3),
                                                                                    child: Icon(
                                                                                      Icons.edit,
                                                                                      color: AppTheme.nearlyWhite,
                                                                                      size: 18,
                                                                                    ),
                                                                                  )))
                                                                          : SizedBox.shrink()),
                                                                  Positioned(
                                                                    bottom: 0,
                                                                    left: 0,
                                                                    right: 0,
                                                                    child:
                                                                        Container(
                                                                      decoration:
                                                                          BoxDecoration(
                                                                        color: AppTheme
                                                                            .vinhoescuro,
                                                                        borderRadius:
                                                                            BorderRadius.circular(6.0), // Defina o raio da borda
                                                                      ),
                                                                      child:
                                                                          Center(
                                                                        child:
                                                                            Text(
                                                                          tabName,
                                                                          style: AppTheme
                                                                              .dividerfont
                                                                              .copyWith(color: Colors.white),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ],
                                                              );
                                                            }
                                                          });
                                                    },
                                                  ),
                                                ),
                                        ],
                                      )
                                    ]))
                              ]))
                        ],
                      ),
                    ),
                  ]),
                  backgroundColor: AppTheme.cinza,
                ),
                AnimatedPositioned(
                  duration: Duration(milliseconds: 300),
                  top: 0,
                  right: isDrawerOpen ? 0 : -drawerWidth,
                  bottom: 0,
                  width: drawerWidth,
                  child: Container(
                    color: AppTheme.vinhoroxeado,
                    child: Column(
                      children: [
                        Gap(70.h),
                        CircleAvatar(
                          backgroundColor: Colors.grey,
                          backgroundImage: NetworkImage(
                            userData['photoUrl'],
                          ),
                          radius: 40.h,
                        ),
                        Gap(16.h),
                        ListTile(
                          leading: Icon(
                            Icons.edit,
                            color: AppTheme.nearlyWhite,
                          ),
                          title: Text(
                            "Edit Profile",
                            style: AppTheme.subheadlinewhite,
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => EditProfileScreen(
                                      uid: FirebaseAuth
                                          .instance.currentUser!.uid)),
                            );
                          },
                        ),
                        ListTile(
                          leading: Icon(
                            Icons.shopify_sharp,
                            color: AppTheme.nearlyWhite,
                          ),
                          title: Text(
                            "My Purchases",
                            style: AppTheme.subheadlinewhite,
                          ),
                          onTap: () {},
                        ),
                        Divider(),
                        Expanded(
                            child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 16),
                                child: ListView(children: [
                                  Text(
                                    "Collections",
                                    style: AppTheme.subtitlewhite,
                                  ),
                                  ListTile(
                                    leading: Icon(
                                      Icons.favorite,
                                      color: AppTheme.nearlyWhite,
                                    ),
                                    title: Text(
                                      "Favorites",
                                      style: AppTheme.subheadlinewhite,
                                    ),
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => FavoritesScreen(
                                            isShoppingBag: false,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                  ListTile(
                                    leading: Icon(
                                      CupertinoIcons.bag_fill,
                                      color: AppTheme.nearlyWhite,
                                    ),
                                    title: Text(
                                      "Shopping Bag",
                                      style: AppTheme.subheadlinewhite,
                                    ),
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => BasketScreen(),
                                        ),
                                      );
                                    },
                                  ),
                                  Divider(),
                                  Text(
                                    "My stores",
                                    style: AppTheme.subtitlewhite,
                                  ),
                                  ListTile(
                                    leading: Icon(
                                      Icons.add,
                                      color: AppTheme.nearlyWhite,
                                    ),
                                    title: Text(
                                      "Create a store",
                                      style: AppTheme.subheadlinewhite,
                                    ),
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => StoreScreen(
                                              uid: FirebaseAuth
                                                  .instance.currentUser!.uid),
                                        ),
                                      );
                                    },
                                  ),
                                  Divider(),
                                  ListTile(
                                    leading: Icon(
                                      Icons.logout,
                                      color: AppTheme.nearlyWhite,
                                    ),
                                    title: Text(
                                      "Logout",
                                      style: AppTheme.subheadlinewhite,
                                    ),
                                    onTap: () {
                                      AuthMethods().signOut().then((value) {
                                        Navigator.pushAndRemoveUntil(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    LoginScreen()),
                                            (Route<dynamic> route) => false);
                                      });
                                    },
                                  )
                                ]))),
                        Text(
                          "Version: beta of beta",
                          style: AppTheme.subtitlewhite,
                        ),
                        Gap(10)
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
  }

  Column buildStatColumn(int count, String label) {
    return Column(
      children: [
        Text(
          count.toString(),
          style: AppTheme.title,
        ),
        Text(
          label,
          style: AppTheme.subtitle,
        ),
      ],
    );
  }
}

class NoContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Image.asset(
        'assets/NO-CONTENT.png',
        height: 400.h,
        width: 250.w,
      ),
    );
  }
}
