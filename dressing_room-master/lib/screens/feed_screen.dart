import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:dressing_room/resources/auth_methods.dart';
import 'package:dressing_room/resources/firestore_methods.dart';
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
  late Stream<QuerySnapshot<Map<String, dynamic>>> _anonymousPostsStream;
  late Stream<QuerySnapshot<Map<String, dynamic>>> _postsStream;
  late Stream<QuerySnapshot<Map<String, dynamic>>> _votationsStream;
  bool isLoading = false;

   late String fotoUrl = '';

  Future<void> getData() async {
    setState(() {
      isLoading = true;
    });
    try {
      var doc = await FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid).get();
      fotoUrl = doc.get('photoUrl');
      setState(() {
        isLoading = true;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    getData();
    _anonymousPostsStream = FirebaseFirestore.instance.collection('anonymous_posts').snapshots();
    _postsStream = FirebaseFirestore.instance.collection('posts').snapshots();
    _votationsStream = FirebaseFirestore.instance.collection('votations').snapshots();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: width > webScreenSize ? AppTheme.cinza : AppTheme.cinza,
      appBar: width > webScreenSize
          ? null
          :AppBar(
  backgroundColor: AppTheme.vinho,
  title: Row(
    children: [
      CircleAvatar(
        backgroundColor: Colors.grey,
        backgroundImage: NetworkImage(fotoUrl),
        radius: 20,
      ),
      SizedBox(width: 70), // Espaço entre o CircleAvatar e o título
      Text(
        "DressRoom",
        style: AppTheme.headlinewhite,
      ),
    ],
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
        stream: _anonymousPostsStream,
        builder: (context, anonymousPostsSnapshot) {
          if (anonymousPostsSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          List<DocumentSnapshot<Map<String, dynamic>>> anonymousPosts = anonymousPostsSnapshot.data!.docs;

          return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: _postsStream,
            builder: (context, postsSnapshot) {
              if (postsSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              List<DocumentSnapshot<Map<String, dynamic>>> posts = postsSnapshot.data!.docs;

              return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: _votationsStream,
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
