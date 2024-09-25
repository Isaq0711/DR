import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:typed_data';

class Product {
  final String description;
  final String uid;
  final String username;
  final int vendas;
  final String productId;
  final DateTime datePublished;
  final List<VariationInfo> variations;
  final String category;
  final String type;
  final String profImage;
  final bool vitrine;
  final bool promotions;

  const Product({
    required this.description,
    required this.uid,
    required this.username,
    required this.vendas,
    required this.productId,
    required this.datePublished,
    required this.category,
    required this.type,
    required this.variations,
    required this.profImage,
    required this.vitrine,
    required this.promotions,
  });

  factory Product.fromSnap(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map<String, dynamic>;

    List<dynamic> variationsData = snapshot['variations'] ?? [];
    List<VariationInfo> variationsList = variationsData
        .map((variation) => VariationInfo.fromMap(variation))
        .toList();

    return Product(
      description: snapshot["description"] ?? '',
      uid: snapshot["uid"] ?? '',
      vendas: snapshot["vendas"] ?? 0,
      productId: snapshot["productId"] ?? '',
      datePublished: snapshot["datePublished"] != null
          ? (snapshot["datePublished"] as Timestamp).toDate()
          : DateTime.now(),
      username: snapshot["username"] ?? '',
      category: snapshot["category"] ?? '',
      type: snapshot["type"] ?? '',
      profImage: snapshot['profImage'] ?? '',
      variations: variationsList,
      vitrine: snapshot['vitrine'] ?? false,
      promotions: snapshot['promotions'] ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        "description": description,
        "uid": uid,
        "vendas": vendas,
        "username": username,
        "productId": productId,
        "datePublished": datePublished,
        'profImage': profImage,
        'variations': variations.map((variation) => variation.toMap()).toList(),
        "category": category,
        "type": type,
        'vitrine': vitrine,
        'promotions': promotions,
      };
}

class VariationInfo {
  String variationdescription;
  int itemCount;
  List<String> sizesAvailable;
  List<Uint8List> photos;
  List<String> photoUrls;

  double? price;

  VariationInfo({
    required this.variationdescription,
    required this.itemCount,
    required this.sizesAvailable,
    required this.photos,
    required this.photoUrls,
    required this.price,
  });

  factory VariationInfo.fromMap(Map<String, dynamic> map) {
    return VariationInfo(
      variationdescription: map['variationdescription'] ?? '',
      itemCount: map['itemCount'] ?? 0,
      sizesAvailable: List<String>.from(map['sizesAvailable'] ?? []),
      photos: (map['photos'] as List<dynamic>?)
              ?.map((photo) => photo as Uint8List)
              .toList() ??
          [],
      photoUrls: (map['photoUrls'] as List<dynamic>?)
              ?.map((url) => url as String)
              .toList() ??
          [],
      price: map['price'] != null ? map['price'].toDouble() : 0.0,
      // Adicione o mapeamento de photoUrls
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'variationdescription': variationdescription,
      'itemCount': itemCount,
      'sizesAvailable': sizesAvailable,
      'photos': photos,
      'photoUrls': photoUrls,
      'price': price,
    };
  }
}

Map<String, List<String>> categorySizes = {
  'Pernas': ['34', '36', '38', '40', '42', '44'],
  'Pés': ['34', '35', '36', '37', '38', '39', '40', '41', '42'],
  'Tronco': ['PP', 'P', 'M', 'G', 'GG', 'XGG'],
  'Body (corpo inteiro)': ['PP', 'P', 'M', 'G', 'GG', 'XGG'],
  'Top (cabeça)': ['P', 'M', 'G'],
  "Mão": [],
  "Pulso": [],
  "Pescoço": [],
  "Cintura": ['34', '36', '38', '40', '42', '44'],
  'Rosto': [],
};
