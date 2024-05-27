import 'package:cloud_firestore/cloud_firestore.dart';

class Votation {
  final String uid;
  final String username;
  final votes;

  final String votationId;
  final DateTime datePublished;
  final List<VotationOption> options;
  final String profImage;

  const Votation({
    required this.uid,
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
  final List<String>? pecasID;
  final List<String>? pecasPhotoUrls;

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
