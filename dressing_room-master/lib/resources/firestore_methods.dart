import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dressing_room/models/post.dart';
import 'package:dressing_room/models/products.dart';
import 'package:dressing_room/models/votations.dart';
import 'package:dressing_room/resources/storage_methods.dart';
import 'package:uuid/uuid.dart';
import 'package:dressing_room/models/cart.dart';

class FireStoreMethods {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Future<String> uploadPost(
    String description,
    List<Uint8List> files,
    String uid,
    String username,
    String profImage,
    double grade,
  ) async {
    String res = "Some error occurred";
    try {
      List<String> photoUrls = [];

      for (Uint8List file in files) {
        String photoUrl =
            await StorageMethods().uploadImageToStorage('posts', file, true);
        photoUrls.add(photoUrl);
      }

      String postId = const Uuid().v1();
      Post post = Post(
        description: description,
        uid: uid,
        username: username,
        grade: 0.0,
        postId: postId,
        datePublished: DateTime.now(),
        photoUrls: photoUrls,
        profImage: profImage,
        votes: {}, // Inicializa o mapa de votos vazio
      );

      _firestore.collection('posts').doc(postId).set(post.toJson());
      res = "success";
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  Future<String> uploadAnonymousPost(
    String description,
    List<Uint8List> files,
    String uid,
  ) async {
    String res = "Some error occurred";
    try {
      List<String> photoUrls = [];

      for (Uint8List file in files) {
        String photoUrl = await StorageMethods()
            .uploadImageToStorage('anonymousposts', file, true);
        photoUrls.add(photoUrl); // Adiciona a URL da foto à lista
      }

      String postId = const Uuid().v1();

      Post post = Post(
        description: description,
        uid: uid,
        username: "Anonymous User",
        grade: 0.0,
        postId: postId,
        datePublished: DateTime.now(),
        photoUrls: photoUrls,
        profImage: "generic_photo_url",
        votes: {},
      );

      await FirebaseFirestore.instance
          .collection('anonymous_posts')
          .doc(postId)
          .set(post.toJson());
      res = "success";
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  Future<String> uploadVotation(
    List<Map<String, dynamic>> votationOptions,
    List<Uint8List> photoFiles,
    String uid,
    String username,
    String profImage,
  ) async {
    String res = "Some error occurred";
    try {
      List<VotationOption> options = [];

      for (int i = 0; i < votationOptions.length; i++) {
        Uint8List file = photoFiles[i];
        Map<String, dynamic> optionData = votationOptions[i];

        String photoUrl = await StorageMethods()
            .uploadImageToStorage('votations', file, true);
        VotationOption option = VotationOption(
          description: optionData['description'],
          photoUrl: photoUrl,
        );

        options.add(option);
      }

      String votationId = const Uuid().v1();
      Votation votation = Votation(
        uid: uid,
        username: username,
        votes: [],
        votationId: votationId,
        datePublished: DateTime.now(),
        options: options,
        profImage: profImage,
      );

      _firestore.collection('votations').doc(votationId).set(votation.toJson());
      res = "success";
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  Future<String> uploadtoCart(
    String description,
    String uid,
    String username,
    String productId,
    String category,
    String variationdescription,
    String size,
    String photoUrl,
    double price,
  ) async {
    String res = "Some error occurred";
    try {
      Cart product = Cart(
        description: description,
        uid: uid,
        username: username,
        vendas: 0,
        productId: productId,
        dateAdded: DateTime.now(),
        category: category,
        variationdescription: variationdescription,
        size: size,
        photoUrl: photoUrl,
        price: price,
        promotions: false,
        qntspedidos: 1, // Set default quantity to 1 when adding a new product
      );

      DocumentSnapshot productsnapshot =
          await _firestore.collection('cart').doc(uid).get();

      if (productsnapshot.exists && productsnapshot.data() != null) {
        Map<String, dynamic> data =
            productsnapshot.data() as Map<String, dynamic>;

        if (data.containsKey(productId)) {
          int quantity = data[productId]['qntspedidos'] + 1;
          await _firestore.collection('cart').doc(uid).update({
            '$productId.qntspedidos': quantity,
          });
        } else {
          // Initialize quantity if the product doesn't exist in the cart
          int quantity = 1;
          await _firestore.collection('cart').doc(uid).update({
            '$productId': product.toJson(),
          });
        }
      } else {
        // Cart doesn't exist for the user, create a new cart
        await _firestore.collection('cart').doc(uid).set({
          '$productId': product.toJson(),
        });
      }
      res = "success";
    } catch (err) {
      res = "Error: $err"; // Update error message for better understanding
      // Log the error for debugging purposes
      print("Error occurred: $err");
    }
    return res;
  }

  Future<String> uploadProduct(
    String description,
    List<Uint8List> files,
    String uid,
    String username,
    String profImage,
    List<Map<String, dynamic>> variations,
    String category,
    bool vitrine,
    bool promotions,
    bool x,
  ) async {
    String res = "Some error occurred";
    try {
      List<VariationInfo> variationsList = [];

      for (int i = 0; i < variations.length; i++) {
        Map<String, dynamic> variationMap = variations[i];
        VariationInfo variationInfo = VariationInfo.fromMap(variationMap);

        List<String> variationPhotoUrls = [];
        if (variationMap['photoUrls'] != null) {
          variationPhotoUrls = List<String>.from(variationMap['photoUrls']);
        }
        variationInfo.photoUrls = variationPhotoUrls;

        variationsList.add(variationInfo);
      }

      String productId = const Uuid().v1();
      Product product = Product(
        description: description,
        uid: uid,
        username: username,
        vendas: 0,
        productId: productId,
        datePublished: DateTime.now(),
        category: category,
        variations: variationsList,
        profImage: profImage,
        vitrine: vitrine,
        promotions: promotions,
        x: x,
      );

      await FirebaseFirestore.instance
          .collection('products')
          .doc(productId)
          .set(product.toJson());

      res = "success";
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  Future<String> votePost(
      String votationId, String uid, int optionIndex) async {
    String res = "Some error occurred";
    try {
      DocumentSnapshot votationSnapshot =
          await _firestore.collection('votations').doc(votationId).get();

      if (votationSnapshot.exists) {
        List<dynamic> votes = (votationSnapshot.data() as dynamic)['votes'];

        // Verifica se o usuário já votou na votação
        bool hasVoted = false;
        int existingVoteIndex =
            -1; // Índice do voto existente do usuário (se houver)
        for (int i = 0; i < votes.length; i++) {
          Map<String, dynamic> vote = votes[i];
          if (vote['uid'] == uid) {
            hasVoted = true;
            existingVoteIndex = i;
            break;
          }
        }

        if (hasVoted) {
          // Verifica se o usuário selecionou a mesma opção que votou antes
          if (optionIndex == votes[existingVoteIndex]['optionIndex']) {
            // Remove o voto existente
            await _firestore.collection('votations').doc(votationId).update({
              'votes': FieldValue.arrayRemove([votes[existingVoteIndex]])
            });
            res = 'Vote removed';
          } else {
            res = 'User has already voted in a different option';
          }
        } else {
          // Verifica se o índice da opção é válido
          List<dynamic> options =
              (votationSnapshot.data() as dynamic)['options'];
          if (optionIndex >= 0 && optionIndex < options.length) {
            Map<String, dynamic> option = options[optionIndex];
            Map<String, dynamic> vote = {
              'uid': uid,
              'optionIndex': optionIndex,
              'optionDescription': option['description'],
              'voteTimestamp': DateTime.now(),
            };

            // Adiciona o novo voto à votação
            await _firestore.collection('votations').doc(votationId).update({
              'votes': FieldValue.arrayUnion([vote])
            });

            res = 'Success';
          } else {
            res = 'Invalid option index';
          }
        }
      } else {
        res = 'Votation does not exist';
      }
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  Future<void> updatePostGrade(String postId, bool isAnonymous) async {
    try {
      final collectionPath = isAnonymous ? 'anonymous_posts' : 'posts';

      DocumentSnapshot postSnapshot = await FirebaseFirestore.instance
          .collection(collectionPath)
          .doc(postId)
          .get();

      if (postSnapshot.exists &&
          (postSnapshot.data() as dynamic)['votes'] != null) {
        dynamic votes = (postSnapshot.data() as dynamic)['votes'];

        if (votes.isNotEmpty) {
          // Calcula a média dos votos
          double averageGrade =
              votes.values.reduce((a, b) => a + b) / votes.length;

          // Arredonda a média para o formato desejado (0 ou .5)
          double roundedGrade = (averageGrade * 2).round() / 2;

          // Atualiza o campo 'grade' na publicação
          await FirebaseFirestore.instance
              .collection(collectionPath)
              .doc(postId)
              .update({'grade': roundedGrade});
        }
      }
    } catch (err) {
      print(err.toString());
    }
  }

  Future<double> getUserGrade(String postId, String uid,
      [double? newGrade]) async {
    double initialRating = 0;
    try {
      DocumentSnapshot postSnapshot = await FirebaseFirestore.instance
          .collection('posts')
          .doc(postId)
          .get();
      DocumentSnapshot anonymousPostSnapshot = await FirebaseFirestore.instance
          .collection('anonymous_posts')
          .doc(postId)
          .get();

      bool isAnonymous = false;
      if (postSnapshot.exists) {
        String username = (postSnapshot.data() as dynamic)['username'];
        isAnonymous = username == "Anonymous User";
      } else if (anonymousPostSnapshot.exists) {
        String username = (anonymousPostSnapshot.data() as dynamic)['username'];
        isAnonymous = username == "Anonymous User";
      }

      final collectionPath = isAnonymous ? 'anonymous_posts' : 'posts';

      // Verifica se o usuário já votou nesse post
      if (postSnapshot.exists &&
          (postSnapshot.data() as dynamic)['votes'] != null) {
        dynamic votes = (postSnapshot.data() as dynamic)['votes'];
        if (votes[uid] != null) {
          initialRating = votes[uid];
          if (newGrade != null && initialRating != newGrade) {
            votes[uid] = newGrade;
            await FirebaseFirestore.instance
                .collection(collectionPath)
                .doc(postId)
                .update({'votes': votes});
          }
        } else {
          // Se o usuário nunca votou, cria um novo voto
          if (newGrade != null) {
            votes[uid] = newGrade;
            await FirebaseFirestore.instance
                .collection(collectionPath)
                .doc(postId)
                .update({'votes': votes});
            initialRating = newGrade;
          }
        }
      } else if (anonymousPostSnapshot.exists &&
          (anonymousPostSnapshot.data() as dynamic)['votes'] != null) {
        dynamic votes = (anonymousPostSnapshot.data() as dynamic)['votes'];
        if (votes[uid] != null) {
          initialRating = votes[uid];
          if (newGrade != null && initialRating != newGrade) {
            votes[uid] = newGrade;
            await FirebaseFirestore.instance
                .collection(collectionPath)
                .doc(postId)
                .update({'votes': votes});
          }
        } else {
          // Se o usuário nunca votou, cria um novo voto
          if (newGrade != null) {
            votes[uid] = newGrade;
            await FirebaseFirestore.instance
                .collection(collectionPath)
                .doc(postId)
                .update({'votes': votes});
            initialRating = newGrade;
          }
        }
      }
      await updatePostGrade(postId, isAnonymous);
    } catch (err) {
      print(err.toString());
    }
    return initialRating;
  }

  Future<String> postComment(String postId, String text, String uid,
      String name, String profilePic) async {
    String res = "Some error occurred";
    try {
      if (text.isNotEmpty) {
        String commentId = const Uuid().v1();
        _firestore
            .collection('posts')
            .doc(postId)
            .collection('comments')
            .doc(commentId)
            .set({
          'profilePic': profilePic,
          'name': name,
          'uid': uid,
          'text': text,
          'commentId': commentId,
          'datePublished': DateTime.now(),
        });
        res = 'success';
      } else {
        res = "Please enter text";
      }
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  Future<String> deleteComment(String postId, String commentId) async {
    String res = "Some error occurred";
    try {
      await _firestore
          .collection('posts')
          .doc(postId)
          .collection('comments')
          .doc(commentId)
          .delete();
      res = 'success';
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  Future<String> deletePost(String postId) async {
    String res = "Some error occurred";
    try {
      await _firestore.collection('posts').doc(postId).delete();
      res = 'success';
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  Future<String> deleteVotation(String votationId) async {
    String res = "Some error occurred";
    try {
      await _firestore.collection('votations').doc(votationId).delete();
      res = "success";
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  Future<String> deleteAnonymousPost(String postId) async {
    String res = "Some error occurred";
    try {
      await _firestore.collection('anonymous_posts').doc(postId).delete();
      res = 'success';
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  Future<void> followUser(String uid, String followId) async {
    try {
      DocumentSnapshot snap =
          await _firestore.collection('users').doc(uid).get();
      List<dynamic> following = (snap.data() as dynamic)['following'];

      if (following.contains(followId)) {
        await _firestore.collection('users').doc(followId).update({
          'followers': FieldValue.arrayRemove([uid])
        });

        await _firestore.collection('users').doc(uid).update({
          'following': FieldValue.arrayRemove([followId])
        });
      } else {
        await _firestore.collection('users').doc(followId).update({
          'followers': FieldValue.arrayUnion([uid])
        });

        await _firestore.collection('users').doc(uid).update({
          'following': FieldValue.arrayUnion([followId])
        });
      }
    } catch (e) {
      print(e.toString());
    }
  }

  Future<String> uploadSizes(
    String uid,
    String shoulder,
    String chest,
    String waist,
    String hip,
    String inseam,
    String height,
  ) async {
    try {
      await _firestore.doc(uid).set({
        'shoulder': shoulder,
        'chest': chest,
        'waist': waist,
        'hip': hip,
        'inseam': inseam,
        'height': height,
      }, SetOptions(merge: true));
      return 'success';
    } catch (e) {
      return 'Error: $e';
    }
  }

  Future<String> toggleFavorite(String postId, String uid) async {
    try {
      DocumentSnapshot favoriteSnapshot = await _firestore
          .collection('favorites')
          .doc(uid)
          .collection('userFavorites')
          .doc(postId)
          .get();

      if (favoriteSnapshot.exists) {
        // The post is already in favorites, so remove it
        await _firestore
            .collection('favorites')
            .doc(uid)
            .collection('userFavorites')
            .doc(postId)
            .delete();

        return 'Post removed from favorites';
      } else {
        DocumentSnapshot postSnapshot =
            await _firestore.collection('posts').doc(postId).get();
        DocumentSnapshot anonymousPostSnapshot =
            await _firestore.collection('anonymous_posts').doc(postId).get();

        if (postSnapshot.exists) {
          List<dynamic> photoUrls =
              (postSnapshot.data() as dynamic)['photoUrls'];

          await _firestore
              .collection('favorites')
              .doc(uid)
              .collection('userFavorites')
              .doc(postId)
              .set({
            'postId': postId,
            'uid': uid,
            'dateAdded': DateTime.now(),
            'photoUrls': photoUrls,
          });

          return 'Post added to favorites';
        } else if (anonymousPostSnapshot.exists) {
          List<dynamic> photoUrls =
              (anonymousPostSnapshot.data() as dynamic)['photoUrls'];

          await _firestore
              .collection('favorites')
              .doc(uid)
              .collection('userFavorites')
              .doc(postId)
              .set({
            'postId': postId,
            'uid': uid,
            'dateAdded': DateTime.now(),
            'photoUrls': photoUrls,
          });

          return 'Post added to favorites';
        } else {
          return 'Post not found';
        }
      }
    } catch (err) {
      return 'An error occurred: $err';
    }
  }
}
