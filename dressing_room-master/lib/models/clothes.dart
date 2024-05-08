import 'package:cloud_firestore/cloud_firestore.dart';

class Cloth {
  final String description;
  final String uid;
  final String clothId;
  final DateTime dateAdded;
  final String? category;
  final bool isPublic;
  final String photoUrl;
  final String? barCode;
  final List<String>? marcas;
  final List<String>? tecido;

  const Cloth({
    required this.description,
    required this.uid,
    required this.clothId,
    required this.dateAdded,
    required this.category,
    required this.isPublic,
    required this.photoUrl,
    required this.barCode,
    this.marcas,
    this.tecido,
  });

  factory Cloth.fromSnap(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map<String, dynamic>;

    return Cloth(
      description: snapshot["description"] ?? '',
      uid: snapshot["uid"] ?? '',
      clothId: snapshot["clothId"] ?? '',
      dateAdded: snapshot["dateAdded"] != null
          ? (snapshot["dateAdded"] as Timestamp).toDate()
          : DateTime.now(),
      category: snapshot["category"] ?? '',
      isPublic: snapshot["isPublic"] ?? false,
      photoUrl: snapshot['photoUrl'] ?? '',
      barCode: snapshot["barCode"] ?? '',
      marcas: snapshot["marcas"] as List<String>?,
      tecido: snapshot["tecido"] as List<String>?,
    );
  }

  Map<String, dynamic> toJson() => {
        "description": description,
        "uid": uid,
        "clothId": clothId,
        "dateAdded": dateAdded,
        "photoUrl": photoUrl,
        "category": category,
        "isPublic": isPublic,
        "barCode": barCode,
        "marcas": marcas,
        "tecido": tecido,
      };
}
