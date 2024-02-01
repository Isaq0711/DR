import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dressing_room/providers/bottton_nav_controller.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:dressing_room/screens/outfit_screen.dart';
import 'package:dressing_room/screens/store_screen.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/rendering.dart';
import 'search_screen.dart';
import 'package:dressing_room/2d_cards/new_votation_card.dart';
import 'package:dressing_room/utils/colors.dart';
import 'package:dressing_room/2d_cards/new_post_card.dart';

import 'package:dressing_room/2d_cards/product_card.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({Key? key}) : super(key: key);

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  late Stream<QuerySnapshot<Map<String, dynamic>>> _anonymousPostsStream;
  late Stream<QuerySnapshot<Map<String, dynamic>>> _postsStream;
  late Stream<QuerySnapshot<Map<String, dynamic>>> _votationsStream;
  late Stream<QuerySnapshot<Map<String, dynamic>>> _productsStream;
  bool isLoading = false;
  bool isShop = false;
  late ScrollController scrollController;

  late String fotoUrl = '';

  @override
  void initState() {
    super.initState();
    scrollController = ScrollController();

    scrollController.addListener(() {
      final bool isScrollingUp =
          scrollController.position.userScrollDirection ==
              ScrollDirection.reverse;

      if (isScrollingUp) {
        context.read<BottonNavController>().setBottomVisible(false);
      } else {
        context.read<BottonNavController>().setBottomVisible(true);
      }
    });

    _anonymousPostsStream =
        FirebaseFirestore.instance.collection('anonymous_posts').snapshots();
    _postsStream = FirebaseFirestore.instance.collection('posts').snapshots();
    _votationsStream =
        FirebaseFirestore.instance.collection('votations').snapshots();
    _productsStream =
        FirebaseFirestore.instance.collection('products').snapshots();
  }

  @override
  void dispose() {
    super.dispose();
    scrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    bool isBottomVisible = context.watch<BottonNavController>().isBottonVisible;

    return Scaffold(
      backgroundColor: AppTheme.cinza,
      appBar: AppBar(
        toolbarHeight: 60.h,
        elevation: 0.0,
        centerTitle: false,
        backgroundColor: Colors.transparent,
        title: Padding(
          padding: EdgeInsets.only(left: 8.w),
          child: Text(
            "DressRoom",
            style: AppTheme.headlinevinho.copyWith(
              shadows: [
                Shadow(
                  blurRadius: 4.0,
                  color: Colors.black, // Cor da sombra
                ),
              ],
            ),
          ),
        ),
        actions: [
          Padding(
              padding: EdgeInsets.symmetric(horizontal: 26.w),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(
                      shadows: <Shadow>[
                        Shadow(color: AppTheme.vinho, blurRadius: 2.0)
                      ],
                      CupertinoIcons.search,
                      color: AppTheme.vinho,
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => SearchScreen()),
                      );
                    },
                  ),
                  IconButton(
                    icon: Icon(
                      shadows: <Shadow>[
                        Shadow(color: AppTheme.vinho, blurRadius: 3.0)
                      ],
                      CupertinoIcons.info_circle,
                      color: AppTheme.vinho,
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => StoreScreen(
                            uid: FirebaseAuth.instance.currentUser!.uid,
                          ),
                        ),
                      );
                    },
                  ),
                  isShop
                      ? IconButton(
                          icon: Icon(
                            shadows: <Shadow>[
                              Shadow(
                                  color: AppTheme.nearlyBlack, blurRadius: 5.0)
                            ],
                            CupertinoIcons.shopping_cart,
                            color: AppTheme.vinho,
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => OutfitScreen(
                                        uid: FirebaseAuth
                                            .instance.currentUser!.uid,
                                      )),
                            );
                          },
                        )
                      : Container()
                ],
              ))
        ],
      ),
      floatingActionButton: Visibility(
          visible: isBottomVisible,
          child: Container(
            margin: EdgeInsets.only(
              bottom: 3.h,
            ),
            child: FloatingActionButton(
              onPressed: () {
                setState(() {
                  isShop = !isShop;
                });
              },
              backgroundColor: AppTheme.vinho,
              elevation: 2.0,
              child: isShop
                  ? Icon(
                      CupertinoIcons.person_3_fill,
                      color: AppTheme.cinza,
                    )
                  : Icon(
                      CupertinoIcons.tag_fill,
                      color: AppTheme.cinza,
                    ),
            ),
          )),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: _anonymousPostsStream,
        builder: (context, anonymousPostsSnapshot) {
          if (anonymousPostsSnapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          List<DocumentSnapshot<Map<String, dynamic>>> anonymousPosts =
              anonymousPostsSnapshot.data!.docs;

          return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: _postsStream,
            builder: (context, postsSnapshot) {
              if (postsSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              List<DocumentSnapshot<Map<String, dynamic>>> posts =
                  postsSnapshot.data!.docs;

              return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: _votationsStream,
                builder: (context, votationsSnapshot) {
                  if (votationsSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  List<DocumentSnapshot<Map<String, dynamic>>> votations =
                      votationsSnapshot.data!.docs;

                  return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                    stream: _productsStream,
                    builder: (context, productsSnapshot) {
                      if (productsSnapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }

                      List<DocumentSnapshot<Map<String, dynamic>>> products =
                          productsSnapshot.data!.docs;

                      List<DocumentSnapshot<Map<String, dynamic>>>
                          allDocuments = [];

                      if (isShop) {
                        allDocuments = [
                          ...products,
                        ];
                      } else {
                        allDocuments = [
                          ...anonymousPosts,
                          ...posts,
                          ...votations,
                        ];
                      }

                      allDocuments.sort((a, b) => (b.data()!['datePublished']
                              as Timestamp)
                          .compareTo(a.data()!['datePublished'] as Timestamp));

                      return ListView.builder(
                        controller: scrollController,
                        itemCount: allDocuments.length,
                        itemBuilder: (ctx, index) {
                          final documentData = allDocuments[index].data();

                          if (documentData!.containsKey('options')) {
                            return Container(
                              margin: EdgeInsets.symmetric(
                                horizontal: 17.w,
                                vertical: 5.h,
                              ),
                              child: NewVotationCard(
                                snap: documentData,
                              ),
                            );
                          } else if (documentData.containsKey('category')) {
                            return Container(
                              margin: EdgeInsets.symmetric(
                                horizontal: 17.w,
                                vertical: 5.h,
                              ),
                              child: ProductCard(
                                snap: documentData,
                              ),
                            );
                          } else {
                            return Container(
                              margin: EdgeInsets.symmetric(
                                horizontal: 17.w,
                                vertical: 5.h,
                              ),
                              child: NewPostCard(
                                snap: documentData,
                              ),
                            );
                          }
                        },
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
