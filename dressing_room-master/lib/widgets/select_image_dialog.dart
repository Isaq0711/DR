import 'dart:typed_data';
import 'package:dressing_room/screens/add_product_screen.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:gap/gap.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:dressing_room/utils/colors.dart';
import 'package:dressing_room/screens/2_store_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dressing_room/screens/2_store_screen.dart';
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
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
              width: 300.h,
              child: ElevatedButton.icon(
                icon: Icon(Icons.camera),
                label: Text(
                  'Câmera',
                  style: TextStyle(
                      fontFamily: 'Quicksand',
                      fontWeight: FontWeight.bold,
                      fontSize: 15.h),
                ),
                style: ElevatedButton.styleFrom(primary: AppTheme.vinho),
                onPressed: () async {
                  Navigator.pop(context);
                  Uint8List? file = await pickImage(ImageSource.camera);
                  if (file != null) {
                    onImageSelected(file);
                  }
                },
              )),
          Gap(
            5.h,
          ),
          Container(
              width: 300.h,
              child: ElevatedButton.icon(
                icon: Icon(Icons.photo_library),
                label: Text(
                  'Galeria',
                  style: TextStyle(
                    fontFamily: 'Quicksand',
                    fontSize: 15.h,
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
              )),
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
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            width: 300.h,
            child: ElevatedButton.icon(
              icon: Icon(Icons.camera),
              label: const Text(
                'Câmera',
                style: TextStyle(
                  fontFamily: 'Quicksand',
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(primary: AppTheme.vinho),
              onPressed: () async {
                Navigator.pop(context);
                Uint8List? file =
                    await pickImage1por1(source: ImageSource.camera);
                if (file != null) {
                  onImageSelected(file);
                }
              },
            ),
          ),
          Gap(2.h),
          Container(
            width: 300.h,
            child: ElevatedButton.icon(
              icon: Icon(Icons.photo_library),
              label: const Text(
                'Galeria',
                style: TextStyle(
                  fontFamily: 'Quicksand',
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(primary: AppTheme.vinho),
              onPressed: () async {
                Navigator.of(context).pop();
                Uint8List? file =
                    await pickImage1por1(source: ImageSource.gallery);
                if (file != null) {
                  onImageSelected(file);
                }
              },
            ),
          ),
          Gap(2.h),
          Container(
            width: 300.h,
            child: ElevatedButton.icon(
              icon: Icon(Icons.web),
              label: const Text(
                'Web',
                style: TextStyle(
                  fontFamily: 'Quicksand',
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(primary: AppTheme.vinho),
              onPressed: () async {
                Navigator.pop(context);
                Uint8List? file = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => WebViewPage(
                      onImageCaptured: (Uint8List capturedFile) {
                        Navigator.pop(context, capturedFile);
                      },
                    ),
                  ),
                );
                if (file != null) {
                  onImageSelected(file);
                }
              },
            ),
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
          style: AppTheme.headline,
        ),
      ),
      content: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ElevatedButton.icon(
            icon: Icon(Icons.camera),
            label: const Text(
              'Câmera',
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
              'Galeria',
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
              'Câmera',
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
              'Galeria',
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
              Uint8List? file =
                  await pickImage1por1(source: ImageSource.camera);
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
              Uint8List? file =
                  await pickImage1por1(source: ImageSource.gallery);
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
              Text('Criar uma loja', style: AppTheme.subheadlinewhite),
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
                return SizedBox.shrink();
              }
              var userStores = snapshot.data!.docs;
              return SizedBox(
                height: 100.h,
                width: 300.w,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: userStores.length,
                  itemBuilder: (context, index) {
                    var store =
                        userStores[index].data() as Map<String, dynamic>;
                    return ElevatedButton(
                      child: Row(children: [
                        Container(
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border:
                                    Border.all(width: 1, color: AppTheme.cinza),
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                      color: Colors.black54, blurRadius: 15)
                                ]),
                            child: CircleAvatar(
                              radius: 13,
                              backgroundImage: NetworkImage(store['photoUrl']),
                            )),
                        Gap(7),
                        Expanded(
                          child: Text(
                            store['storename'],
                            style: AppTheme.subheadlinewhite,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ]),
                      style: ElevatedButton.styleFrom(primary: AppTheme.vinho),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AddProductScreen(
                              uid: store['storeId'],
                              storename: store['storename'],
                              storephoto: store['photoUrl'],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
