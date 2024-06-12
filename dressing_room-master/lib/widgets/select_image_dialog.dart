import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:gap/gap.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:dressing_room/utils/colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:dressing_room/screens/create_store_screen.dart';

import 'package:firebase_auth/firebase_auth.dart';

import 'package:dressing_room/utils/utils.dart';

class SelectImageDialog extends StatelessWidget {
  final Function(Uint8List) onImageSelected;

  SelectImageDialog({required this.onImageSelected});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppTheme.nearlyWhite,
      title: Align(
        alignment: Alignment.center,
        child: Text(
          'UPLOAD',
          style: AppTheme.subheadline,
        ),
      ),
      content: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ElevatedButton.icon(
            icon: Icon(Icons.camera),
            label: const Text(
              'Camera',
              style: TextStyle(
                fontFamily: 'Quicksand',
                fontWeight: FontWeight.bold,
              ),
            ),
            style: ElevatedButton.styleFrom(primary: AppTheme.vinho),
            onPressed: () async {
              Navigator.pop(context);
              Uint8List? file = await pickImage(ImageSource.camera);
              if (file != null) {
                onImageSelected(file);
              }
            },
          ),
          SizedBox(
            width: 10,
          ),
          ElevatedButton.icon(
            icon: Icon(Icons.photo_library),
            label: const Text(
              'Gallery',
              style: TextStyle(
                fontFamily: 'Quicksand',
                fontWeight: FontWeight.bold,
              ),
            ),
            style: ElevatedButton.styleFrom(primary: AppTheme.vinho),
            onPressed: () async {
              Navigator.of(context).pop();
              Uint8List? file = await pickImage(ImageSource.gallery);
              if (file != null) {
                onImageSelected(file);
              }
            },
          ),
        ],
      ),
    );
  }
}

class SelectImageDialog1por1 extends StatelessWidget {
  final Function(Uint8List) onImageSelected;

  SelectImageDialog1por1({required this.onImageSelected});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppTheme.nearlyWhite,
      title: Align(
        alignment: Alignment.center,
        child: Text(
          'UPLOAD',
          style: AppTheme.subheadline,
        ),
      ),
      content: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ElevatedButton.icon(
            icon: Icon(Icons.camera),
            label: const Text(
              'Camera',
              style: TextStyle(
                fontFamily: 'Quicksand',
                fontWeight: FontWeight.bold,
              ),
            ),
            style: ElevatedButton.styleFrom(primary: AppTheme.vinho),
            onPressed: () async {
              Navigator.pop(context);
              Uint8List? file = await pickImage(ImageSource.camera);
              if (file != null) {
                onImageSelected(file);
              }
            },
          ),
          SizedBox(
            width: 10,
          ),
          ElevatedButton.icon(
            icon: Icon(Icons.photo_library),
            label: const Text(
              'Gallery',
              style: TextStyle(
                fontFamily: 'Quicksand',
                fontWeight: FontWeight.bold,
              ),
            ),
            style: ElevatedButton.styleFrom(primary: AppTheme.vinho),
            onPressed: () async {
              Navigator.of(context).pop();
              Uint8List? file = await pickImage(ImageSource.gallery);
              if (file != null) {
                onImageSelected(file);
              }
            },
          ),
        ],
      ),
    );
  }
}

class SelectImageRedondaDialog extends StatelessWidget {
  final Function(Uint8List) onImageSelected;

  SelectImageRedondaDialog({required this.onImageSelected});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppTheme.nearlyWhite,
      title: Align(
        alignment: Alignment.center,
        child: Text(
          'UPLOAD',
          style: AppTheme.subheadline,
        ),
      ),
      content: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ElevatedButton.icon(
            icon: Icon(Icons.camera),
            label: const Text(
              'Camera',
              style: TextStyle(
                fontFamily: 'Quicksand',
                fontWeight: FontWeight.bold,
              ),
            ),
            style: ElevatedButton.styleFrom(primary: AppTheme.vinho),
            onPressed: () async {
              Navigator.pop(context);
              Uint8List? file = await pickImageRedonda(ImageSource.camera);
              if (file != null) {
                onImageSelected(file);
              }
            },
          ),
          SizedBox(
            width: 10,
          ),
          ElevatedButton.icon(
            icon: Icon(Icons.photo_library),
            label: const Text(
              'Gallery',
              style: TextStyle(
                fontFamily: 'Quicksand',
                fontWeight: FontWeight.bold,
              ),
            ),
            style: ElevatedButton.styleFrom(primary: AppTheme.vinho),
            onPressed: () async {
              Navigator.of(context).pop();
              Uint8List? file = await pickImageRedonda(ImageSource.gallery);
              if (file != null) {
                onImageSelected(file);
              }
            },
          ),
        ],
      ),
    );
  }
}

class SelectImageCapaDialog extends StatelessWidget {
  final Function(Uint8List) onImageSelected;

  SelectImageCapaDialog({required this.onImageSelected});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppTheme.nearlyWhite,
      title: Align(
        alignment: Alignment.center,
        child: Text(
          'UPLOAD',
          style: AppTheme.subheadline,
        ),
      ),
      content: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ElevatedButton.icon(
            icon: Icon(Icons.camera),
            label: const Text(
              'Camera',
              style: TextStyle(
                fontFamily: 'Quicksand',
                fontWeight: FontWeight.bold,
              ),
            ),
            style: ElevatedButton.styleFrom(primary: AppTheme.vinho),
            onPressed: () async {
              Navigator.pop(context);
              Uint8List? file = await pickImagedeCapa(ImageSource.camera);
              if (file != null) {
                onImageSelected(file);
              }
            },
          ),
          SizedBox(
            width: 10,
          ),
          ElevatedButton.icon(
            icon: Icon(Icons.photo_library),
            label: const Text(
              'Gallery',
              style: TextStyle(
                fontFamily: 'Quicksand',
                fontWeight: FontWeight.bold,
              ),
            ),
            style: ElevatedButton.styleFrom(primary: AppTheme.vinho),
            onPressed: () async {
              Navigator.of(context).pop();
              Uint8List? file = await pickImagedeCapa(ImageSource.gallery);
              if (file != null) {
                onImageSelected(file);
              }
            },
          ),
        ],
      ),
    );
  }
}

class SelectImageSuggestion extends StatelessWidget {
  final Function(Uint8List) onImageSelected;

  SelectImageSuggestion({required this.onImageSelected});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppTheme.nearlyWhite,
      title: Align(
        alignment: Alignment.center,
        child: Text(
          'UPLOAD',
          style: AppTheme.subheadline,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ElevatedButton(
            child: Text(
              'Remove BG',
              style: TextStyle(
                fontFamily: 'Quicksand',
                fontWeight: FontWeight.bold,
              ),
            ),
            style: ElevatedButton.styleFrom(primary: AppTheme.vinho),
            onPressed: () async {
              SelectImageDialog1por1(onImageSelected: onImageSelected);
              Navigator.pop(context);
              Uint8List? file = await pickImage1por1(ImageSource.camera);
              if (file != null) {
                onImageSelected(file);
              }
            },
          ),
          Gap(
            10.h,
          ),
          ElevatedButton(
            child: Text(
              'Complete image',
              style: TextStyle(
                fontFamily: 'Quicksand',
                fontWeight: FontWeight.bold,
              ),
            ),
            style: ElevatedButton.styleFrom(primary: AppTheme.vinho),
            onPressed: () async {
              Navigator.of(context).pop();
              Uint8List? file = await pickImage1por1(ImageSource.gallery);
              if (file != null) {
                onImageSelected(file);
              }
            },
          ),
        ],
      ),
    );
  }
}

class SelectStore extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppTheme.nearlyWhite,
      title: Align(
        alignment: Alignment.center,
        child: Text(
          'SELECIONE A LOJA',
          style: AppTheme.subheadline,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ElevatedButton(
            child: Row(children: [
              Icon(
                Icons.add,
                color: AppTheme.nearlyWhite,
              ),
              Gap(5),
              Text('Criar uma loja', style: AppTheme.barapp),
            ]),
            style: ElevatedButton.styleFrom(primary: AppTheme.vinho),
            onPressed: () async {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CreateStoreScreen(),
                ),
              );
            },
          ),
          Gap(
            10.h,
          ),
          FutureBuilder<QuerySnapshot>(
            future: FirebaseFirestore.instance
                .collection('store')
                .where('adms',
                    arrayContains: FirebaseAuth.instance.currentUser!.uid)
                .get(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator();
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return Text('No stores found.');
              }
              var userStores = snapshot.data!.docs;
              return ListView.builder(
                shrinkWrap: true,
                itemCount: userStores.length,
                itemBuilder: (context, index) {
                  var store = userStores[index].data() as Map<String, dynamic>;
                  return ElevatedButton(
                    child: Text(
                      store['storename'],
                      style: TextStyle(
                        fontFamily: 'Quicksand',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(primary: AppTheme.vinho),
                    onPressed: () {},
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
