import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:dressing_room/widgets/post_card.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:dressing_room/utils/colors.dart';
import 'package:dressing_room/screens/votation_card.dart';
import 'package:dressing_room/screens/product_card.dart';

class SeePost extends StatefulWidget {
  final String postId;

  const SeePost({Key? key, required this.postId}) : super(key: key);

  @override
  _SeePostState createState() => _SeePostState();
}

class _SeePostState extends State<SeePost> {
  late Stream<DocumentSnapshot<Map<String, dynamic>>> _postStream;
  late Stream<DocumentSnapshot<Map<String, dynamic>>> _anonymousPostStream;
  late Stream<QuerySnapshot<Map<String, dynamic>>> _votationsStream;
  late Stream<QuerySnapshot<Map<String, dynamic>>> _productStream;

  @override
  void initState() {
    super.initState();
    _initializeFirebase();
    _postStream = _subscribeToPost();
    _anonymousPostStream = _subscribeToAnonymousPost();
    _votationsStream = _subscribeToVotations();
    _productStream = _subscribeToProducts();
  }

  void _initializeFirebase() async {
    await Firebase.initializeApp();
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> _subscribeToPost() {
    return FirebaseFirestore.instance
        .collection('posts')
        .doc(widget.postId)
        .snapshots();
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> _subscribeToAnonymousPost() {
    return FirebaseFirestore.instance
        .collection('anonymous_posts')
        .doc(widget.postId)
        .snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> _subscribeToVotations() {
    return FirebaseFirestore.instance
        .collection('votations')
        .where('votationId', isEqualTo: widget.postId)
        .snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> _subscribeToProducts() {
    return FirebaseFirestore.instance
        .collection('products')
        .where('productId', isEqualTo: widget.postId)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(
            Icons.arrow_back_ios,
            color: AppTheme.nearlyBlack,
          ),
        ),
        backgroundColor: Colors.transparent,
      ),
      body: ListView(children: <Widget>[
        Column(
          children: [
            StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
              stream: _postStream,
              builder: (context, snapshot) {
                if (!snapshot.hasData || !snapshot.data!.exists) {
                  return Container();
                }
                final post = snapshot.data!.data();
                return PostCard(snap: post);
              },
            ),
            StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: _productStream,
              builder: (context, snapshot) {
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Container(); // handle the case where data does not exist
                }
                final products = snapshot.data!.docs;
                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    return ProductCard(snap: products[index].data());
                  },
                );
              },
            ),
            StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
              stream: _anonymousPostStream,
              builder: (context, snapshot) {
                if (!snapshot.hasData || !snapshot.data!.exists) {
                  return Container();
                }
                final anonymousPost = snapshot.data!.data();
                return PostCard(snap: anonymousPost);
              },
            ),
            StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: _votationsStream,
              builder: (context, snapshot) {
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Container(); // handle the case where data does not exist
                }
                final votations = snapshot.data!.docs;
                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: votations.length,
                  itemBuilder: (context, index) {
                    return VotationCard(snap: votations[index].data());
                  },
                );
              },
            ),
          ],
        ),
      ]),
    );
  }
}
