import 'package:cloud_firestore/cloud_firestore.dart';

class Cart {
  final String description;
  final String uid;
  final String username;
  final int vendas;
  final String productId;
  final DateTime dateAdded;
  final String category;
  final String variationdescription;
  final String size;
  final String photoUrl;
  final double price;
  final bool promotions;
  final int qntspedidos;

  const Cart({
    required this.description,
    required this.uid,
    required this.username,
    required this.vendas,
    required this.productId,
    required this.dateAdded,
    required this.category,
    required this.variationdescription,
    required this.size,
    required this.photoUrl,
    required this.price,
    required this.promotions,
    required this.qntspedidos,
  });

  factory Cart.fromSnap(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map<String, dynamic>;

    return Cart(
      description: snapshot["description"] ?? '',
      uid: snapshot["uid"] ?? '',
      vendas: snapshot["vendas"] ?? 0,
      productId: snapshot["productId"] ?? '',
      dateAdded: snapshot["dateAdded"] != null
          ? (snapshot["dateAdded"] as Timestamp).toDate()
          : DateTime.now(),
      username: snapshot["username"] ?? '',
      category: snapshot["category"] ?? '',
      photoUrl: snapshot['photoUrl'] ?? '',
      variationdescription: snapshot["variationdescription"] ?? '',
      size: snapshot["size"] ?? '',
      price: snapshot["price"] ?? 0,
      promotions: snapshot['promotions'] ?? false,
      qntspedidos: snapshot['qntspedidos'] ?? 1,
    );
  }

  Map<String, dynamic> toJson() => {
        "description": description,
        "uid": uid,
        "vendas": vendas,
        "username": username,
        "productId": productId,
        "dateAdded": dateAdded,
        "photoUrl": photoUrl,
        "variationdescription": variationdescription,
        "price": price,
        "size": size,
        "category": category,
        "promotions": promotions,
        "qntspedidos": qntspedidos
      };
}
