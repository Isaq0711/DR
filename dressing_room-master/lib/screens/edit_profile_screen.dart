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
  List<Map<String, dynamic>> clothesData = [];

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

      var clothesSnap = await FirebaseFirestore.instance
          .collection('wardrobe')
          .doc(widget.uid)
          .collection('clothes')
          .get();

      clothesData.clear();

      for (var doc in clothesSnap.docs) {
        String clothId = doc['clothId'];

        var clothDataSnap = await FirebaseFirestore.instance
            .collection('clothes')
            .doc(clothId)
            .get();

        String photoUrl = clothDataSnap['photoUrl'];
        clothesData.add({
          'id': clothId,
          'photoUrl': photoUrl,
        });
      }
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
    setState(() {
      isLoading = true; // Set isLoading to true
    });

    String newUsername = _usernameController.text;
    Uint8List? newImage = _image;

    try {
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
    } catch (e) {
      showSnackBar(context, e.toString());
    } finally {
      setState(() {
        isLoading = false; // Set isLoading to false after all operations
      });
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
                title: InkWell(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          String selectedServer = 'cloud'; // Valor padrão

                          return StatefulBuilder(
                            builder: (context, setState) {
                              return AlertDialog(
                                title: Text('Selecione o Servidor'),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    RadioListTile<String>(
                                      title: Text('Servidor na Nuvem'),
                                      value: 'cloud',
                                      groupValue: selectedServer,
                                      onChanged: (value) {
                                        setState(() {
                                          selectedServer = value!;
                                        });
                                      },
                                    ),
                                    RadioListTile<String>(
                                      title: Text('Servidor Local'),
                                      value: 'local',
                                      groupValue: selectedServer,
                                      onChanged: (value) {
                                        setState(() {
                                          selectedServer = value!;
                                        });
                                      },
                                    ),
                                  ],
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: Text('Cancelar'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      if (selectedServer == 'local') {
                                        // Exibe outro pop-up para o campo de texto
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            TextEditingController
                                                localServerController =
                                                TextEditingController();
                                            return AlertDialog(
                                              title: Text(
                                                  'Digite o endereço do Servidor Local'),
                                              content: TextField(
                                                controller:
                                                    localServerController,
                                                decoration: InputDecoration(
                                                  labelText:
                                                      'Endereço do servidor local',
                                                ),
                                              ),
                                              actions: [
                                                TextButton(
                                                  onPressed: () {
                                                    Navigator.of(context).pop();
                                                  },
                                                  child: Text('Cancelar'),
                                                ),
                                                TextButton(
                                                  onPressed: () {
                                                    selectedServerAddress =
                                                        localServerController
                                                            .text; // Salva o endereço local
                                                    print(
                                                        'Servidor local selecionado: $selectedServerAddress');
                                                    Navigator.of(context)
                                                        .pop(); // Fecha o segundo diálogo
                                                    Navigator.of(context)
                                                        .pop(); // Fecha o primeiro diálogo
                                                  },
                                                  child: Text('Confirmar'),
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                      } else {
                                        selectedServerAddress =
                                            nuvem; // Usar servidor na nuvem
                                        print(
                                            'Servidor na nuvem selecionado: $selectedServerAddress');
                                        Navigator.of(context)
                                            .pop(); // Fecha o primeiro diálogo
                                      }
                                    },
                                    child: Text('Confirmar'),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      );
                    },
                    child: Text(
                      'Editar Perfil',
                      style: AppTheme.barapp.copyWith(shadows: [
                        Shadow(
                          blurRadius: 2.0,
                          color: Colors.black,
                        ),
                      ]),
                    )),
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
                          return SelectImageRedondaDialog(
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
                    "Coleções",
                    style: AppTheme.subheadline,
                  ),
                  Gap(10.h),
                  ListTile(
                    key: Key('primeiro item'),
                    title: Text('Adicionar uma pasta',
                        style: AppTheme.dividerfont),
                    trailing: Icon(Icons.add, color: AppTheme.nearlyBlack),
                    onTap: () {
                      createDialog(
                        context,
                        userData,
                        Categorias,
                        clothesData,
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
                                          clothesData,
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
  List<Map<String, dynamic>> clothesData,
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

                            final postDocuments =
                                (snapshot.data! as QuerySnapshot).docs.toList();

                            final combinedDocuments = postDocuments.map((doc) {
                              return {
                                'id': doc['postId'],
                                'photoUrl': doc['photoUrls'][0],
                                'isPost': true,
                              };
                            }).toList();

                            combinedDocuments.addAll(clothesData.map((cloth) {
                              return {
                                'id': cloth['id'],
                                'photoUrl': cloth['photoUrl'],
                                'isPost': false,
                              };
                            }));

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
                                      future: Future.wait([
                                        FirebaseFirestore.instance
                                            .collection('posts')
                                            .doc(selectedPostIds[index])
                                            .get(),
                                        FirebaseFirestore.instance
                                            .collection('clothes')
                                            .doc(selectedPostIds[index])
                                            .get(),
                                      ]),
                                      builder: (context, snapshot) {
                                        if (!snapshot.hasData) {
                                          return const Center(
                                            child: CircularProgressIndicator(),
                                          );
                                        }

                                        var postSnapshot = snapshot.data![0];
                                        var clothesSnapshot = snapshot.data![1];

                                        bool isPost = postSnapshot.exists &&
                                            postSnapshot
                                                .data()!
                                                .containsKey('photoUrls');

                                        return Stack(
                                          children: [
                                            Padding(
                                                padding: EdgeInsets.all(5),
                                                child: ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10.0),
                                                  child: Image.network(
                                                    isPost
                                                        ? postSnapshot.data()![
                                                            'photoUrls'][0]
                                                        : clothesSnapshot
                                                                .data()![
                                                            'photoUrl'],
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
                                    itemCount: combinedDocuments.length,
                                    itemBuilder: (context, index) {
                                      final document =
                                          combinedDocuments.elementAt(index);
                                      final id = document['id'];
                                      final isPost = document['isPost'];

                                      return GestureDetector(
                                        child: Container(
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                              color: selectedPostIds
                                                      .contains(document['id'])
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
                                              document['photoUrl'].toString(),
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                        onTap: () {
                                          setState(() {
                                            if (selectedPostIds.contains(id)) {
                                              selectedPostIds.remove(id);
                                            } else {
                                              selectedPostIds.add(id);
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
  List<Map<String, dynamic>> clothesData,
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
                              "            Criar uma coleção",
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
                      Text("Nome da pasta:", style: AppTheme.dividerfont),
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
                              hintText: 'Escreva o nome da pasta...',
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
                      Text("Adicionar para a pasta",
                          style: AppTheme.dividerfont),
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

                              final postDocuments =
                                  (snapshot.data! as QuerySnapshot)
                                      .docs
                                      .toList();

                              final combinedDocuments =
                                  postDocuments.map((doc) {
                                return {
                                  'id': doc['postId'],
                                  'photoUrl': doc['photoUrls'][0],
                                  'isPost': true,
                                };
                              }).toList();

                              combinedDocuments.addAll(clothesData.map((cloth) {
                                return {
                                  'id': cloth['id'],
                                  'photoUrl': cloth['photoUrl'],
                                  'isPost': false,
                                };
                              }));

                              return GridView.builder(
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 3,
                                  mainAxisSpacing: 8.0,
                                  crossAxisSpacing: 8.0,
                                  childAspectRatio: 1.0,
                                ),
                                itemCount: combinedDocuments.length,
                                itemBuilder: (context, index) {
                                  final document =
                                      combinedDocuments.elementAt(index);
                                  final id = document['id'];

                                  return GestureDetector(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                        border: Border.all(
                                          color: selectedPostIds.contains(id)
                                              ? AppTheme.vinho
                                              : Colors.transparent,
                                          width: 4.0,
                                        ),
                                      ),
                                      child: ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                        child: Image.network(
                                          document['photoUrl'].toString(),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                    onTap: () {
                                      setState(() {
                                        if (selectedPostIds.contains(id)) {
                                          selectedPostIds.remove(id);
                                        } else {
                                          selectedPostIds.add(id);
                                        }
                                      });
                                    },
                                  );
                                },
                              );
                            },
                          )),
                    ],
                  ),
                );
              },
            ),
          ));
    },
  ).then((updatedCategories) {});
}
