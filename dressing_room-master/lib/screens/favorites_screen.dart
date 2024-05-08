import 'package:dressing_room/resources/firestore_methods.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:dressing_room/providers/user_provider.dart';
import 'package:dressing_room/models/user.dart';
import 'package:dressing_room/utils/utils.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/cupertino.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:dressing_room/utils/colors.dart';

import 'seepost.dart';

class FavoritesScreen extends StatefulWidget {
  final bool isShoppingBag;
  const FavoritesScreen({Key? key, required this.isShoppingBag})
      : super(key: key);

  @override
  _FavoritesScreenState createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen>
    with SingleTickerProviderStateMixin {
  bool isLoading = false;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = widget.isShoppingBag
        ? TabController(length: 1, vsync: this)
        : TabController(length: 5, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        leading: !widget.isShoppingBag
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
          'User Favorites',
          style: AppTheme.subheadline.copyWith(
            shadows: [
              Shadow(
                blurRadius: 2.0,
                color: Colors.black, // Shadow color
                // Shadow's X and Y offset
              ),
            ],
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Gap(3.h),
          TabBar(
            controller: _tabController,
            isScrollable: true,
            dividerColor: AppTheme.nearlyWhite,
            tabAlignment: TabAlignment.center,
            indicatorColor: AppTheme.vinhoescuro,
            labelStyle: AppTheme.subtitle.copyWith(
              shadows: [
                Shadow(
                  blurRadius: 5.0,
                  color: Colors.black, // Shadow color
                  // Shadow's X and Y offset
                ),
              ],
            ),
            unselectedLabelColor: AppTheme.nearlyWhite,
            tabs: widget.isShoppingBag
                ? [
                    Tab(text: 'Adicionar classificação por tipo'),
                  ]
                : [
                    Tab(text: 'All'),
                    Tab(text: 'Collections'),
                    Tab(text: 'Posts'),
                    Tab(text: 'Products'),
                    Tab(text: 'Votations'),
                  ],
            onTap: (index) {
              setState(() {});
            },
          ),
          Gap(10),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: widget.isShoppingBag
                  ? [
                      Column(
                        children: [
                          FutureBuilder(
                            future: FirebaseFirestore.instance
                                .collection('favorites')
                                .doc(FirebaseAuth.instance.currentUser!.uid)
                                .collection('userFavorites')
                                .orderBy('dateAdded', descending: true)
                                .get(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return Center(
                                  child: CircularProgressIndicator(),
                                );
                              }

                              List<QueryDocumentSnapshot> favorites =
                                  (snapshot.data! as QuerySnapshot).docs;

                              Future<List<QueryDocumentSnapshot>>
                                  filterFavorites() async {
                                List<QueryDocumentSnapshot> validFavorites = [];
                                for (var favorite in favorites) {
                                  String postId = favorite['postId'];
                                  bool existsInProducts =
                                      (await FirebaseFirestore.instance
                                              .collection('products')
                                              .doc(postId)
                                              .get())
                                          .exists;

                                  if (existsInProducts) {
                                    validFavorites.add(favorite);
                                  }
                                }
                                return validFavorites;
                              }

                              return FutureBuilder(
                                future: filterFavorites(),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return Center(
                                      child: CircularProgressIndicator(),
                                    );
                                  }

                                  List<QueryDocumentSnapshot> validFavorites =
                                      snapshot.data
                                          as List<QueryDocumentSnapshot>;

                                  return Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 16),
                                    child: SizedBox(
                                      height: 450.h,
                                      child: GridView.builder(
                                        gridDelegate:
                                            SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: 3,
                                          mainAxisSpacing: 8.h,
                                          crossAxisSpacing: 8.h,
                                          childAspectRatio: 1.0,
                                        ),
                                        itemCount: validFavorites.length,
                                        itemBuilder: (context, index) {
                                          String postId =
                                              validFavorites[index]['postId'];

                                          return ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            child: InkWell(
                                              child: Image.network(
                                                validFavorites[index]
                                                    ['photoUrls'][0],
                                                fit: BoxFit.fill,
                                              ),
                                              onTap: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        SeePost(
                                                      postId: postId,
                                                    ),
                                                  ),
                                                );
                                              },
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ],
                      ),
                    ]
                  : [
                      Column(
                        children: [
                          FutureBuilder(
                            future: FirebaseFirestore.instance
                                .collection('favorites')
                                .doc(FirebaseAuth.instance.currentUser!.uid)
                                .collection('userFavorites')
                                .orderBy('dateAdded', descending: true)
                                .get(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return Center(
                                  child: CircularProgressIndicator(),
                                );
                              }

                              List<QueryDocumentSnapshot> favorites =
                                  (snapshot.data! as QuerySnapshot).docs;

                              return Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 16),
                                  child: SizedBox(
                                    height: 450.h,
                                    child: GridView.builder(
                                      gridDelegate:
                                          SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 3,
                                        mainAxisSpacing: 8.h,
                                        crossAxisSpacing: 8.h,
                                        childAspectRatio: 1.0,
                                      ),
                                      itemCount: favorites.length,
                                      itemBuilder: (context, index) {
                                        return ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          child: InkWell(
                                            child: Image.network(
                                              favorites[index]['photoUrls'][0],
                                              fit: BoxFit.fill,
                                            ),
                                            onTap: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) => SeePost(
                                                    postId: favorites[index]
                                                        ['postId'],
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                        );
                                      },
                                    ),
                                  ));
                            },
                          ),
                        ],
                      ),
                      Column(),
                      Column(
                        children: [
                          FutureBuilder(
                            future: FirebaseFirestore.instance
                                .collection('favorites')
                                .doc(FirebaseAuth.instance.currentUser!.uid)
                                .collection('userFavorites')
                                .orderBy('dateAdded', descending: true)
                                .get(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return Center(
                                  child: CircularProgressIndicator(),
                                );
                              }

                              List<QueryDocumentSnapshot> favorites =
                                  (snapshot.data! as QuerySnapshot).docs;

                              // Função assíncrona para filtrar os favoritos
                              Future<List<QueryDocumentSnapshot>>
                                  filterFavorites() async {
                                List<QueryDocumentSnapshot> validFavorites = [];
                                for (var favorite in favorites) {
                                  String postId = favorite['postId'];
                                  bool existsInPosts = (await FirebaseFirestore
                                          .instance
                                          .collection('posts')
                                          .doc(postId)
                                          .get())
                                      .exists;
                                  bool existsInAnonymousPosts =
                                      (await FirebaseFirestore.instance
                                              .collection('anonymousposts')
                                              .doc(postId)
                                              .get())
                                          .exists;

                                  if (existsInPosts || existsInAnonymousPosts) {
                                    validFavorites.add(favorite);
                                  }
                                }
                                return validFavorites;
                              }

                              return FutureBuilder(
                                future: filterFavorites(),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return Center(
                                      child: CircularProgressIndicator(),
                                    );
                                  }

                                  List<QueryDocumentSnapshot> validFavorites =
                                      snapshot.data
                                          as List<QueryDocumentSnapshot>;

                                  return Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 16),
                                    child: SizedBox(
                                      height: 450.h,
                                      child: GridView.builder(
                                        gridDelegate:
                                            SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: 3,
                                          mainAxisSpacing: 8.h,
                                          crossAxisSpacing: 8.h,
                                          childAspectRatio: 1.0,
                                        ),
                                        itemCount: validFavorites.length,
                                        itemBuilder: (context, index) {
                                          String postId =
                                              validFavorites[index]['postId'];

                                          return ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            child: InkWell(
                                              child: Image.network(
                                                validFavorites[index]
                                                    ['photoUrls'][0],
                                                fit: BoxFit.fill,
                                              ),
                                              onTap: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        SeePost(
                                                      postId: postId,
                                                    ),
                                                  ),
                                                );
                                              },
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          FutureBuilder(
                            future: FirebaseFirestore.instance
                                .collection('favorites')
                                .doc(FirebaseAuth.instance.currentUser!.uid)
                                .collection('userFavorites')
                                .orderBy('dateAdded', descending: true)
                                .get(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return Center(
                                  child: CircularProgressIndicator(),
                                );
                              }

                              List<QueryDocumentSnapshot> favorites =
                                  (snapshot.data! as QuerySnapshot).docs;

                              Future<List<QueryDocumentSnapshot>>
                                  filterFavorites() async {
                                List<QueryDocumentSnapshot> validFavorites = [];
                                for (var favorite in favorites) {
                                  String postId = favorite['postId'];
                                  bool existsInProducts =
                                      (await FirebaseFirestore.instance
                                              .collection('products')
                                              .doc(postId)
                                              .get())
                                          .exists;

                                  if (existsInProducts) {
                                    validFavorites.add(favorite);
                                  }
                                }
                                return validFavorites;
                              }

                              return FutureBuilder(
                                future: filterFavorites(),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return Center(
                                      child: CircularProgressIndicator(),
                                    );
                                  }

                                  List<QueryDocumentSnapshot> validFavorites =
                                      snapshot.data
                                          as List<QueryDocumentSnapshot>;

                                  return Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 16),
                                    child: SizedBox(
                                      height: 450.h,
                                      child: GridView.builder(
                                        gridDelegate:
                                            SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: 3,
                                          mainAxisSpacing: 8.h,
                                          crossAxisSpacing: 8.h,
                                          childAspectRatio: 1.0,
                                        ),
                                        itemCount: validFavorites.length,
                                        itemBuilder: (context, index) {
                                          String postId =
                                              validFavorites[index]['postId'];

                                          return ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            child: InkWell(
                                              child: Image.network(
                                                validFavorites[index]
                                                    ['photoUrls'][0],
                                                fit: BoxFit.fill,
                                              ),
                                              onTap: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        SeePost(
                                                      postId: postId,
                                                    ),
                                                  ),
                                                );
                                              },
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          FutureBuilder(
                            future: FirebaseFirestore.instance
                                .collection('favorites')
                                .doc(FirebaseAuth.instance.currentUser!.uid)
                                .collection('userFavorites')
                                .orderBy('dateAdded', descending: true)
                                .get(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return Center(
                                  child: CircularProgressIndicator(),
                                );
                              }

                              List<QueryDocumentSnapshot> favorites =
                                  (snapshot.data! as QuerySnapshot).docs;

                              Future<List<QueryDocumentSnapshot>>
                                  filterFavorites() async {
                                List<QueryDocumentSnapshot> validFavorites = [];
                                for (var favorite in favorites) {
                                  String postId = favorite['postId'];
                                  bool existsInProducts =
                                      (await FirebaseFirestore.instance
                                              .collection('votations')
                                              .doc(postId)
                                              .get())
                                          .exists;

                                  if (existsInProducts) {
                                    validFavorites.add(favorite);
                                  }
                                }
                                return validFavorites;
                              }

                              return FutureBuilder(
                                future: filterFavorites(),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return Center(
                                      child: CircularProgressIndicator(),
                                    );
                                  }

                                  List<QueryDocumentSnapshot> validFavorites =
                                      snapshot.data
                                          as List<QueryDocumentSnapshot>;

                                  return Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 16),
                                    child: SizedBox(
                                      height: 450.h,
                                      child: GridView.builder(
                                        gridDelegate:
                                            SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: 3,
                                          mainAxisSpacing: 8.h,
                                          crossAxisSpacing: 8.h,
                                          childAspectRatio: 1.0,
                                        ),
                                        itemCount: validFavorites.length,
                                        itemBuilder: (context, index) {
                                          String postId =
                                              validFavorites[index]['postId'];

                                          return ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            child: InkWell(
                                              child: Image.network(
                                                validFavorites[index]
                                                    ['photoUrls'][0],
                                                fit: BoxFit.fill,
                                              ),
                                              onTap: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        SeePost(
                                                      postId: postId,
                                                    ),
                                                  ),
                                                );
                                              },
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ],
                      ),
                    ],
            ),
          ),
        ],
      ),
    );
  }
}
