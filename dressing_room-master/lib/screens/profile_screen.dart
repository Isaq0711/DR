import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dressing_room/models/store.dart';
import 'package:dressing_room/screens/basket_screen.dart';
import 'package:dressing_room/screens/favorites_screen.dart';
import 'package:dressing_room/screens/product_screen.dart';
import 'package:dressing_room/screens/shopping_cart.dart';
import 'package:dressing_room/screens/tinder_like_page.dart';
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
import 'edit_profile_screen.dart';
import 'create_store_screen.dart';
import 'seepost.dart';
import 'package:dressing_room/widgets/follow_button.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProfileScreen extends StatefulWidget {
  final String uid;
  final bool isMainn;

  ProfileScreen({Key? key, required this.uid, required this.isMainn})
      : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  var userData = {};
  var storesData = {};
  int storesLen = 0;

  int followers = 0;
  int following = 0;
  int tabviews = 0;
  List<dynamic> followersIDs = [];
  List<dynamic> followingIDs = [];
  List<String> fotosUrls = [];
  List<String> clothItens = [];
  List<dynamic> storesIDs = [];
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

      var storeSnap = await FirebaseFirestore.instance
          .collection('store')
          .where('adms', arrayContains: widget.uid)
          .get();

      var clothesSnap = await FirebaseFirestore.instance
          .collection('wardrobe')
          .doc(widget.uid)
          .collection('clothes')
          .get();

      clothItens.clear();
      fotosUrls.clear();

      for (var doc in clothesSnap.docs) {
        String clothId = doc['clothId'];
        clothItens.add(clothId);

        var clothDataSnap = await FirebaseFirestore.instance
            .collection('clothes')
            .doc(clothId)
            .get();

        String photoUrl = clothDataSnap['photoUrl'];
        fotosUrls.add(photoUrl);
      }

      storesLen = storeSnap.docs.length;
      storesData = userSnap.data()!;
      userData = userSnap.data()!;
      followers = userSnap.data()!['followers'].length;
      following = userSnap.data()!['following'].length;

      followersIDs = userSnap.data()!['followers'];
      followingIDs = userSnap.data()!['following'];
      storesIDs = storeSnap.docs.map((doc) => doc.id).toList();
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
            onHorizontalDragUpdate: !widget.isMainn
                ? (details) {
                    if (details.primaryDelta! > 0) {
                      // Se o arrasto horizontal for para a esquerda (negativo)
                      Navigator.pop(context);
                    }
                  }
                : (details) {
                    if (details.primaryDelta! < 0) {
                      openDrawer();
                    }
                    if (isDrawerOpen) {
                      if (details.primaryDelta! > 0) {
                        // Se o arrasto horizontal for para a esquerda (negativo)
                        closeDrawer();
                      }
                    }
                  },
            child: Stack(
              children: [
                Scaffold(
                  appBar: AppBar(
                    leading: !widget.isMainn
                        ? IconButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            icon: Icon(
                              Icons.arrow_back_ios,
                              color: AppTheme.nearlyBlack,
                            ),
                          )
                        : SizedBox.shrink(),
                    title: Text(
                      FirebaseAuth.instance.currentUser!.uid == widget.uid
                          ? "Meu Perfil"
                          : "Perfil",
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
                  floatingActionButton: Visibility(
                      visible:
                          FirebaseAuth.instance.currentUser!.uid != widget.uid,
                      child: Container(
                        margin: EdgeInsets.only(
                          bottom: 10.h,
                        ),
                        child: FloatingActionButton(
                          onPressed: () {
                            setState(() {});
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => TinderScreen(
                                        uid: widget.uid,
                                        datainicial: null,
                                      )),
                            );
                          },
                          backgroundColor: AppTheme.vinho,
                          elevation: 2.0,
                          child: ImageIcon(
                            AssetImage(
                              'assets/SUGGESTION.png',
                            ),
                            size: 30,
                            color: AppTheme.cinza,
                          ),
                        ),
                      )),
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
                                        InteractiveViewer(
                                          minScale: 1,
                                          maxScale: 15,
                                          clipBehavior: Clip.none,
                                          child: CircleAvatar(
                                            backgroundColor: Colors.grey,
                                            backgroundImage: NetworkImage(
                                              userData['photoUrl'],
                                            ),
                                            radius: 119,
                                          ),
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
                              buildStatColumn(
                                  storesLen, "lojas", storesIDs, 'store'),
                              buildStatColumn(followers, "seguidores",
                                  followersIDs, 'users'),
                              buildStatColumn(
                                  following, "seguindo", followingIDs, 'users'),
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
                                              AssetImage(
                                                  'assets/ELECTION-FILL.png'),
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
                                Gap(5.h),
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
                                                allPosts.sort((a, b) =>
                                                    (b.data()!['datePublished']
                                                            as Timestamp)
                                                        .compareTo(a.data()![
                                                                'datePublished']
                                                            as Timestamp));

                                                return SizedBox(
                                                  height: 400.h,
                                                  child: GridView.builder(
                                                    physics:
                                                        const NeverScrollableScrollPhysics(),
                                                    gridDelegate:
                                                        SliverGridDelegateWithFixedCrossAxisCount(
                                                      crossAxisCount: 3,
                                                      mainAxisSpacing: 6.h,
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
                                                              builder: (context) => SeePost(
                                                                  isTagclicked:
                                                                      false,
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
                                                                            .cover,
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
                                              height: 400.h,
                                              child: GridView.builder(
                                                physics:
                                                    const NeverScrollableScrollPhysics(),
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
                                                                  isTagclicked:
                                                                      false,
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
                                                          fit: BoxFit.cover,
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
                                                  horizontal: 3, vertical: 5),
                                              child: SizedBox(
                                                height: 430.h,
                                                child: GridView.builder(
                                                  physics:
                                                      const NeverScrollableScrollPhysics(),
                                                  gridDelegate:
                                                      SliverGridDelegateWithFixedCrossAxisCount(
                                                    crossAxisCount: 3,
                                                    mainAxisSpacing: 6.h,
                                                    crossAxisSpacing: 6.h,
                                                  ),
                                                  itemCount: clothItens.length,
                                                  itemBuilder:
                                                      (context, index) {
                                                    return GestureDetector(
                                                        onTap: () {
                                                          Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                              builder: (context) => SeePost(
                                                                  isTagclicked:
                                                                      false,
                                                                  postId:
                                                                      clothItens[
                                                                          index]),
                                                            ),
                                                          );
                                                        },
                                                        child: Material(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10.0),
                                                            elevation: 6.0,
                                                            child: Container(
                                                              decoration:
                                                                  BoxDecoration(
                                                                color: Colors
                                                                    .grey[200],
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            10.0),
                                                              ),
                                                              child: ClipRRect(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            10),
                                                                child: Image(
                                                                  image: NetworkImage(
                                                                      fotosUrls[
                                                                          index]),
                                                                  fit: BoxFit
                                                                      .contain,
                                                                ),
                                                              ),
                                                            )));
                                                  },
                                                ),
                                              ))
                                        ],
                                      ),
                                      Column(
                                        children: [
                                          userData['tabviews'].isEmpty
                                              ? NoContent()
                                              : SizedBox(
                                                  height: 450.h,
                                                  child: GridView.builder(
                                                    physics:
                                                        const NeverScrollableScrollPhysics(),
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
                                                                            .cover,
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
                                                                                                      builder: (context) => SeePost(
                                                                                                        postId: postIds[index],
                                                                                                        isTagclicked: false,
                                                                                                      ),
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
                            "Editar Perfil",
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
                            "Minhas compras",
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
                                    "Coleções",
                                    style: AppTheme.subtitlewhite,
                                  ),
                                  ListTile(
                                    leading: Icon(
                                      Icons.favorite,
                                      color: AppTheme.nearlyWhite,
                                    ),
                                    title: Text(
                                      "Favoritos",
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
                                      CupertinoIcons.cart_fill,
                                      color: AppTheme.nearlyWhite,
                                    ),
                                    title: Text(
                                      "Carrinho",
                                      style: AppTheme.subheadlinewhite,
                                    ),
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              ShoppingCart(uid: widget.uid),
                                        ),
                                      );
                                    },
                                  ),
                                  Divider(),
                                  Text(
                                    "Minhas lojas",
                                    style: AppTheme.subtitlewhite,
                                  ),
                                  ListTile(
                                    leading: Icon(
                                      Icons.add,
                                      color: AppTheme.nearlyWhite,
                                    ),
                                    title: Text(
                                      "Criar uma loja",
                                      style: AppTheme.subheadlinewhite,
                                    ),
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              CreateStoreScreen(),
                                        ),
                                      );
                                    },
                                  ),
                                  FutureBuilder<QuerySnapshot>(
                                    future: FirebaseFirestore.instance
                                        .collection('store')
                                        .where('adms',
                                            arrayContains: FirebaseAuth
                                                .instance.currentUser!.uid)
                                        .get(),
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState ==
                                          ConnectionState.waiting) {
                                        return Center(
                                            child: CircularProgressIndicator());
                                      }
                                      if (!snapshot.hasData ||
                                          snapshot.data!.docs.isEmpty) {
                                        return SizedBox.shrink();
                                      }
                                      var userStores = snapshot.data!.docs;
                                      return ListView.builder(
                                        shrinkWrap: true,
                                        itemCount: userStores.length,
                                        itemBuilder: (context, index) {
                                          var store = userStores[index].data()
                                              as Map<String, dynamic>;
                                          return ListTile(
                                            leading: Container(
                                                decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    border: Border.all(
                                                        width: 1,
                                                        color: AppTheme.cinza),
                                                    color: Colors.white,
                                                    boxShadow: [
                                                      BoxShadow(
                                                          color: Colors.black54,
                                                          blurRadius: 15)
                                                    ]),
                                                child: CircleAvatar(
                                                  radius: 13,
                                                  backgroundImage: NetworkImage(
                                                      store['photoUrl']),
                                                )),
                                            title: Expanded(
                                              child: Text(
                                                store['storename'],
                                                style:
                                                    AppTheme.subheadlinewhite,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            onTap: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      StoreScreen(
                                                    storeId: store['storeId'],
                                                  ),
                                                ),
                                              );
                                            },
                                          );
                                        },
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
                                      "Sair",
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

  Column buildStatColumn(
      int count, String label, List<dynamic> uids, String category) {
    String name = "";
    return Column(
      children: [
        InkWell(
          child: Column(children: [
            Text(
              count.toString(),
              style: AppTheme.title,
            ),
            Text(
              label,
              style: AppTheme.subtitle,
            ),
          ]),
          onTap: () {
            category == "users" ? name = "username" : name = "storename";
            if (count > 0)
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Dialog(
                            backgroundColor: AppTheme.cinza,
                            child: Padding(
                              padding: const EdgeInsets.all(10),
                              child: FutureBuilder<QuerySnapshot>(
                                  future: FirebaseFirestore.instance
                                      .collection(category)
                                      .where(FieldPath.documentId,
                                          whereIn: uids)
                                      .get(),
                                  builder: (BuildContext context,
                                      AsyncSnapshot<QuerySnapshot> snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return Center(
                                          child: CircularProgressIndicator());
                                    }

                                    if (snapshot.hasError) {
                                      return Text('Erro ao carregar dados');
                                    }
                                    List<UserData> userDataList = [];

                                    if (snapshot.hasData &&
                                        snapshot.data!.docs.isNotEmpty) {
                                      snapshot.data!.docs.forEach((doc) {
                                        userDataList.add(UserData(doc[name],
                                            doc.id, doc['photoUrl']));
                                      });
                                    }

                                    return Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(label, style: AppTheme.barapp),
                                          const Gap(10),
                                          ListView.builder(
                                            shrinkWrap: true,
                                            itemCount: userDataList.length,
                                            itemBuilder: (BuildContext context,
                                                int index) {
                                              return ListTile(
                                                leading: Container(
                                                    decoration: BoxDecoration(
                                                        shape: BoxShape.circle,
                                                        border: Border.all(
                                                            width: 1,
                                                            color:
                                                                AppTheme.cinza),
                                                        color: Colors.white,
                                                        boxShadow: [
                                                          BoxShadow(
                                                              color: Colors
                                                                  .black54,
                                                              blurRadius: 15)
                                                        ]),
                                                    child: CircleAvatar(
                                                      radius: 13,
                                                      backgroundImage:
                                                          NetworkImage(
                                                              userDataList[
                                                                      index]
                                                                  .foto),
                                                    )),
                                                title: Text(
                                                  userDataList[index].username,
                                                  style: AppTheme.subheadline,
                                                ),
                                                onTap: () {
                                                  name == "storename"
                                                      ? Navigator.of(context).push(
                                                          MaterialPageRoute(
                                                              builder:
                                                                  (context) =>
                                                                      StoreScreen(
                                                                        storeId:
                                                                            userDataList[index].uid,
                                                                      )))
                                                      : Navigator.of(context)
                                                          .push(
                                                              MaterialPageRoute(
                                                          builder: (context) =>
                                                              ProfileScreen(
                                                            uid: userDataList[
                                                                    index]
                                                                .uid,
                                                            isMainn: false,
                                                          ),
                                                        ));
                                                },
                                              );
                                            },
                                          ),
                                        ]);
                                  }),
                            ))
                      ],
                    ),
                  );
                },
              );
          },
        ),
      ],
    );
  }
}

class UserData {
  final String username;
  final String uid;
  final String foto;

  UserData(this.username, this.uid, this.foto);
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
