import 'package:dressing_room/resources/firestore_methods.dart';
import 'package:dressing_room/screens/my_wardrobe.dart';
import 'package:dressing_room/utils/utils.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:dressing_room/screens/search_screen.dart';
import 'package:dressing_room/screens/favorites_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:dressing_room/resources/storage_methods.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:typed_data';
import 'package:dressing_room/widgets/select_image_dialog.dart';
import 'package:gap/gap.dart';
import 'package:dressing_room/utils/colors.dart';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

class SuggestionCard extends StatefulWidget {
  const SuggestionCard({Key? key, required this.postId}) : super(key: key);

  final String? postId;

  @override
  _SuggestionCardState createState() => _SuggestionCardState();
}

class _SuggestionCardState extends State<SuggestionCard>
    with TickerProviderStateMixin {
  final TextEditingController _textEditingController = TextEditingController();
  String? selected;
  List<String> clothIds = [];
  List<dynamic> photoUrls = [];
  List<String> wardrobephotoUrls = [];
  String? category;

  List<String> clothItens = [];

  final Map<String, List<String>> clothingItems = {
    "Top (cabeça)": [
      "chapéu",
      "boné",
      "boina",
      "viseira",
      "véu",
      "bandana",
      "lenço",
      "turbante",
      "capuz",
      "máscara",
      "arco"
    ],
    "Pés": [
      "coturno",
      "tênis",
      "sapato",
      "sandália",
      "chinelo",
      "sapatênis",
      "bota",
      "salto",
      "tamancão",
      "sapatilha",
      "chuteira",
      "pantufas",
      "meia"
    ],
    "Tronco": [
      "blusa",
      "camisa",
      "camiseta",
      "regata",
      "camisa polo",
      "raglan",
      "suéter",
      "jaqueta",
      "corta-vento",
      "blazier",
      "top",
      "colete",
      "espartilho",
      "poncho",
      "toga"
    ],
    "Pernas": ["short", "bermuda", "calça", "saia", "leggin", "saia-calça"],
    "Cintura": ["cinto"],
    "Pescoço": [
      "gravata",
      "cordão",
      "colar",
      "gargantilha",
      "crachá",
      "cachecol"
    ],
    "Pulso": ["pulseira", "relógio"],
    "Mão": ["anel", "bolsa", "mala", "luva", "luva sem dedos"],
    "Body (corpo inteiro)": [
      "vestido",
      "sobretudo",
      "macacão",
      "jardineira",
      "avental",
      "túnica",
      "roupão"
    ],
    "Rosto": ["óculos"],
  };

  Map<String, List<String>> getCategoryItems(
      List<String> clothItens, List<String> photoUrls) {
    Map<String, List<String>> categoryItems = {};

    for (int i = 0; i < clothItens.length; i++) {
      String clothId = clothItens[i];
      String photoUrl = photoUrls[i];

      var clothDataSnap =
          FirebaseFirestore.instance.collection('clothes').doc(clothId).get();

      clothDataSnap.then((snapshot) {
        String tipo = snapshot['category'];

        clothingItems.forEach((category, types) {
          if (types.contains(tipo)) {
            if (categoryItems.containsKey(category)) {
              categoryItems[category]!.add(photoUrl);
              clothIds.add(clothId);
            } else {
              categoryItems[category] = [photoUrl];
            }
          }
        });
      });
    }

    return categoryItems;
  }

  Future<File> saveBytesToFile(Uint8List bytes) async {
    Directory tempDir = await getTemporaryDirectory();
    File tempFile = File('${tempDir.path}/temp_image.png');
    await tempFile.writeAsBytes(bytes);
    return tempFile;
  }

  _selectImage(BuildContext parentContext) async {
    showDialog(
      context: parentContext,
      builder: (BuildContext context) {
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
                    await showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return SelectImageDialog1por1(
                          onImageSelected: (Uint8List file) async {
                            File tempFile = await saveBytesToFile(file);
                            setState(() {
                              photoUrls ??= [];
                              photoUrls!.add(file);
                              isLoading = true; // Ativar indicador de progresso
                            });

                            try {
                              Uint8List? processedImage =
                                  await removeBg(tempFile.path);
                              setState(() {
                                photoUrls!.removeLast();
                                photoUrls!.add(processedImage);
                                isLoading = false;
                              });
                            } catch (e) {
                              print("Erro ao remover o fundo da imagem: $e");

                              setState(() {
                                isLoading = false;
                              });
                            }
                          },
                        );
                      },
                    );
                  }),
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
                    await showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return SelectImageDialog1por1(
                            onImageSelected: (Uint8List file) async {
                          setState(() {
                            photoUrls ??= [];
                            photoUrls!.add(file);
                          });
                        });
                      },
                    );
                  }),
            ],
          ),
        );
      },
    );
  }

  Future<void> uploadImagesAndReplaceUrls() async {
    List<dynamic> newUrls = [];
    for (dynamic item in photoUrls) {
      if (item is Uint8List) {
        // Se for Uint8List, faça o upload da imagem e adicione o URL à lista
        String photoUrl =
            await StorageMethods().uploadImageToStorage('posts', item, true);
        newUrls.add(photoUrl);
      } else {
        // Se não for Uint8List, mantenha o item na lista
        newUrls.add(item);
      }
    }
    setState(() {
      photoUrls = newUrls; // Atualiza a lista de URLs com os novos URLs
    });
  }

  getData() async {
    setState(() {
      isLoading = true;
    });
    try {
      var clothesSnap = await FirebaseFirestore.instance
          .collection('wardrobe')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection('clothes')
          .get();

      // Clear the existing list
      clothItens.clear();

      await Future.forEach(clothesSnap.docs, (doc) async {
        String clothId = doc['clothId'];

        clothItens.add(clothId);
        var clothDataSnap = await FirebaseFirestore.instance
            .collection('clothes')
            .doc(clothId)
            .get();

        String photoUrl = clothDataSnap['photoUrl'];

        wardrobephotoUrls.add(photoUrl);
      });

      setState(() {
        categoryItems = getCategoryItems(clothItens, wardrobephotoUrls);
      });
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

  List<String> correspondingCategories = [];
  Map<String, List<String>> categoryItems = {};
  List<String> postIds = [];
  bool isLoading = false;
  final TextEditingController commentEditingController =
      TextEditingController();

  @override
  void initState() {
    super.initState();

    getData();
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  Widget exibir_products(String uid) {
    late TabController _tabController;
    _tabController = TabController(length: 2, vsync: this);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Column(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                onPressed: () {
                  setState(() {
                    selected = null;
                  });
                },
                icon: Icon(
                  Icons.arrow_back_ios,
                  color: AppTheme.nearlyBlack,
                ),
              ),
            ),
            Container(
              color: Colors.transparent,
              child: RawScrollbar(
                mainAxisMargin: 5,
                trackVisibility: false,
                thumbVisibility: true,
                interactive: false,
                scrollbarOrientation: ScrollbarOrientation.top,
                child: TabBar(
                  controller: _tabController,
                  tabAlignment: TabAlignment.center,
                  dividerColor: Colors.transparent,
                  indicatorColor: Colors.transparent,
                  labelColor: AppTheme.vinho,
                  labelStyle: AppTheme.subheadline.copyWith(
                    shadows: [
                      Shadow(
                        blurRadius: .5,
                        color: Colors.black,
                      ),
                    ],
                  ),
                  unselectedLabelColor: const Color.fromARGB(255, 94, 93, 93),
                  tabs: [
                    Tab(icon: Icon(CupertinoIcons.heart)),
                    Tab(icon: Icon(CupertinoIcons.cart)),
                  ],
                ),
              ),
            ),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              // Conteúdo da primeira aba (Favorites)
              FutureBuilder(
                future: FirebaseFirestore.instance
                    .collection('favorites')
                    .doc(uid)
                    .collection('userFavorites')
                    .orderBy('dateAdded', descending: true)
                    .get(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(
                        color: Colors.blueAccent,
                      ),
                    );
                  }

                  List<QueryDocumentSnapshot> favorites =
                      (snapshot.data! as QuerySnapshot).docs;

                  Future<List<QueryDocumentSnapshot>> filterFavorites() async {
                    List<QueryDocumentSnapshot> validFavorites = [];
                    for (var favorite in favorites) {
                      String postId = favorite['postId'];
                      bool existsInProducts = (await FirebaseFirestore.instance
                              .collection('products')
                              .doc(postId)
                              .get())
                          .exists;

                      if (existsInProducts) {
                        validFavorites.add(favorite);
                      }
                    }
                    return validFavorites;
                  }

                  return FutureBuilder(
                    future: filterFavorites(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(
                          child: CircularProgressIndicator(
                            color: Colors.blueAccent,
                          ),
                        );
                      }

                      List<QueryDocumentSnapshot> validFavorites =
                          snapshot.data as List<QueryDocumentSnapshot>;

                      return SingleChildScrollView(
                        child: SizedBox(
                          height: 450.h,
                          child: GridView.builder(
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              mainAxisSpacing: 8.h,
                              crossAxisSpacing: 8.h,
                              childAspectRatio: 1.0,
                            ),
                            itemCount: validFavorites.length,
                            itemBuilder: (context, index) {
                              String postId = validFavorites[index]['postId'];
                              bool alreadyAdded = photoUrls.contains(
                                  validFavorites[index]['photoUrls'][0]);

                              return Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: alreadyAdded
                                          ? AppTheme.vinho
                                          : Colors.transparent,
                                      width: 4.0,
                                    ),
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: InkWell(
                                      child: Image.network(
                                        validFavorites[index]['photoUrls'][0],
                                        fit: BoxFit.fill,
                                      ),
                                      onTap: () {
                                        alreadyAdded
                                            ? setState(() {
                                                photoUrls.remove(
                                                    validFavorites[index]
                                                        ['photoUrls'][0]);
                                                postIds.remove(postId[index]);
                                              })
                                            : setState(() {
                                                photoUrls.add(
                                                    validFavorites[index]
                                                        ['photoUrls'][0]);
                                                postIds.add(postId[index]);
                                              });
                                      },
                                    ),
                                  ));
                            },
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
              // Conteúdo da segunda aba (Cart)
              FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('cart')
                    .doc(uid)
                    .get(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(
                        color: Colors.blueAccent,
                      ),
                    );
                  }

                  if (!snapshot.hasData || snapshot.data == null) {
                    return Center(
                      child: Text("No data found!"),
                    );
                  }

                  // Explicitly cast data to Map
                  Map<String, dynamic> data =
                      (snapshot.data as DocumentSnapshot).data()
                          as Map<String, dynamic>;

                  // Manipulate data and populate itens list
                  List<dynamic> itens = [];
                  if (data != null) {
                    data.entries.forEach((entry) {
                      var itemData = entry.value;
                      itemData['postId'] = entry.key; // Add the 'postId' field
                      itens.add(itemData);
                    });
                  }

                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: SizedBox(
                      height: 450,
                      child: GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          mainAxisSpacing: 8,
                          crossAxisSpacing: 8,
                          childAspectRatio: 1.0,
                        ),
                        itemCount: itens.length,
                        itemBuilder: (context, index) {
                          String postId = itens[index]['postId'];
                          bool alreadyAdded =
                              photoUrls.contains(itens[index]['photoUrl']);

                          return Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: alreadyAdded
                                      ? AppTheme.vinho
                                      : Colors.transparent,
                                  width: 4.0,
                                ),
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: InkWell(
                                  child: Image.network(
                                    itens[index]['photoUrl'],
                                    fit: BoxFit.fill,
                                  ),
                                  onTap: () {
                                    alreadyAdded
                                        ? setState(() {
                                            photoUrls.remove(
                                                itens[index]['photoUrl']);
                                            postIds.remove(postId);
                                          })
                                        : setState(() {
                                            photoUrls
                                                .add(itens[index]['photoUrl']);
                                            postIds.add(postId);
                                          });
                                  },
                                ),
                              ));
                        },
                      ),
                    ),
                  );
                },
              )
            ],
          ),
        ),
      ],
    );
  }

  Widget exibir_wardrobe(String uid) {
    final List<String> categories = clothingItems.keys.toList();
    late TabController _tabController;
    _tabController = TabController(length: 2, vsync: this);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Column(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                onPressed: () {
                  setState(() {
                    selected = null;
                  });
                },
                icon: Icon(
                  Icons.arrow_back_ios,
                  color: AppTheme.nearlyBlack,
                ),
              ),
            ),
            Container(
              color: Colors.transparent,
              child: RawScrollbar(
                mainAxisMargin: 5,
                trackVisibility: false,
                thumbVisibility: true,
                interactive: false,
                scrollbarOrientation: ScrollbarOrientation.top,
                child: TabBar(
                    controller: _tabController,
                    tabAlignment: TabAlignment.center,
                    dividerColor: Colors.transparent,
                    indicatorColor: Colors.transparent,
                    labelColor: AppTheme.vinho,
                    labelStyle: AppTheme.subheadline.copyWith(
                      shadows: [
                        Shadow(
                          blurRadius: .5,
                          color: Colors.black,
                        ),
                      ],
                    ),
                    unselectedLabelColor: const Color.fromARGB(255, 94, 93, 93),
                    tabs: [
                      Tab(
                          icon: ImageIcon(
                        AssetImage(
                          'assets/GAVETA.png',
                        ),
                        size: 32,
                      )),
                      Tab(
                          icon: ImageIcon(
                        AssetImage(
                          'assets/CABIDE.png',
                        ),
                        size: 40,
                      )),
                    ]),
              ),
            ),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              category == null
                  ? Center(
                      child: ScrollbarTheme(
                        data: ScrollbarThemeData(
                          thumbColor: MaterialStateProperty.all(Colors.black45),
                        ),
                        child: Scrollbar(
                          thickness: 6,
                          thumbVisibility: true,
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 20.0),
                            child: ListView(
                              shrinkWrap: true,
                              children: [
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    GridView.builder(
                                      shrinkWrap: true,
                                      physics: NeverScrollableScrollPhysics(),
                                      itemCount: categories.length,
                                      gridDelegate:
                                          SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 2,
                                        crossAxisSpacing: 10.0,
                                        mainAxisSpacing: 10.0,
                                      ),
                                      itemBuilder: (context, index) {
                                        return ElevatedButton(
                                          onPressed: () {
                                            setState(() {
                                              category = categories[index];
                                            });
                                          },
                                          style: ElevatedButton.styleFrom(
                                            padding: EdgeInsets.all(20.0),
                                            backgroundColor: AppTheme.vinho,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10.0),
                                            ),
                                          ),
                                          child: Text(
                                            categories[index],
                                            style: AppTheme.subheadlinewhite,
                                          ),
                                        );
                                      },
                                    ),
                                    Gap(20),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    )
                  : Column(
                      children: [
                        Gap(10),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                category.toString(),
                                style: AppTheme.subheadline,
                                textAlign: TextAlign
                                    .center, // Align text to the center
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                setState(() {
                                  category = null;
                                });
                                print(categoryItems);
                              },
                              icon: Icon(
                                Icons.close,
                                color: AppTheme.nearlyBlack,
                              ),
                            )
                          ],
                        ),
                        Gap(10),
                        categoryItems.containsKey(category) &&
                                categoryItems[category]!.isNotEmpty
                            ? Expanded(
                                child: GridView.builder(
                                  gridDelegate:
                                      SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 3,
                                    mainAxisSpacing: 8.h,
                                    crossAxisSpacing: 8.h,
                                    childAspectRatio: 1.0,
                                  ),
                                  itemCount: categoryItems[category]!.length,
                                  itemBuilder: (context, index) {
                                    bool alreadyAdded = photoUrls.contains(
                                        categoryItems[category]![index]);

                                    return Container(
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: alreadyAdded
                                                ? AppTheme.vinho
                                                : Colors.transparent,
                                            width: 4.0,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(10.0),
                                        ),
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          child: InkWell(
                                            child: Image.network(
                                              categoryItems[category]![index],
                                              fit: BoxFit.fill,
                                            ),
                                            onTap: () {
                                              alreadyAdded
                                                  ? setState(() {
                                                      photoUrls.remove(
                                                          categoryItems[
                                                                  category]![
                                                              index]);
                                                    })
                                                  : setState(() {
                                                      photoUrls.add(
                                                          categoryItems[
                                                                  category]![
                                                              index]);
                                                    });
                                            },
                                          ),
                                        ));
                                  },
                                ),
                              )
                            : Center(
                                child: Image.asset(
                                  'assets/NO-CONTENT.png',
                                  height: 200.h,
                                  width: 200.w,
                                ),
                              ),
                      ],
                    ),
              GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 8.h,
                  crossAxisSpacing: 8.h,
                  childAspectRatio: 1.0,
                ),
                itemCount: wardrobephotoUrls.length,
                itemBuilder: (context, index) {
                  bool alreadyAdded =
                      photoUrls.contains(wardrobephotoUrls[index]);

                  return Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: alreadyAdded
                              ? AppTheme.vinho
                              : Colors.transparent,
                          width: 4.0,
                        ),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: InkWell(
                          child: Image.network(
                            wardrobephotoUrls[index],
                            fit: BoxFit.fill,
                          ),
                          onTap: () {
                            alreadyAdded
                                ? setState(() {
                                    photoUrls.remove(wardrobephotoUrls[index]);
                                  })
                                : setState(() {
                                    photoUrls.add(wardrobephotoUrls[index]);
                                  });
                          },
                        ),
                      ));
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? Center(
            child: CircularProgressIndicator(color: Colors.blueAccent),
          )
        : Container(
            decoration: BoxDecoration(
              color: AppTheme.cinza,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(30),
              ),
            ),
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                    child: Column(
                  children: [
                    Container(
                      width: 40,
                      height: 6,
                      margin: const EdgeInsets.only(top: 16, bottom: 4),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(50),
                        color: AppTheme.nearlyWhite,
                      ),
                    ),
                    Gap(5),
                    Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Gap(30),
                            Expanded(
                                child: InkWell(
                              onTap: () {
                                print(postIds);
                              },
                              child: Text(
                                "Suggest",
                                style: AppTheme.barapp,
                                textAlign: TextAlign.center,
                              ),
                            )),
                            IconButton(
                              onPressed: () async {
                                setState(() {
                                  isLoading = true;
                                });

                                if (photoUrls.isEmpty) {
                                  Navigator.pop(context);
                                } else {
                                  await uploadImagesAndReplaceUrls(); // Espera o upload das imagens e a substituição dos URLs
                                  await FireStoreMethods().suggest(
                                      widget.postId,
                                      commentEditingController.text,
                                      FirebaseAuth.instance.currentUser!.uid,
                                      photoUrls,
                                      postIds,
                                      "posts");

                                  setState(() {
                                    isLoading = false;
                                  });

                                  Navigator.pop(context);
                                }
                              },
                              icon: Icon(
                                Icons.check,
                                color: AppTheme.nearlyBlack,
                              ),
                            ),
                          ],
                        )),
                    Gap(15),
                    photoUrls.length > 0
                        ? Padding(
                            padding: EdgeInsets.symmetric(horizontal: 5),
                            child: SizedBox(
                              height: 100.h,
                              child: RawScrollbar(
                                thumbVisibility: true,
                                thumbColor: Colors.grey,
                                radius: Radius.circular(20),
                                thickness: 5,
                                scrollbarOrientation:
                                    ScrollbarOrientation.bottom,
                                child: GridView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: photoUrls.length,
                                  gridDelegate:
                                      SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 1,
                                  ),
                                  itemBuilder: (context, index) {
                                    dynamic photoUrl = photoUrls[index];
                                    late Widget imageWidget;

                                    if (photoUrl is String) {
                                      imageWidget = Image.network(
                                        photoUrl,
                                        fit: BoxFit.fill,
                                        width: double.infinity,
                                        height: double.infinity,
                                      );
                                    } else if (photoUrl is Uint8List) {
                                      imageWidget = Image.memory(
                                        photoUrl,
                                        fit: BoxFit.fill,
                                        width: double.infinity,
                                        height: double.infinity,
                                      );
                                    }

                                    return Container(
                                      margin: EdgeInsets.only(right: 8.0),
                                      decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                        border: Border.all(
                                          color: Colors.transparent,
                                          width: 2.0,
                                        ),
                                      ),
                                      child: Stack(
                                        children: [
                                          ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(10.0),
                                            child: imageWidget,
                                          ),
                                          Positioned(
                                            child: InkWell(
                                              onTap: () {
                                                setState(() {
                                                  photoUrls.removeAt(index);
                                                });
                                              },
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  color: AppTheme.vinho,
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                                child: Icon(Icons.delete,
                                                    size: 20),
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          )
                        : SizedBox.shrink(),
                    Gap(5),
                    Divider(color: AppTheme.nearlyWhite),
                    Gap(15),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: SingleChildScrollView(
                          child: SizedBox(
                        height: photoUrls.isEmpty ? 400.h : 350.h,
                        child: selected == null
                            ? ListView(
                                children: [
                                  GridView.count(
                                    shrinkWrap: true,
                                    crossAxisCount: 2,
                                    crossAxisSpacing: 20.0,
                                    mainAxisSpacing: 20.0,
                                    children: [
                                      ElevatedButton(
                                        onPressed: () {
                                          setState(() {
                                            selected = "wardrobe";
                                          });
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppTheme.vinho,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10.0),
                                          ),
                                        ),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            ImageIcon(
                                              AssetImage(
                                                  'assets/CLOSET-FILL.png'),
                                              size: 40,
                                              color: AppTheme.nearlyWhite,
                                            ),
                                            Gap(10),
                                            Text('Wardrobe',
                                                style:
                                                    AppTheme.subheadlinewhite),
                                          ],
                                        ),
                                      ),
                                      ElevatedButton(
                                        onPressed: () {
                                          setState(() {
                                            selected = "products";
                                          });
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppTheme.vinho,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10.0),
                                          ),
                                        ),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              CupertinoIcons.bag_fill,
                                              size: 40,
                                              color: AppTheme.nearlyWhite,
                                            ),
                                            Gap(10),
                                            Text('Products',
                                                style:
                                                    AppTheme.subheadlinewhite),
                                          ],
                                        ),
                                      ),
                                      ElevatedButton(
                                        onPressed: () {
                                          setState(() {
                                            selected = "search";
                                          });
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppTheme.vinho,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10.0),
                                          ),
                                        ),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              CupertinoIcons.search,
                                              size: 40,
                                              color: AppTheme.nearlyWhite,
                                            ),
                                            Gap(10),
                                            Text('Search',
                                                style:
                                                    AppTheme.subheadlinewhite),
                                          ],
                                        ),
                                      ),
                                      ElevatedButton(
                                        onPressed: () {
                                          _selectImage(context);
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppTheme.vinho,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10.0),
                                          ),
                                        ),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.upload_file_rounded,
                                              size: 40,
                                              color: AppTheme.nearlyWhite,
                                            ),
                                            Gap(10),
                                            Text('Upload',
                                                style:
                                                    AppTheme.subheadlinewhite),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              )
                            : selected == 'wardrobe'
                                ? exibir_wardrobe(
                                    FirebaseAuth.instance.currentUser!.uid)
                                : selected == 'search'
                                    ? Container() // replace `container` with the actual widget you want to display
                                    : selected == 'products'
                                        ? SingleChildScrollView(
                                            // Wrap with SingleChildScrollView
                                            child: SizedBox(
                                              height: 450.h,
                                              child: exibir_products(
                                                  FirebaseAuth.instance
                                                      .currentUser!.uid),
                                            ),
                                          )
                                        : Container(), // You might want to handle other cases
                      )),
                    )
                  ],
                )),
                SafeArea(
                  child: Container(
                    height: kToolbarHeight,
                    margin: EdgeInsets.only(
                      bottom: MediaQuery.of(context).viewInsets.bottom,
                    ),
                    padding: const EdgeInsets.only(left: 16, right: 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 16, right: 8),
                            child: TextField(
                              controller: commentEditingController,
                              style: AppTheme.title,
                              decoration: InputDecoration(
                                hintText: 'Talk about your suggestion...',
                                hintStyle: AppTheme.subtitle,
                                border: InputBorder.none,
                              ),
                              maxLines: null,
                              textInputAction: TextInputAction.newline,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
  }
}
