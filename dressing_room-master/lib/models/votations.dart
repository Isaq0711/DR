import 'package:cloud_firestore/cloud_firestore.dart';

class Votation {
  final String uid;
  final String question;
  final String username;
  final votes;
  final String votationId;
  final DateTime datePublished;
  final List<VotationOption> options;
  final String profImage;

  const Votation({
    required this.uid,
    required this.question,
    required this.username,
    required this.votes,
    required this.votationId,
    required this.datePublished,
    required this.options,
    required this.profImage,
  });

  static Votation fromSnap(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map<String, dynamic>;

    return Votation(
      uid: snapshot["uid"],
      question: snapshot["question"],
      username: snapshot["username"],
      votes: snapshot["votes"],
      votationId: snapshot["votationId"],
      datePublished: snapshot["datePublished"].toDate(),
      options: List<VotationOption>.from(
          snapshot['options'].map((option) => VotationOption.fromMap(option))),
      profImage: snapshot['profImage'],
    );
  }

  Map<String, dynamic> toJson() => {
        "uid": uid,
        "question": question,
        "username": username,
        "votes": votes,
        "votationId": votationId,
        "datePublished": datePublished,
        "options": options.map((option) => option.toMap()).toList(),
        "profImage": profImage,
      };
}

class VotationOption {
  final String description;
  final String photoUrl;
  final List<dynamic>? pecasID;
  final List<dynamic>? pecasPhotoUrls;

  const VotationOption({
    required this.description,
    required this.photoUrl,
    required this.pecasID,
    required this.pecasPhotoUrls,
  });

  factory VotationOption.fromMap(Map<String, dynamic> map) {
    return VotationOption(
      description: map['description'],
      photoUrl: map['photoUrl'],
      pecasID: map['pecasID'],
      pecasPhotoUrls: map['pecasPhotoUrls'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'description': description,
      'photoUrl': photoUrl,
      'pecasID': pecasID,
      'pecasPhotoUrls': pecasPhotoUrls
    };
  }
}

class Votationpramadar {
  final String uid;
  final String question;
  final String username;
  final votes;
  final String votationId;
  final List<VotationOption> options;
  final String profImage;

  Votationpramadar({
    required this.uid,
    required this.question,
    required this.username,
    required this.votes,
    required this.votationId,
    required this.options,
    required this.profImage,
  });

  factory Votationpramadar.fromSnap(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map<String, dynamic>;

    return Votationpramadar(
      uid: snapshot["uid"],
      question: snapshot["question"],
      username: snapshot["username"],
      votes: snapshot["votes"],
      votationId: snapshot["votationId"],
      options: List<VotationOption>.from(
          (snapshot['options'] as List<dynamic>? ?? [])
              .map((option) => VotationOption.fromMap(option))),
      profImage: snapshot['profImage'],
    );
  }

  Map<String, dynamic> toJson() => {
        "uid": uid,
        "question": question,
        "username": username,
        "votes": votes,
        "votationId": votationId,
        "options": options.map((option) => option.toMap()).toList(),
        "profImage": profImage,
      };
}

class Postpramandar {
  final String description;
  final String uid;
  final String username;
  final double? grade;
  final String postId;
  final List<String>? pecasPhotoUrls;
  final List<String>? pecasIds;
  final List<String> photoUrls; // Lista de URLs de fotos
  final String profImage;
  final Map<String, double>
      votes; // Mapa que armazena quem votou e a respectiva nota

  Postpramandar({
    required this.description,
    required this.uid,
    required this.username,
    required this.grade,
    required this.postId,
    required this.photoUrls,
    required this.pecasPhotoUrls,
    required this.pecasIds,
    required this.profImage,
    required this.votes,
  });

  factory Postpramandar.fromSnap(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map<String, dynamic>;

    return Postpramandar(
      description: snapshot["description"],
      uid: snapshot["uid"],
      grade: snapshot["grade"],
      postId: snapshot["postId"],
      username: snapshot["username"],
      photoUrls: List<String>.from(snapshot['photoUrls'] ?? []),
      profImage: snapshot['profImage'],
      pecasIds: List<String>.from(snapshot['pecasIds'] ?? []),
      pecasPhotoUrls: List<String>.from(snapshot['pecasPhotoUrls'] ?? []),
      votes: Map<String, double>.from(snapshot['votes'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() => {
        "description": description,
        "uid": uid,
        "grade": grade,
        "username": username,
        "postId": postId,
        'photoUrls': photoUrls,
        'profImage': profImage,
        'pecasIds': pecasIds,
        'pecasPhotoUrls': pecasPhotoUrls,
        'votes': votes,
      };
}
