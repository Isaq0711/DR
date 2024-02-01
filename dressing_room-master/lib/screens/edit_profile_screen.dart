import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dressing_room/utils/colors.dart';
import 'package:dressing_room/utils/utils.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:dressing_room/resources/storage_methods.dart';
import 'package:dressing_room/widgets/select_image_dialog.dart';
import 'package:gap/gap.dart';

class EditProfileScreen extends StatefulWidget {
  final String uid;

  const EditProfileScreen({Key? key, required this.uid}) : super(key: key);

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  var userData = {};
  final TextEditingController _usernameController = TextEditingController();
  Uint8List? _image;
  bool isLoading = false;
  bool _isEditing = false;
  List<String> Categorias = [
    "Viagem à Europa",
    "Camisas verão",
    "Looks inverno",
    "Looks trabalho",
    "Jogos de futebol",
    "SP fashion week"
  ];

  @override
  void initState() {
    super.initState();
    getData();
  }

  getData() async {
    setState(() {
      isLoading = true;
    });
    try {
      var userSnap = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.uid)
          .get();

      userData = userSnap.data()!;

      setState(() {});
    } catch (e) {
      showSnackBar(
        context,
        e.toString(),
      );
    }
    setState(() {
      isLoading = false;
    });
  }

  void saveChanges() async {
    String newUsername = _usernameController.text;
    Uint8List? newImage = _image;

    if (_usernameController.text != "") {
      // Update username in 'users' collection
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.uid)
          .update({'username': newUsername});

      // Update username in 'posts' collection
      QuerySnapshot posts = await FirebaseFirestore.instance
          .collection('posts')
          .where('uid', isEqualTo: widget.uid)
          .get();
      posts.docs.forEach((doc) {
        doc.reference.update({'username': newUsername});
      });

      // Update username in 'votations' collection
      QuerySnapshot votations = await FirebaseFirestore.instance
          .collection('votations')
          .where('uid', isEqualTo: widget.uid)
          .get();
      votations.docs.forEach((doc) {
        doc.reference.update({'username': newUsername});
      });
    }

    if (_image != null) {
      String downloadUrl = await StorageMethods()
          .uploadImageToStorage('profilePics', _image!, false);

      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.uid)
          .update({'photoUrl': downloadUrl});
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const Center(
            child: CircularProgressIndicator(),
          )
        : Scaffold(
            appBar: AppBar(
              title: Text('Edit Profile', style: AppTheme.headlinewhite),
              backgroundColor: AppTheme.vinho,
              actions: [
                IconButton(
                  onPressed: saveChanges,
                  icon: const Icon(Icons.save),
                ),
              ],
            ),
            body: Container(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return SelectImageDialog(
                              onImageSelected: (Uint8List file) {
                            setState(() {
                              _image = file;
                            });
                          });
                        },
                      );
                    },
                    child: Stack(
                      children: [
                        _image != null
                            ? CircleAvatar(
                                radius: 64,
                                backgroundImage: MemoryImage(_image!),
                                backgroundColor: Colors.grey,
                              )
                            : CircleAvatar(
                                backgroundColor: Colors.grey,
                                backgroundImage:
                                    NetworkImage(userData['photoUrl']),
                                radius: 70.h,
                              ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppTheme.vinho,
                            ),
                            padding: const EdgeInsets.all(8.0),
                            child: Icon(
                              Icons.edit,
                              color: AppTheme.nearlyWhite,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Gap(45.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (_isEditing)
                        Expanded(
                          child: TextField(
                            controller: _usernameController,
                            decoration: InputDecoration(
                              labelText: "Type new Username",
                              labelStyle: AppTheme.title,
                              hintStyle: AppTheme.title,
                            ),
                            style: TextStyle(color: Colors.black),
                          ),
                        )
                      else
                        Text(
                          userData['username'],
                          style: AppTheme.subheadline,
                        ),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            _isEditing = true;
                          });
                        },
                        icon: Icon(
                          Icons.edit,
                          color: AppTheme.nearlyBlack,
                        ),
                      ),
                    ],
                  ),
                  Gap(40.h),
                  Text(
                    "Edit Collections",
                    style: AppTheme.subheadline,
                  ),
                  Gap(10.h),
                  Container(
                    height: 330.h,
                    child: ReorderableListView(
                      onReorder: (int oldIndex, int newIndex) {
                        setState(() {
                          if (oldIndex < newIndex) {
                            newIndex -= 1;
                          }
                          final String item = Categorias.removeAt(oldIndex);
                          Categorias.insert(newIndex, item);
                        });
                      },
                      children: Categorias.asMap()
                          .entries
                          .map(
                            (MapEntry<int, String> entry) => ListTile(
                              key: Key(entry.value),
                              title: Text(
                                entry.value,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.black,
                                ),
                              ),
                              trailing: IconButton(
                                onPressed: () {
                                  setState(() {});
                                },
                                icon: Icon(Icons.edit,
                                    color: AppTheme.nearlyBlack),
                              ),
                              onTap: () {
                                setState(() {});
                              },
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ],
              ),
            ),
          );
  }
}
