import 'package:cloud_firestore/cloud_firestore.dart';

class Store {
  final String storeId;
  final String storename;
  final String photoUrl;
  final String bio;

  final String fotodecapa;
  final List followers;
  final List following;
  final List patrocinados;
  final List adms;

  const Store(
      {required this.storename,
      required this.storeId,
      required this.photoUrl,
      required this.bio,
      required this.fotodecapa,
      required this.followers,
      required this.following,
      required this.patrocinados,
      required this.adms});

  static Store fromSnap(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map<String, dynamic>;

    return Store(
      storename: snapshot["storename"],
      storeId: snapshot["storeId"],
      fotodecapa: snapshot["fotodecapa"],
      photoUrl: snapshot["photoUrl"],
      bio: snapshot["bio"],
      followers: snapshot["followers"],
      following: snapshot["following"],
      patrocinados: snapshot["patrocinados"],
      adms: snapshot["adms"],
    );
  }

  Map<String, dynamic> toJson() => {
        "storename": storename,
        "storeId": storeId,
        "fotodecapa": fotodecapa,
        "photoUrl": photoUrl,
        "bio": bio,
        "followers": followers,
        "following": following,
        "patrocinados": patrocinados,
        "adms": adms,
      };
}
