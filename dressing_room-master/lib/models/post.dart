import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  final String description;
  final String uid;
  final String username;
  final double
      grade; // Alterado para double para representar a nota em estrelas
  final String postId;
  final DateTime datePublished;
  final List<String>? pecasPhotoUrls;
  final List<String>? pecasIds;
  final List<String> photoUrls; // Lista de URLs de fotos
  final String profImage;
  final Map<String, double>
      votes; // Mapa que armazena quem votou e a respectiva nota

  const Post({
    required this.description,
    required this.uid,
    required this.username,
    required this.grade,
    required this.postId,
    required this.datePublished,
    required this.photoUrls,
    required this.pecasPhotoUrls,
    required this.pecasIds,
    required this.profImage,
    required this.votes,
  });

  static Post fromSnap(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map<String, dynamic>;

    return Post(
      description: snapshot["description"],
      uid: snapshot["uid"],
      grade: snapshot["grade"],
      postId: snapshot["postId"],
      datePublished: snapshot["datePublished"].toDate(),
      username: snapshot["username"],
      photoUrls: List<String>.from(snapshot['photoUrls']),
      profImage: snapshot['profImage'],
      pecasIds: List<String>.from(snapshot['pecasIds']),
      pecasPhotoUrls: List<String>.from(snapshot['pecasPhotoUrls']),
      votes: Map<String, double>.from(snapshot['votes'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() => {
        "description": description,
        "uid": uid,
        "grade": grade,
        "username": username,
        "postId": postId,
        "datePublished": datePublished,
        'photoUrls': photoUrls,
        'profImage': profImage,
        'pecasIds': pecasIds,
        'pecasPhotoUrls': pecasPhotoUrls,
        'votes': votes,
      };
}
