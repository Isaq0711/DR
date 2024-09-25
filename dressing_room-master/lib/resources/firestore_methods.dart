import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dressing_room/models/post.dart';
import 'package:dressing_room/models/products.dart';
import 'package:dressing_room/models/votations.dart';
import 'package:dressing_room/models/store.dart';
import 'package:dressing_room/widgets/friends_list.dart';
import 'package:flutter/material.dart';
import 'package:dressing_room/widgets/tag_card.dart';
import 'package:dressing_room/screens/forum_screen.dart';
import 'package:dressing_room/resources/storage_methods.dart';
import 'package:provider/provider.dart';
import 'package:dressing_room/providers/bottton_nav_controller.dart';
import 'package:dressing_room/utils/utils.dart';
import 'package:uuid/uuid.dart';
import 'dart:math';
import 'package:dressing_room/models/cart.dart';
import 'package:dressing_room/models/clothes.dart';
import 'package:http/http.dart' as http;

class FireStoreMethods {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String> uploadPost(
    String description,
    List<Uint8List> files,
    List<String>? pecasIds,
    List<String>? pecasPhotoUrls,
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
        pecasIds: pecasIds,
        pecasPhotoUrls: pecasPhotoUrls,
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
    List<String>? pecasIds,
    List<String>? pecasPhotoUrls,
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
        pecasIds: pecasIds,
        pecasPhotoUrls: pecasPhotoUrls,
        datePublished: DateTime.now(),
        photoUrls: photoUrls,
        profImage: "https://cdn-icons-png.flaticon.com/512/4123/4123763.png",
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
    String question,
    List<Uint8List> photoFiles,
    String uid,
    String username,
    String profImage,
  ) async {
    String res = "Some error occurred";
    try {
      List<VotationOption> options = [];

      // Log the start of the upload process
      print(
          "Starting the upload process for ${votationOptions.length} options");

      // Upload files in sequence
      for (int i = 0; i < votationOptions.length; i++) {
        Uint8List file = photoFiles[i];
        Map<String, dynamic> optionData = votationOptions[i];

        print("Uploading image $i to storage");
        String photoUrl = await StorageMethods()
            .uploadImageToStorage('votations', file, true);
        print("Uploaded image $i to storage with URL: $photoUrl");

        VotationOption option = VotationOption(
          description: optionData['description'],
          photoUrl: photoUrl,
          pecasID: optionData['pecasID'],
          pecasPhotoUrls: optionData['pecasPhotoUrls'],
        );

        options.add(option);
      }

      // Generate votation ID
      String votationId = const Uuid().v1();
      Votation votation = Votation(
        uid: uid,
        username: username,
        question: question,
        votes: [],
        votationId: votationId,
        datePublished: DateTime.now(),
        options: options,
        profImage: profImage,
      );

      // Log the creation of the votation
      print("Creating votation with ID: $votationId");

      // Save votation to Firestore
      await _firestore
          .collection('votations')
          .doc(votationId)
          .set(votation.toJson());
      res = "success";
    } catch (err) {
      // Log any errors
      print("Error during votation upload: ${err.toString()}");
      res = err.toString();
    }

    // Log the result
    print("Votation upload result: $res");
    return res;
  }

  Future<Map<String, String>> uploadCloth(
    String description,
    Uint8List file,
    String uid,
    String? category,
    String? type,
    bool isPublic,
    String? barCode,
    List<String>? marcas,
    List<String>? tecido,
  ) async {
    try {
      // Faz o upload da imagem para o armazenamento
      String photoUrl =
          await StorageMethods().uploadImageToStorage('cloth', file, true);

      // Cria um ID único para o produto de roupa
      String clothId = const Uuid().v1();

      // Cria um objeto Cloth com os dados fornecidos
      Cloth cloth = Cloth(
        description: description,
        uid: uid,
        clothId: clothId,
        photoUrl: photoUrl,
        dateAdded: DateTime.now(),
        type: type,
        category: category,
        isPublic: isPublic,
        barCode: barCode,
        marcas: marcas,
        tecido: tecido,
      );

      await FirebaseFirestore.instance
          .collection('clothes')
          .doc(clothId)
          .set(cloth.toJson());

      await FireStoreMethods().addToWardrobe(clothId, uid, uid);

      return {"message": "success", "clothId": clothId};
    } catch (err) {
      return {"message": err.toString()};
    }
  }

  Future<String> deleteCloth(String clothId, String uid) async {
    String res = "Some error occurred";
    try {
      await _firestore.collection('clothes').doc(clothId).delete();

      await FireStoreMethods().removeFromWardrobe(clothId, uid);

      res = 'success';
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  Future<String> uploadForum(
    String description,
    List<Uint8List> files,
    List<String>? pecasIds,
    List<String>? pecasPhotoUrls,
    String uid,
    String username,
    String profImage,
  ) async {
    String res = "Some error occurred";
    try {
      List<String> photoUrls = [];

      for (Uint8List file in files) {
        String photoUrl =
            await StorageMethods().uploadImageToStorage('forum', file, true);

        photoUrls.add(photoUrl);
      }

      String forumId = const Uuid().v1();
      Forum forum = Forum(
        description: description,
        uid: uid,
        username: username,
        forumId: forumId,
        datePublished: DateTime.now(),
        photoUrls: photoUrls,
        pecasIds: pecasIds,
        pecasPhotoUrls: pecasPhotoUrls,
        profImage: profImage,
      );

      _firestore.collection('forum').doc(forumId).set(forum.toJson());

      var request = http.MultipartRequest(
        "POST",
        Uri.parse('http://$server:$port/forum'),
      );

      request.fields['postId'] = forumId;
      request.fields['description'] = description;
      request.fields['photoUrls'] = photoUrls.join(',');
      request.fields['userQuePostou'] = uid;

      final response = await request.send();

      if (response.statusCode == 200) {
        res = 'success';
      } else {
        res = "Suggestion saved in Firebase but failed to send to server";
      }
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  Future<String> createStore(String storename, Uint8List file, String uid,
      Uint8List capa, String bio) async {
    String res = "Some error occurred";
    try {
      String photoUrl =
          await StorageMethods().uploadImageToStorage('storeFotos', file, true);
      String fotodecapa =
          await StorageMethods().uploadImageToStorage('storeFotos', capa, true);

      String storeId = _generateStoreId();
      Store store = Store(
          storeId: storeId,
          storename: storename,
          photoUrl: photoUrl,
          fotodecapa: fotodecapa,
          followers: [],
          following: [],
          patrocinados: [],
          bio: bio,
          adms: [uid]);

      _firestore.collection('store').doc(storeId).set(store.toJson());
      res = "success";
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  String _generateStoreId() {
    const length = 28;
    const chars =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz';
    final rand = Random();
    return List.generate(length, (index) => chars[rand.nextInt(chars.length)])
        .join();
  }

  Future<String> createOrUpdateTabViewCollection(
    String uid,
    String collectionName,
    List<String> selectedPostIds,
  ) async {
    String res = "Some error occurred";
    try {
      DocumentReference userDocRef = _firestore.collection('users').doc(uid);

      DocumentSnapshot userSnap = await userDocRef.get();
      Map<String, dynamic>? userData = userSnap.data() as Map<String, dynamic>?;

      if (userData != null) {
        List<dynamic> tabViews = userData['tabviews'] ?? [];
        int existingIndex =
            tabViews.indexWhere((tab) => tab.keys.first == collectionName);

        if (existingIndex != -1) {
          Map<String, dynamic> updatedCollection = {
            collectionName: selectedPostIds,
          };
          tabViews[existingIndex] = updatedCollection;
        } else {
          Map<String, dynamic> newCollection = {
            collectionName: selectedPostIds,
          };
          tabViews.add(newCollection);
        }

        await userDocRef.update({'tabviews': tabViews});

        res = "success";
      } else {
        res = "User data not found";
      }
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  Future<String> updateTabViews(
      String uid, List<Map<String, dynamic>> tabViews) async {
    String res = "Some error occurred";
    try {
      // Update the 'users' collection with the new tabviews
      await _firestore
          .collection('users')
          .doc(uid)
          .update({'tabviews': tabViews});
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
    BuildContext context, // Adicione o parâmetro BuildContext
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
        qntspedidos: 1,
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
          await _firestore.collection('cart').doc(uid).update({
            '$productId': product.toJson(),
          });
          Provider.of<CartCounterProvider>(context, listen: false)
              .increment(); // Utilize o Provider.of com o contexto
        }
      } else {
        await _firestore.collection('cart').doc(uid).set({
          '$productId': product.toJson(),
        });
        Provider.of<CartCounterProvider>(context, listen: false)
            .increment(); // Utilize o Provider.of com o contexto
      }
      res = "success";
    } catch (err) {
      res = "Error: $err";

      print("Error occurred: $err");
    }
    return res;
  }

  Future<String> removeFromCart(
      String uid, String productId, BuildContext context) async {
    String res = "Some error occurred";
    try {
      DocumentSnapshot productsnapshot =
          await _firestore.collection('cart').doc(uid).get();

      if (productsnapshot.exists && productsnapshot.data() != null) {
        await _firestore.collection('cart').doc(uid).update({
          '$productId': FieldValue.delete(),
        });
        Provider.of<CartCounterProvider>(context, listen: false)
            .decrement(); // Utilize o Provider.of com o contexto
        res = "success";
      }
    } catch (err) {
      res = "Error: $err";
      print("Error occurred: $err");
    }
    return res;
  }

  Future<String> uploadList(
    String uid,
    String listname,
    List<String>? users,
  ) async {
    String res = "Some error occurred";
    try {
      Lista listaa = Lista(
        uid: uid,
        dateAdded: DateTime.now(),
        listname: listname,
        users: users,
      );

      DocumentSnapshot listsnap =
          await _firestore.collection('lists').doc(uid).get();

      if (listsnap.exists) {
        Map<String, dynamic> data = listsnap.data() as Map<String, dynamic>;

        data[listname] = listaa.toJson();

        await _firestore.collection('lists').doc(uid).update(data);
      } else {
        await _firestore.collection('lists').doc(uid).set({
          listname: listaa.toJson(),
        });
      }

      res = "success";
    } catch (err) {
      res = "Error: $err";
      print("Error occurred: $err");
    }
    return res;
  }

  Future<String> createHashtag(String itemname, String category) async {
    String res = "Some error occurred";

    try {
      Hashtag tag = Hashtag(
        itemname: itemname,
        category: category,
      );

      DocumentSnapshot tagSnap =
          await _firestore.collection('hashtags').doc(category).get();

      if (tagSnap.exists) {
        Map<String, dynamic> data = tagSnap.data() as Map<String, dynamic>;
        data[itemname] = tag.toJson();

        await _firestore.collection('hashtags').doc(category).update(data);
      } else {
        await _firestore.collection('hashtags').doc(category).set({
          itemname: tag.toJson(),
        });
      }

      res = "success";
    } catch (err) {
      res = "Error: $err";
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
    String type,
    bool vitrine,
    bool promotions,
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
        type: type,
        variations: variationsList,
        profImage: profImage,
        vitrine: vitrine,
        promotions: promotions,
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

  Future<String> removeVote(String votationId, String uid) async {
    String res = "Some error occurred";
    try {
      DocumentSnapshot votationSnapshot =
          await _firestore.collection('votations').doc(votationId).get();

      if (votationSnapshot.exists) {
        List<dynamic> votes = (votationSnapshot.data() as dynamic)['votes'];

        int existingVoteIndex = votes.indexWhere((vote) => vote['uid'] == uid);
        if (existingVoteIndex != -1) {
          await _firestore.collection('votations').doc(votationId).update({
            'votes': FieldValue.arrayRemove([votes[existingVoteIndex]])
          });
          res = 'Vote removed';
        } else {
          res = 'User has not voted yet';
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

  Future<String> postComment(
      String postId,
      String? description,
      String text,
      double? rating,
      String userquepostou,
      String uid,
      String name,
      String profilePic,
      String category) async {
    String res = "Some error occurred";

    try {
      if (text.isNotEmpty) {
        String commentId = const Uuid().v1();
        await _firestore
            .collection(category)
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

        var request = http.MultipartRequest(
            "POST", Uri.parse('http://$server:$port/comments'));

        request.fields['postId'] = postId;
        request.fields['rating'] = rating.toString();
        request.fields['description'] = description!;
        request.fields['comentario'] = text;
        request.fields['userQueComentou'] = uid;
        request.fields['userQuePostou'] = userquepostou;
        request.fields['category'] = category;
        request.fields['photoUrls'] = "";
        request.fields['tipo'] = "comentário";

        final response = await request.send();

        if (response.statusCode == 200) {
          res = 'success';
        } else {
          res = "Comment saved in Firebase but failed to send to server";
        }
      } else {
        res = "Please enter text";
      }
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  Future<String> deleteComment(
      String postId, String commentId, String category) async {
    String res = "Some error occurred";
    try {
      await _firestore
          .collection(category)
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

  Future<String> suggest(
    String? postId,
    String text,
    String uid,
    List<dynamic> photoUrls,
    List<String> postIds,
    String categoria,
    String? description,
    double? rating,
    String? userquepostou,
  ) async {
    String res = "Some error occurred";
    try {
      if (text.isNotEmpty) {
        String suggestionId = const Uuid().v1();
        _firestore
            .collection(categoria)
            .doc(postId)
            .collection('suggestion')
            .doc(suggestionId)
            .set({
          'uid': uid,
          'text': text,
          'photoUrls': photoUrls,
          'suggestionId': suggestionId,
          'postIds': postIds,
          'datePublished': DateTime.now(),
        });
        var request = http.MultipartRequest(
            "POST", Uri.parse('http://$server:$port/comments'));

        request.fields['postId'] = postId!;
        request.fields['rating'] = rating.toString();
        request.fields['description'] = description!;
        request.fields['photoUrls'] = photoUrls.join(',');
        request.fields['comentario'] = text;
        request.fields['userQueComentou'] = uid;
        request.fields['userQuePostou'] = userquepostou!;
        request.fields['category'] = categoria;
        request.fields['tipo'] = "sugestão";

        final response = await request.send();

        if (response.statusCode == 200) {
          res = 'success';
        } else {
          res = "Suggestion saved in Firebase but failed to send to server";
        }
      } else {
        res = "Please enter text";
      }
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  Future<String> deleteSuggestion(
      String postId, String suggestionId, String category) async {
    String res = "Some error occurred";
    try {
      await _firestore
          .collection(category)
          .doc(postId)
          .collection('suggestion')
          .doc(suggestionId)
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
        DocumentSnapshot productSnapshot =
            await _firestore.collection('products').doc(postId).get();
        DocumentSnapshot votationSnapshot =
            await _firestore.collection('votations').doc(postId).get();

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
        } else if (productSnapshot.exists) {
          List<dynamic> variations =
              (productSnapshot.data() as dynamic)['variations'];
          List<dynamic> photoUrls = variations[0]['photoUrls'];
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
        } else if (votationSnapshot.exists) {
          Votation votation = Votation.fromSnap(votationSnapshot);

          if (votation.options.isNotEmpty) {
            VotationOption firstOption = votation.options.first;

            await _firestore
                .collection('favorites')
                .doc(uid)
                .collection('userFavorites')
                .doc(postId)
                .set({
              'postId': postId,
              'uid': uid,
              'dateAdded': DateTime.now(),
              'photoUrls': [firstOption.photoUrl],
            });

            return 'Post added to favorites';
          } else {
            return 'No options found for the votation';
          }
        } else {
          return 'Post not found';
        }
      }
    } catch (err) {
      return 'An error occurred: $err';
    }
  }

  Future<String> addToWardrobe(
      String clothId, String uid, String userquecriou) async {
    try {
      DocumentReference clothRef = _firestore
          .collection('wardrobe')
          .doc(uid)
          .collection('clothes')
          .doc(clothId);

      await clothRef.set({
        'dateAdded': DateTime.now(),
        'userquecriou': userquecriou,
        'clothId': clothId
      });

      return 'Success';
    } catch (err) {
      return 'An error occurred: $err';
    }
  }

  Future<String> removeFromWardrobe(String clothId, String uid) async {
    try {
      // Referência para o documento dentro da subcoleção 'wardrobe'
      DocumentReference clothRef = _firestore
          .collection('wardrobe')
          .doc(uid)
          .collection('clothes') // Subcoleção para roupas
          .doc(clothId); // Usando clothId como identificador do documento

      // Verificar se o documento existe antes de tentar removê-lo
      DocumentSnapshot clothSnapshot = await clothRef.get();

      if (clothSnapshot.exists) {
        // Se o documento existir, removê-lo
        await clothRef.delete();
        return 'Success';
      } else {
        return 'Cloth not found in wardrobe';
      }
    } catch (err) {
      return 'An error occurred: $err';
    }
  }

  Future<String> planLook(Uint8List photo, String uid, DateTime data,
      String troncoId, String pernasId, String pesId) async {
    try {
      String photoUrl = await StorageMethods()
          .uploadImageToStorage('looksdodia', photo, true);

      CollectionReference collectionRef =
          _firestore.collection('calendar').doc(uid).collection('looks');

      await collectionRef.add({
        'data': data,
        'look': photoUrl,
        'uid': uid,
        'troncoId': troncoId,
        'pernasId': pernasId,
        'pesId': pesId,
        'lookId': collectionRef.id,
      });

      return 'Success';
    } catch (err) {
      return 'An error occurred: $err';
    }
  }
}
