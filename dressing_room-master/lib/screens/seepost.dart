import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dressing_room/widgets/post_card.dart';
import 'package:dressing_room/utils/colors.dart';
import 'package:dressing_room/widgets/votation_card.dart';

class SeePost extends StatefulWidget {
  final String postId;

  const SeePost({Key? key, required this.postId}) : super(key: key);

  @override
  _SeePostState createState() => _SeePostState();
}

class _SeePostState extends State<SeePost> {
  late Future<DocumentSnapshot<Map<String, dynamic>>> _postFuture;
  late Future<DocumentSnapshot<Map<String, dynamic>>> _anonymousPostFuture;
  late Future<QuerySnapshot<Map<String, dynamic>>> _votationsFuture;

  @override
  void initState() {
    super.initState();
    _initializeFirebase();
    _postFuture = _fetchPost();
    _anonymousPostFuture = _fetchAnonymousPost();
    _votationsFuture = _fetchVotations();
  }

  void _initializeFirebase() async {
    await Firebase.initializeApp();
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> _fetchPost() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('posts')
        .doc(widget.postId)
        .get();
    return snapshot;
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> _fetchAnonymousPost() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('anonymous_posts')
        .doc(widget.postId)
        .get();
    return snapshot;
  }

  Future<QuerySnapshot<Map<String, dynamic>>> _fetchVotations() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('votations')
        .where('votationId', isEqualTo: widget.postId)
        .get();
    return snapshot;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'One more look',
          style: AppTheme.subheadlinewhite,
        ),
        backgroundColor: AppTheme.vinho,
      ),
      body: Center(
        child: Column(
          children: [
            FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
              future: _postFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                }
                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }
                if (!snapshot.hasData || !snapshot.data!.exists) {
                  return Text('Post not found');
                }
                final post = snapshot.data!.data();
                return PostCard(snap: post);
              },
            ),
            FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
              future: _anonymousPostFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                }
                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }
                if (!snapshot.hasData || !snapshot.data!.exists) {
                  return Container();
                }
                final anonymousPost = snapshot.data!.data();
                return PostCard(snap: anonymousPost);
              },
            ),
            FutureBuilder<QuerySnapshot<Map<String, dynamic>>>(
              future: _votationsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                }
                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Text('Votation not found');
                }
                final votations = snapshot.data!.docs.map((doc) => doc.data()).toList();
                return Column(
                  children: votations.map((votation) => VotationCard(snap: votation)).toList(),
                ); 
              },
            ),
          ],
        ),
      ),
    );
  }
}
