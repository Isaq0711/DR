import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dressing_room/models/post.dart';
import 'package:dressing_room/models/votations.dart';
import 'package:dressing_room/resources/storage_methods.dart';
import 'package:uuid/uuid.dart';

class FireStoreMethods {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

 Future<String> uploadPost(
  String description,
  List<Uint8List> files, // Alterado para uma lista de Uint8List
  String uid,
  String username,
  String profImage,
) async {
  String res = "Some error occurred";
  try {
    List<String> photoUrls = []; // Lista de URLs de fotos

    for (Uint8List file in files) {
      String photoUrl =
          await StorageMethods().uploadImageToStorage('posts', file, true);
      photoUrls.add(photoUrl); // Adiciona a URL da foto à lista
    }

    String postId = const Uuid().v1();
    Post post = Post(
      description: description,
      uid: uid,
      username: username,
      likes: [],
      dislikes: [],
      postId: postId,
      datePublished: DateTime.now(),
      photoUrls: photoUrls, // Armazena a lista de URLs de fotos
      profImage: profImage,
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
  List<Uint8List> files, // Alterado para uma lista de Uint8List
  String uid,
) async {
  String res = "Some error occurred";
  try {
    List<String> photoUrls = []; // Lista de URLs de fotos

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
      likes: [],
      dislikes: [],
      postId: postId,
      datePublished: DateTime.now(),
      photoUrls: photoUrls, // Armazena a lista de URLs de fotos
      profImage: "generic_photo_url",
    );

    _firestore.collection('anonymous_posts').doc(postId).set(post.toJson());
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

      String photoUrl =
          await StorageMethods().uploadImageToStorage('votations', file, true);
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

Future<String> votePost(String votationId, String uid, int optionIndex) async {
  String res = "Some error occurred";
  try {
    DocumentSnapshot votationSnapshot = await _firestore.collection('votations').doc(votationId).get();

    if (votationSnapshot.exists) {
      List<dynamic> votes = (votationSnapshot.data() as dynamic)['votes'];

      // Verifica se o usuário já votou na votação
      bool hasVoted = false;
      int existingVoteIndex = -1; // Índice do voto existente do usuário (se houver)
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
        List<dynamic> options = (votationSnapshot.data() as dynamic)['options'];
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



Future<String> likePost(String postId, String uid, List<dynamic> likes) async {
  String res = "Some error occurred";
  try {
    DocumentSnapshot postSnapshot = await _firestore.collection('posts').doc(postId).get();
    DocumentSnapshot anonymousPostSnapshot = await _firestore.collection('anonymous_posts').doc(postId).get();

    bool isAnonymous = false;
    if (postSnapshot.exists) {
      String username = (postSnapshot.data() as dynamic)['username'];
      isAnonymous = username == "Anonymous User";
    } else if (anonymousPostSnapshot.exists) {
      String username = (anonymousPostSnapshot.data() as dynamic)['username'];
      isAnonymous = username == "Anonymous User";
    }

    final collectionPath = isAnonymous ? 'anonymous_posts' : 'posts';

    if (likes.contains(uid)) {
      // Se a lista de curtidas contém o uid do usuário, precisamos removê-lo
      await _firestore.collection(collectionPath).doc(postId).update({
        'likes': FieldValue.arrayRemove([uid])
      });
    } else {
      // Caso contrário, precisamos adicionar o uid às curtidas
      await _firestore.collection(collectionPath).doc(postId).update({
        'likes': FieldValue.arrayUnion([uid])
      });
    }

    res = 'success';
  } catch (err) {
    res = err.toString();
  }
  return res;
}


  Future<String> dislikePost(String postId, String uid, List<dynamic> dislikes) async {
  String res = "Some error occurred";
  try {
    DocumentSnapshot postSnapshot = await _firestore.collection('posts').doc(postId).get();
    DocumentSnapshot anonymousPostSnapshot = await _firestore.collection('anonymous_posts').doc(postId).get();

    bool isAnonymous = false;
    if (postSnapshot.exists) {
      String username = (postSnapshot.data() as dynamic)['username'];
      isAnonymous = username == "Anonymous User";
    } else if (anonymousPostSnapshot.exists) {
      String username = (anonymousPostSnapshot.data() as dynamic)['username'];
      isAnonymous = username == "Anonymous User";
    }

    final collectionPath = isAnonymous ? 'anonymous_posts' : 'posts';

    if (dislikes.contains(uid)) {
      // Se a lista de dislikes contém o uid do usuário, precisamos removê-lo
      await _firestore.collection(collectionPath).doc(postId).update({
        'dislikes': FieldValue.arrayRemove([uid])
      });
    } else {
      // Caso contrário, precisamos adicionar o uid aos dislikes
      await _firestore.collection(collectionPath).doc(postId).update({
        'dislikes': FieldValue.arrayUnion([uid])
      });
    }

    res = 'success';
  } catch (err) {
    res = err.toString();
  }
  return res;
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
      DocumentSnapshot snap = await _firestore.collection('users').doc(uid).get();
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
      DocumentSnapshot postSnapshot = await _firestore.collection('posts').doc(postId).get();
      DocumentSnapshot anonymousPostSnapshot = await _firestore.collection('anonymous_posts').doc(postId).get();

      if (postSnapshot.exists) {
        List<dynamic> photoUrls = (postSnapshot.data() as dynamic)['photoUrls'];

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
        List<dynamic> photoUrls = (anonymousPostSnapshot.data() as dynamic)['photoUrls'];

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
