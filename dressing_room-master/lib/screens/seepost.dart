import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dressing_room/widgets/cloth_card.dart';
import 'package:dressing_room/providers/bottton_nav_controller.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:dressing_room/widgets/post_card.dart';
import 'package:dressing_room/utils/colors.dart';
import 'package:dressing_room/screens/votation_card.dart';
import 'package:dressing_room/screens/product_card.dart';

class SeePost extends StatefulWidget {
  final String postId;
  final bool isTagclicked;

  const SeePost({Key? key, required this.postId, required this.isTagclicked})
      : super(key: key);

  @override
  _SeePostState createState() => _SeePostState();
}

class _SeePostState extends State<SeePost> {
  late Stream<DocumentSnapshot<Map<String, dynamic>>> _postStream;
  late Stream<DocumentSnapshot<Map<String, dynamic>>> _anonymousPostStream;
  late Stream<QuerySnapshot<Map<String, dynamic>>> _votationsStream;
  late Stream<QuerySnapshot<Map<String, dynamic>>> _productStream;
  late Stream<QuerySnapshot<Map<String, dynamic>>> _clothStream;

  @override
  void initState() {
    super.initState();
    _initializeFirebase();
    _postStream = _subscribeToPost();
    _anonymousPostStream = _subscribeToAnonymousPost();
    _votationsStream = _subscribeToVotations();
    _productStream = _subscribeToProducts();
    _clothStream = _subscribeToCloth();
    context.read<ZoomProvider>().setZoom(false);
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

  Stream<QuerySnapshot<Map<String, dynamic>>> _subscribeToCloth() {
    return FirebaseFirestore.instance
        .collection('clothes')
        .where('clothId', isEqualTo: widget.postId)
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
    bool isZooming = context.watch<ZoomProvider>().scroll;
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
      body: ListView(
          physics: isZooming ? const NeverScrollableScrollPhysics() : null,
          children: <Widget>[
            Column(
              children: [
                StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                  stream: _postStream,
                  builder: (context, snapshot) {
                    if (!snapshot.hasData || !snapshot.data!.exists) {
                      return Container();
                    }
                    final post = snapshot.data!.data();
                    return PostCard(
                        snap: post, isTagCliked: widget.isTagclicked);
                  },
                ),
                StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: _productStream,
                  builder: (context, snapshot) {
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return Container(); // handle the case where data does not exist
                    }
                    final products = snapshot.data!.docs;
                    return ProductCard(snap: products[0].data());
                  },
                ),
                StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                  stream: _anonymousPostStream,
                  builder: (context, snapshot) {
                    if (!snapshot.hasData || !snapshot.data!.exists) {
                      return Container();
                    }
                    final anonymousPost = snapshot.data!.data();
                    return PostCard(
                        snap: anonymousPost, isTagCliked: widget.isTagclicked);
                  },
                ),
                StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: _votationsStream,
                  builder: (context, snapshot) {
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return Container(); // handle the case where data does not exist
                    }
                    final votations = snapshot.data!.docs;

                    return VotationCard(snap: votations[0].data());
                  },
                ),
                StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: _clothStream,
                  builder: (context, snapshot) {
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return Container(); // handle the case where data does not exist
                    }
                    final cloth = snapshot.data!.docs;
                    return ClothCard(snap: cloth[0].data());
                  },
                ),
              ],
            ),
          ]),
    );
  }
}
