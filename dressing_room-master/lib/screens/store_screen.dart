import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dressing_room/screens/basket_screen.dart';
import 'package:dressing_room/screens/favorites_screen.dart';
import 'package:dressing_room/screens/product_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:dressing_room/resources/auth_methods.dart';
import 'package:dressing_room/resources/firestore_methods.dart';
import 'package:dressing_room/screens/login_screen.dart';
import 'package:dressing_room/utils/colors.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dressing_room/utils/utils.dart';
import 'package:gap/gap.dart';
import 'seepost.dart';
import 'package:dressing_room/widgets/follow_button.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class StoreScreen extends StatefulWidget {
  final String uid;

  StoreScreen({Key? key, required this.uid}) : super(key: key);

  @override
  _StoreScreenState createState() => _StoreScreenState();
}

class _StoreScreenState extends State<StoreScreen>
    with SingleTickerProviderStateMixin {
  var userData = {};
  int postLen = 0;
  int followers = 0;
  int following = 0;
  int tabviews = 0;
  bool isFollowing = false;
  bool isLoading = false;

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
            child: Stack(
              children: [
                Scaffold(
                    body: CustomScrollView(slivers: [
                  SliverAppBar(
                      backgroundColor: AppTheme.cinza,
                      expandedHeight: 230.h,
                      flexibleSpace: FlexibleSpaceBar(
                        background: Padding(
                          padding: const EdgeInsets.only(bottom: 15),
                          child: Stack(children: <Widget>[
                            ClipPath(
                              clipper: OvalBottomClipper(),
                              child: Image(
                                image: NetworkImage(userData['photoUrl']),
                                height: 245.h,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Positioned.fill(
                              bottom: 0,
                              child: Align(
                                  alignment: AlignmentDirectional.bottomCenter,
                                  child: Container(
                                    decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                            width: 3, color: AppTheme.cinza),
                                        color: Colors.white,
                                        boxShadow: [
                                          BoxShadow(
                                              color: Colors.black54,
                                              blurRadius: 15)
                                        ]),
                                    child: CircleAvatar(
                                      backgroundColor: Colors.grey,
                                      backgroundImage: NetworkImage(
                                        userData['photoUrl'],
                                      ),
                                      radius: 45,
                                    ),
                                  )),
                            ),
                          ]),
                        ),
                      )),
                  SliverList(
                    delegate: SliverChildListDelegate([
                      Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              userData['username'],
                              style: AppTheme.barapp.copyWith(
                                shadows: [
                                  Shadow(
                                    blurRadius: 1.6,
                                    color: Colors.black, // Cor da sombra
                                  ),
                                ],
                              ),
                            ),
                            Gap(16.h),
                            Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                buildStatColumn(postLen, "produtos"),
                                buildStatColumn(followers, "promoções"),
                                buildStatColumn(following, "representantes"),
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
                                            fontFamily: 'Bebas Neue',
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
                                              text: "VITRINE",
                                            ),
                                            Tab(
                                              text: "TODOS",
                                            ),
                                            Tab(
                                              text: "COLEÇÕES",
                                            ),
                                            Tab(
                                              text: "FOR YOU",
                                            ),
                                          ],
                                        ),
                                      )),
                                  SizedBox(
                                      height: 450.h,
                                      child: TabBarView(children: [
                                        Column(children: [
                                          Padding(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 3),
                                          ),
                                          FutureBuilder(
                                              future: FirebaseFirestore.instance
                                                  .collection('products')
                                                  .where('uid',
                                                      isEqualTo: widget.uid)
                                                  .get(),
                                              builder: (context, snapshot) {
                                                if (snapshot.connectionState ==
                                                    ConnectionState.waiting) {
                                                  return const Center(
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

                                                return SizedBox(
                                                  height: 340.h,
                                                  child: GridView.builder(
                                                    gridDelegate:
                                                        SliverGridDelegateWithFixedCrossAxisCount(
                                                      crossAxisCount:
                                                          3, // Ajustado para 3 colunas
                                                      mainAxisSpacing: 4.h,
                                                      crossAxisSpacing: 5.h,
                                                      childAspectRatio:
                                                          0.7, // Ajuste o aspecto para itens mais compactos
                                                    ),
                                                    itemCount: (snapshot.data!
                                                            as QuerySnapshot)
                                                        .docs
                                                        .length,
                                                    itemBuilder:
                                                        (context, index) {
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
                                                                          'productId']),
                                                            ),
                                                          );
                                                        },
                                                        child: Container(
                                                          decoration:
                                                              BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10),
                                                            border: Border.all(
                                                                color: Colors
                                                                    .grey
                                                                    .withOpacity(
                                                                        0.5)),
                                                            boxShadow: [
                                                              BoxShadow(
                                                                color: Colors
                                                                    .grey
                                                                    .withOpacity(
                                                                        0.5),
                                                                spreadRadius: 2,
                                                                blurRadius: 5,
                                                                offset: Offset(
                                                                    0, 3),
                                                              ),
                                                            ],
                                                            color: Colors.white,
                                                          ),
                                                          child: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              ClipRRect(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .only(
                                                                  topLeft: Radius
                                                                      .circular(
                                                                          10),
                                                                  topRight: Radius
                                                                      .circular(
                                                                          10),
                                                                ),
                                                                child: Image
                                                                    .network(
                                                                  snap['variations']
                                                                          [0][
                                                                      'photoUrls'][0],
                                                                  height: 100
                                                                      .h, // Reduzi a altura da imagem
                                                                  width: double
                                                                      .infinity,
                                                                  fit: BoxFit
                                                                      .cover,
                                                                ),
                                                              ),
                                                              Padding(
                                                                padding:
                                                                    EdgeInsets
                                                                        .all(8),
                                                                child: Column(
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .start,
                                                                  children: <Widget>[
                                                                    Text(
                                                                      snap[
                                                                          'description'],
                                                                      maxLines:
                                                                          1, // Reduzi para uma linha
                                                                      overflow:
                                                                          TextOverflow
                                                                              .ellipsis,
                                                                      style:
                                                                          TextStyle(
                                                                        fontSize:
                                                                            12,
                                                                        fontWeight:
                                                                            FontWeight.bold,
                                                                        color: Colors
                                                                            .black87,
                                                                      ),
                                                                    ),
                                                                    Gap(4
                                                                        .h), // Reduzi o espaçamento vertical
                                                                    Row(
                                                                      children: [
                                                                        Spacer(),
                                                                        Text(
                                                                          '\$${snap['variations'][0]['price']}',
                                                                          style:
                                                                              TextStyle(
                                                                            fontSize:
                                                                                14, // Reduzi o tamanho da fonte
                                                                            fontWeight:
                                                                                FontWeight.bold,
                                                                            color:
                                                                                AppTheme.vinho,
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                  ),
                                                );
                                              })
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
                                                      dynamic snap =
                                                          cloth[index];

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
                                                                snap[
                                                                    'photoUrl']),
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
                                                                    .doc(
                                                                        postIds[
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
                                                                String
                                                                    imageUrl =
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
                                                                          width:
                                                                              double.infinity,
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
                  ),
                ]))
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

class OvalBottomClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 25); // Reduzi a altura da curva
    path.quadraticBezierTo(size.width / 2, size.height + 25, size.width,
        size.height - 25); // Ajustei a curva
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return false;
  }
}
