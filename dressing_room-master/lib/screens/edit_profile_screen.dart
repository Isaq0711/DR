import 'dart:typed_data';
import 'package:dressing_room/resources/firestore_methods.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dressing_room/utils/colors.dart';
import 'package:dressing_room/utils/utils.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:dressing_room/resources/storage_methods.dart';
import 'package:dressing_room/widgets/select_image_dialog.dart';
import 'package:gap/gap.dart';

List<String> _createLocalCollection(
  String collectionName,
  List<String> selectedPostIds,
  List<String> Categorias,
  Map<dynamic, dynamic> userData,
) {
  Map<String, dynamic> newCollection = {
    collectionName: selectedPostIds,
  };

  Categorias.add(collectionName);

  // Adicione a nova coleção ao userData
  userData['tabviews'].add(newCollection);

  return Categorias;
}

class EditProfileScreen extends StatefulWidget {
  final String uid;

  EditProfileScreen({Key? key, required this.uid}) : super(key: key);

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  var userData = {};
  final TextEditingController _usernameController = TextEditingController();
  Uint8List? _image;
  bool isLoading = false;
  int selectedIndex = 0;
  bool _isEditing = false;
  late List<String> Categorias;

  @override
  void initState() {
    super.initState();
    getData();
  }

  void _createLocalCollection(
      String collectionName, List<String> selectedPostIds) {
    Map<String, dynamic> newCollection = {
      'name': collectionName,
      'selectedPostIds': selectedPostIds,
      'originalIndex': Categorias.length,
    };

    Categorias.add(collectionName);
    userData['tabviews'].add(newCollection);
    setState(() {});
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
      List<dynamic> tabViews = userData['tabviews'] ?? [];
      Categorias = tabViews
          .cast<Map<String, dynamic>>()
          .map((tab) => tab.keys.first)
          .toList();

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
    List<Map<String, dynamic>> tabViews =
        List<Map<String, dynamic>>.from(userData['tabviews']);

    String updateTabViewsRes =
        await FireStoreMethods().updateTabViews(widget.uid, tabViews);
    if (updateTabViewsRes == "success") {
      Navigator.pop(context);
    } else {
      showSnackBar(context, updateTabViewsRes);
    }
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const Center(
            child: CircularProgressIndicator(),
          )
        : Scaffold(
            appBar: AppBar(
                leading: IconButton(
                  icon: Icon(Icons.arrow_back_ios, color: Colors.black),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                title: Text(
                  'Edit Profile',
                  style: AppTheme.barapp.copyWith(shadows: [
                    Shadow(
                      blurRadius: 2.0,
                      color: Colors.black,
                    ),
                  ]),
                ),
                centerTitle: true,
                backgroundColor: Colors.transparent,
                actions: [
                  IconButton(
                    onPressed: saveChanges,
                    icon: const Icon(Icons.save),
                  ),
                ],
                iconTheme: IconThemeData(color: AppTheme.vinho)),
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
                  Gap(15.h),
                  Divider(),
                  Gap(10.h),
                  Text(
                    "Collections",
                    style: AppTheme.subheadline,
                  ),
                  Gap(10.h),
                  ListTile(
                    key: Key('primeiro item'),
                    title:
                        Text('Add a collection', style: AppTheme.dividerfont),
                    trailing: Icon(Icons.add, color: AppTheme.nearlyBlack),
                    onTap: () {
                      createDialog(
                        context,
                        userData,
                        Categorias,
                        (List<String> updatedCategories) {
                          setState(() {
                            Categorias = updatedCategories;
                          });
                        },
                      );
                    },
                  ),
                  Expanded(
                      child: Scrollbar(
                    thumbVisibility: true,
                    child: ListView(children: [
                      ...Categorias.asMap()
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
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    onPressed: () {
                                      setState(() {
                                        selectedIndex = entry.key;
                                        showMyDialog(
                                          context,
                                          Categorias[selectedIndex],
                                          userData,
                                          selectedIndex,
                                          Categorias,
                                          (List<String> updatedCategories) {
                                            setState(() {
                                              Categorias = updatedCategories;
                                            });
                                          },
                                        );
                                      });
                                    },
                                    icon: Icon(Icons.edit,
                                        color: AppTheme.nearlyBlack),
                                  ),
                                  IconButton(
                                    onPressed: () {
                                      setState(() {
                                        selectedIndex = entry.key;
                                        userData['tabviews']
                                            .removeWhere((collection) {
                                          return collection.keys.first ==
                                              Categorias[selectedIndex];
                                        });
                                        Categorias.removeAt(entry.key);
                                      });
                                    },
                                    icon: Icon(Icons.delete, color: Colors.red),
                                  ),
                                ],
                              ),
                              onTap: () {},
                            ),
                          )
                          .toList(),
                    ]),
                  )),
                ],
              ),
            ),
          );
  }
}

Future<void> showMyDialog(
  BuildContext context,
  String categoria,
  Map<dynamic, dynamic> userData,
  int selectedIndex,
  List<String> Categorias,
  Function(List<String>) updateCategoriesCallback,
) async {
  TextEditingController categoriaController =
      TextEditingController(text: categoria);
  bool isEditing = false;
  List<String> selectedPostIds =
      List<String>.from(userData['tabviews'][selectedIndex][categoria]);

  return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
            backgroundColor: AppTheme.nearlyWhite,
            child: SingleChildScrollView(
              child: StatefulBuilder(
                builder: (BuildContext context, StateSetter setState) {
                  return Padding(
                    padding: EdgeInsets.all(8),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: isEditing
                                  ? TextField(
                                      controller: categoriaController,
                                      style: AppTheme.barapp,
                                      textAlign: TextAlign.center,
                                    )
                                  : Center(
                                      child: Row(
                                      mainAxisAlignment: MainAxisAlignment
                                          .center, // Adicionando mainAxisAlignment
                                      children: [
                                        Gap(40),
                                        Text(
                                          categoria,
                                          style: AppTheme.barapp,
                                          textAlign: TextAlign.center,
                                        ),
                                        IconButton(
                                          icon: Icon(
                                            Icons.edit,
                                            color: AppTheme.nearlyBlack,
                                          ),
                                          onPressed: () {
                                            setState(() {
                                              isEditing = true;
                                            });
                                          },
                                        ),
                                      ],
                                    )),
                            ),
                            IconButton(
                              onPressed: () {
                                userData['tabviews'][selectedIndex][categoria] =
                                    selectedPostIds;

                                Navigator.pop(context);
                              },
                              icon: Icon(
                                Icons.check,
                                color: AppTheme.nearlyBlack,
                              ),
                            ),
                          ],
                        ),
                        Gap(15.h),
                        FutureBuilder(
                          future: FirebaseFirestore.instance
                              .collection('posts')
                              .where('uid', isEqualTo: userData['uid'])
                              .get(),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }
                            final documents =
                                (snapshot.data! as QuerySnapshot).docs.toList();

                            final documentofiltrado = documents.where(
                                (document) => !(userData['tabviews']
                                        [selectedIndex] as Map<String, dynamic>)
                                    .values
                                    .where((value) =>
                                        value is List &&
                                        value.contains(document['postId']))
                                    .isNotEmpty);

                            return Column(children: [
                              SizedBox(
                                height: 100.h,
                                width: double.infinity,
                                child: GridView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: selectedPostIds.length,
                                  gridDelegate:
                                      SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 1,
                                  ),
                                  itemBuilder: (context, index) {
                                    return FutureBuilder(
                                      future: FirebaseFirestore.instance
                                          .collection('posts')
                                          .doc(selectedPostIds[index])
                                          .get(),
                                      builder: (context, snapshot) {
                                        if (!snapshot.hasData) {
                                          return const Center(
                                            child: CircularProgressIndicator(),
                                          );
                                        }
                                        return Stack(
                                          children: [
                                            Padding(
                                                padding: EdgeInsets.all(5),
                                                child: ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10.0),
                                                  child: Image.network(
                                                    snapshot.data!['photoUrls']
                                                        [0],
                                                    fit: BoxFit.fill,
                                                    width: double.infinity,
                                                    height: double.infinity,
                                                  ),
                                                )),
                                            Positioned(
                                              right: 2,
                                              child: InkWell(
                                                onTap: () {
                                                  setState(() {
                                                    selectedPostIds
                                                        .removeAt(index);
                                                  });
                                                },
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    color: AppTheme.vinho,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                  ),
                                                  child: Icon(Icons.delete,
                                                      size: 20),
                                                ),
                                              ),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  },
                                ),
                              ),
                              Gap(5),
                              Divider(),
                              Text("Add to collection",
                                  style: AppTheme.dividerfont),
                              Gap(10),
                              SizedBox(
                                  height: 350.h,
                                  child: GridView.builder(
                                    gridDelegate:
                                        SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 3,
                                      mainAxisSpacing: 8.0,
                                      crossAxisSpacing: 8.0,
                                      childAspectRatio: 1.0,
                                    ),
                                    itemCount: documents.length,
                                    itemBuilder: (context, index) {
                                      final document =
                                          documents.elementAt(index);

                                      return GestureDetector(
                                        child: Container(
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                              color: selectedPostIds.contains(
                                                      document['postId'])
                                                  ? AppTheme.vinho
                                                  : Colors.transparent,
                                              width: 4.0,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(10.0),
                                          ),
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(10.0),
                                            child: Image.network(
                                              document['photoUrls'][0]
                                                  .toString(),
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                        onTap: () {
                                          setState(() {
                                            String postId = document['postId'];
                                            if (!selectedPostIds
                                                .contains(postId)) {
                                              selectedPostIds.add(postId);
                                            } else {
                                              selectedPostIds.remove(postId);
                                            }
                                          });
                                        },
                                      );
                                    },
                                  ))
                            ]);
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
            ));
      }).then((value) {
    userData['tabviews'][selectedIndex].remove(categoria);
    userData['tabviews'][selectedIndex][categoriaController.text] =
        selectedPostIds;
    Categorias[Categorias.indexWhere((element) => element == categoria)] =
        categoriaController.text;
  });
}

Future<void> createDialog(
  BuildContext context,
  Map<dynamic, dynamic> userData,
  List<String> Categorias,
  Function(List<String>) updateCategoriesCallback,
) async {
  final TextEditingController collectionNameController =
      TextEditingController();
  List<String> selectedPostIds = [];

  return showDialog<void>(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
          backgroundColor: AppTheme.nearlyWhite,
          child: SingleChildScrollView(
            child: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                return Padding(
                  padding: EdgeInsets.all(8),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              "Create a collection",
                              style: AppTheme.barapp,
                              textAlign: TextAlign.center,
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              List<String> updatedCategories =
                                  _createLocalCollection(
                                collectionNameController.text,
                                selectedPostIds,
                                Categorias,
                                userData,
                              );

                              // Use the callback to update the state in the parent widget
                              updateCategoriesCallback(updatedCategories);

                              Navigator.pop(context, updatedCategories);
                            },
                            icon: Icon(
                              Icons.check,
                              color: AppTheme.nearlyBlack,
                            ),
                          ),
                        ],
                      ),
                      Gap(10.h),
                      Text("Collection's name:", style: AppTheme.dividerfont),
                      Gap(10),
                      Container(
                        width: 300.w,
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          child: TextField(
                            controller: collectionNameController,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.black,
                            ),
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: 'Write collection name...',
                              hintStyle: TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Divider(),
                      Gap(15.h),
                      Text("Add to collection", style: AppTheme.dividerfont),
                      Gap(10),
                      SizedBox(
                        height: 350.h,
                        child: FutureBuilder(
                          future: FirebaseFirestore.instance
                              .collection('posts')
                              .where('uid', isEqualTo: userData['uid'])
                              .get(),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }
                            final documents =
                                (snapshot.data! as QuerySnapshot).docs.toList();

                            return GridView.builder(
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                mainAxisSpacing: 8.0,
                                crossAxisSpacing: 8.0,
                                childAspectRatio: 1.0,
                              ),
                              itemCount: documents.length,
                              itemBuilder: (context, index) {
                                final document = documents.elementAt(index);

                                return GestureDetector(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10.0),
                                      border: Border.all(
                                        color: selectedPostIds
                                                .contains(document['postId'])
                                            ? AppTheme.vinho
                                            : Colors.transparent,
                                        width: 4.0,
                                      ),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(10.0),
                                      child: Image.network(
                                        document['photoUrls'][0].toString(),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  onTap: () {
                                    setState(() {
                                      if (selectedPostIds
                                          .contains(document['postId'])) {
                                        selectedPostIds
                                            .remove(document['postId']);
                                      } else {
                                        selectedPostIds.add(document['postId']);
                                      }
                                    });
                                  },
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ));
    },
  ).then((updatedCategories) {});
}
