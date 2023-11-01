import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  final String description;
  final String uid;
  final String username;
  final likes;
  final dislikes;
  final String postId;
  final DateTime datePublished;
  final List<String> photoUrls; // Lista de URLs de fotos
  final String profImage;

  const Post({
    required this.description,
    required this.uid,
    required this.username,
    required this.likes,
    required this.dislikes,
    required this.postId,
    required this.datePublished,
    required this.photoUrls, // Atualizado para uma lista de URLs
    required this.profImage,
  });

  static Post fromSnap(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map<String, dynamic>;

    return Post(
      description: snapshot["description"],
      uid: snapshot["uid"],
      likes: snapshot["likes"],
      dislikes: snapshot["dislikes"],
      postId: snapshot["postId"],
      datePublished: snapshot["datePublished"],
      username: snapshot["username"],
      photoUrls: snapshot['photoUrls'],
      profImage: snapshot['profImage']
    );
  }

   Map<String, dynamic> toJson() => {
        "description": description,
        "uid": uid,
        "likes": likes,
        "dislikes": dislikes,
        "username": username,
        "postId": postId,
        "datePublished": datePublished,
        'photoUrls': photoUrls,
        'profImage': profImage
      };
}
