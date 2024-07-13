import 'package:cloud_firestore/cloud_firestore.dart';

class Cloth {
  final String description;
  final String uid;
  final String clothId;
  final DateTime dateAdded;
  final String? category;
  final String? type;
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
    required this.type,
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
      type: snapshot["type"] ?? '',
      isPublic: snapshot["isPublic"] ?? false,
      photoUrl: snapshot['photoUrl'] ?? '',
      barCode: snapshot["barCode"] ?? '',
      marcas: (snapshot["marcas"] as List<dynamic>?)?.cast<String>(),
      tecido: (snapshot["tecido"] as List<dynamic>?)?.cast<String>(),
    );
  }

  Map<String, dynamic> toJson() => {
        "description": description,
        "uid": uid,
        "clothId": clothId,
        "dateAdded": dateAdded,
        "photoUrl": photoUrl,
        "type": type,
        "category": category,
        "isPublic": isPublic,
        "barCode": barCode,
        "marcas": marcas,
        "tecido": tecido,
      };
}

class ClothPraMandar {
  final String description;
  final String uid;
  final String clothId;
  final DateTime dateAdded;
  final String? category;
  final String? type;
  final bool isPublic;
  final String photoUrl;
  final String? barCode;
  final List<String>? marcas;
  final List<String>? tecido;

  const ClothPraMandar({
    required this.description,
    required this.uid,
    required this.clothId,
    required this.dateAdded,
    required this.category,
    required this.type,
    required this.isPublic,
    required this.photoUrl,
    required this.barCode,
    this.marcas,
    this.tecido,
  });

  factory ClothPraMandar.fromSnap(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map<String, dynamic>;

    return ClothPraMandar(
      description: snapshot["description"] ?? '',
      uid: snapshot["uid"] ?? '',
      clothId: snapshot["clothId"] ?? '',
      dateAdded: snapshot["dateAdded"] != null
          ? (snapshot["dateAdded"] as Timestamp).toDate()
          : DateTime.now(),
      category: snapshot["category"] ?? '',
      type: snapshot["type"] ?? '',
      isPublic: snapshot["isPublic"] ?? false,
      photoUrl: snapshot['photoUrl'] ?? '',
      barCode: snapshot["barCode"] ?? '',
      marcas: (snapshot["marcas"] as List<dynamic>?)?.cast<String>(),
      tecido: (snapshot["tecido"] as List<dynamic>?)?.cast<String>(),
    );
  }

  Map<String, dynamic> toJson() => {
        "description": description,
        "uid": uid,
        "clothId": clothId,
        "dateAdded": dateAdded.toIso8601String(),
        "photoUrl": photoUrl,
        "type": type,
        "category": category,
        "isPublic": isPublic,
        "barCode": barCode,
        "marcas": marcas,
        "tecido": tecido,
      };
}
