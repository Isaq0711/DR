import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'search_screen.dart';
import 'package:dressing_room/widgets/votation_card.dart';
import 'package:dressing_room/utils/colors.dart';
import 'package:dressing_room/utils/global_variable.dart';
import 'package:dressing_room/widgets/post_card.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({Key? key}) : super(key: key);

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: width > webScreenSize ? AppTheme.cinza : AppTheme.cinza,
      appBar: width > webScreenSize
          ? null
          : AppBar(
              backgroundColor: AppTheme.vinho,
              centerTitle: false,
              title: const Text(
                "DressRoom",
                style: AppTheme.headlinewhite,
              ),
              actions: [
                IconButton(
                  icon: const Icon(
                    Icons.search,
                    color: AppTheme.nearlyWhite,
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SearchScreen()),
                    );
                  },
                ),
              ],
            ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance.collection('anonymous_posts').snapshots(),
        builder: (context, anonymousPostsSnapshot) {
          if (anonymousPostsSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          List<DocumentSnapshot<Map<String, dynamic>>> anonymousPosts = anonymousPostsSnapshot.data!.docs;

          return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: FirebaseFirestore.instance.collection('posts').snapshots(),
            builder: (context, postsSnapshot) {
              if (postsSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              List<DocumentSnapshot<Map<String, dynamic>>> posts = postsSnapshot.data!.docs;

              return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: FirebaseFirestore.instance.collection('votations').snapshots(),
                builder: (context, votationsSnapshot) {
                  if (votationsSnapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  List<DocumentSnapshot<Map<String, dynamic>>> votations = votationsSnapshot.data!.docs;

                  List<DocumentSnapshot<Map<String, dynamic>>> allDocuments = [...anonymousPosts, ...posts, ...votations];
                  allDocuments.sort((a, b) => (b.data()!['datePublished'] as Timestamp).compareTo(a.data()!['datePublished'] as Timestamp));

                  return ListView.builder(
                    itemCount: allDocuments.length,
                    itemBuilder: (ctx, index) {
                      final documentData = allDocuments[index].data();

                      if (documentData!.containsKey('options')) {
                        // It's a VotationCard
                        return Container(
                          margin: EdgeInsets.symmetric(
                            horizontal: width > webScreenSize ? width * 0.3 : 2.7,
                            vertical: width > webScreenSize ? 15 : 2.7,
                          ),
                          child: VotationCard(
                            snap: documentData,
                          ),
                        );
                      } else {
                        // It's a PostCard
                        return Container(
                          margin: EdgeInsets.symmetric(
                            horizontal: width > webScreenSize ? width * 0.3 : 2.7,
                            vertical: width > webScreenSize ? 15 : 2.7,
                          ),
                          child: PostCard(
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
      ),
    );
  }
}
