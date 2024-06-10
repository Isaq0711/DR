import 'package:flutter/material.dart';
import 'package:dressing_room/utils/colors.dart';
import 'package:dressing_room/utils/utils.dart';
import 'seepost.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gap/gap.dart';
import 'package:flutter/cupertino.dart';
import 'package:dressing_room/screens/outfit_screen.dart';

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

List<String> icons = [
  'icons8-head-profile-100.png',
  'icons8-pés-100.png',
  'icons8-camisa-100.png',
  'icons8-calças-100.png',
  'icons8-cinto-100.png',
  'icons8-joalheria-100.png',
  'icons8-vista-frontal-de-relógios-100.png',
  'icons8-toda-a-mão-100.png',
  'icons8-tipo-de-corpo-alto-100.png',
  'icons8-óculos-de-sol-100.png',
];

class Wardrobe extends StatefulWidget {
  final bool isDialog;
  final String uid;
  Wardrobe({Key? key, required this.isDialog, required this.uid})
      : super(key: key);
  @override
  _WardrobeState createState() => _WardrobeState();
}

class _WardrobeState extends State<Wardrobe>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String? category;
  List<String> ids = [];
  List<String> fotosUrls = [];
  List<String> clothItens = [];
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
            } else {
              categoryItems[category] = [photoUrl];
            }
          }
        });
      });
    }

    return categoryItems;
  }

  Future<void> getCategoryItemsAndIds(
      List<String> clothItens, List<String> photoUrls) async {
    Map<String, List<String>> tempCategoryItems = {};
    Map<String, List<String>> tempCategoryIds = {};

    for (int i = 0; i < clothItens.length; i++) {
      String clothId = clothItens[i];
      String photoUrl = photoUrls[i];

      var clothDataSnap = await FirebaseFirestore.instance
          .collection('clothes')
          .doc(clothId)
          .get();

      String tipo = clothDataSnap['category'];

      clothingItems.forEach((category, types) {
        if (types.contains(tipo)) {
          if (tempCategoryItems.containsKey(category)) {
            tempCategoryItems[category]!.add(photoUrl);
            tempCategoryIds[category]!.add(clothId);
          } else {
            tempCategoryItems[category] = [photoUrl];
            tempCategoryIds[category] = [clothId];
          }
        }
      });
    }

    setState(() {
      categoryItems = tempCategoryItems;
      categoryIds = tempCategoryIds;
    });
  }

  List<String> correspondingCategories = [];
  List<String> photoUrls = [];
  Map<String, List<String>> categoryItems = {};
  Map<String, List<String>> categoryIds = {};
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    getData();
    _tabController = TabController(length: 2, vsync: this);
  }

  getData() async {
    setState(() {
      isLoading = true;
    });
    try {
      var clothesSnap = await FirebaseFirestore.instance
          .collection('wardrobe')
          .doc(widget.uid)
          .collection('clothes')
          .get();

      clothItens.clear();
      photoUrls.clear();

      for (var doc in clothesSnap.docs) {
        String clothId = doc['clothId'];
        clothItens.add(clothId);

        var clothDataSnap = await FirebaseFirestore.instance
            .collection('clothes')
            .doc(clothId)
            .get();

        String photoUrl = clothDataSnap['photoUrl'];
        photoUrls.add(photoUrl);
      }

      await getCategoryItemsAndIds(clothItens, photoUrls);
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

  @override
  Widget build(BuildContext context) {
    final List<String> categories = clothingItems.keys.toList();

    return isLoading
        ? Center(
            child: CircularProgressIndicator(),
          )
        : widget.isDialog
            ? Container(
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
                          Gap(10), // Replaced Gap with SizedBox
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Gap(30),
                                Expanded(
                                  child: buildBeginning(_tabController),
                                ),
                                IconButton(
                                  onPressed: () async {
                                    ids.isEmpty
                                        ? Navigator.pop(context)
                                        : Navigator.pop(context, {
                                            'wardroberesultsID': ids,
                                            'wardroberesultsPhotos': fotosUrls,
                                          });
                                  },
                                  icon: Icon(
                                    Icons.check,
                                    color: AppTheme.nearlyBlack,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Gap(15),
                          Divider(color: AppTheme.nearlyWhite),

                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            child: SingleChildScrollView(
                              child: SizedBox(
                                height: 450.h,
                                child: BodyWidget(
                                  fotoUrls: fotosUrls,
                                  ids: ids,
                                  tabController: _tabController,
                                  category: category,
                                  categories: categories,
                                  categoryItems: categoryItems,
                                  categoryIds: categoryIds,
                                  clothItems: clothItens,
                                  photoUrls: photoUrls,
                                  isDialog: widget.isDialog,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )
            : Scaffold(
                appBar: AppBar(
                  toolbarHeight: 100.h,
                  leading: IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: Icon(
                      Icons.arrow_back_ios,
                      color: AppTheme.nearlyBlack,
                    ),
                  ),
                  title: buildBeginning(_tabController),
                  centerTitle: true,
                  backgroundColor: Colors.transparent,
                ),
                body: BodyWidget(
                    fotoUrls: fotosUrls,
                    ids: ids,
                    tabController: _tabController,
                    category: category,
                    categories: categories,
                    categoryItems: categoryItems,
                    categoryIds: categoryIds,
                    clothItems: clothItens,
                    photoUrls: photoUrls,
                    isDialog: widget.isDialog));
  }
}

Widget buildBeginning(TabController _tabController) {
  return Column(
    children: [
      Text(
        "WARDROBE",
        style: AppTheme.barapp.copyWith(
          shadows: [
            Shadow(
              blurRadius: 2.0,
              color: Colors.black,
            ),
          ],
        ),
      ),
      Gap(10), // Reintroduced Gap widget
      DefaultTabController(
        length: 2,
        initialIndex: 0,
        child: Column(
          children: [
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
                  indicatorColor: AppTheme.vinhoescuro,
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
                      ),
                    ),
                    Tab(
                      icon: ImageIcon(
                        AssetImage(
                          'assets/CABIDE.png',
                        ),
                        size: 40,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ],
  );
}

class BodyWidget extends StatefulWidget {
  final TabController tabController;
  String? category;
  final List<String> categories;
  final Map<String, List<String>> categoryItems;
  final Map<String, List<String>> categoryIds;
  final List<String> clothItems;
  final List<String> photoUrls;
  final bool isDialog;
  final List<String> ids;
  final List<String> fotoUrls;

  BodyWidget(
      {required this.tabController,
      required this.category,
      required this.categories,
      required this.categoryItems,
      required this.categoryIds,
      required this.clothItems,
      required this.photoUrls,
      required this.isDialog,
      required this.ids,
      required this.fotoUrls});

  @override
  _BodyWidgetState createState() => _BodyWidgetState();
}

class _BodyWidgetState extends State<BodyWidget> {
  @override
  Widget build(BuildContext context) {
    void addIDToList(String id) {
      setState(() {
        bool jatem = (widget.ids.contains(id));

        if (jatem) {
          widget.ids.remove(id);
        } else {
          widget.ids.add(id);
        }
      });
    }

    return TabBarView(
      controller: widget.tabController,
      children: [
        widget.category == null
            ? Center(
                child: Scrollbar(
                  thickness: 6,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: ListView(
                      shrinkWrap: true,
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            GridView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: widget.categories.length,
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
                                      widget.category =
                                          widget.categories[index];
                                    });
                                  },
                                  style: ElevatedButton.styleFrom(
                                    padding: EdgeInsets.all(20.0),
                                    backgroundColor: AppTheme.vinho,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                  ),
                                  child: ImageIcon(
                                    AssetImage(
                                      'assets/${icons[index]}',
                                    ),
                                    color: AppTheme.nearlyWhite,
                                    size: 40,
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
              )
            : Column(
                children: [
                  Gap(10),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          widget.category.toString(),
                          style: AppTheme.subheadline,
                          textAlign: TextAlign.center,
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            widget.category = null;
                          });
                        },
                        icon: Icon(
                          Icons.close,
                          color: AppTheme.nearlyBlack,
                        ),
                      )
                    ],
                  ),
                  Gap(10),
                  widget.categoryItems.containsKey(widget.category) &&
                          widget.categoryItems[widget.category]!.isNotEmpty
                      ? Expanded(
                          child: GridView.builder(
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              mainAxisSpacing: 8.h,
                              crossAxisSpacing: 8.h,
                              childAspectRatio: 1.0,
                            ),
                            itemCount:
                                widget.categoryItems[widget.category]!.length,
                            itemBuilder: (context, index) {
                              bool alreadyAdded = widget.fotoUrls.contains(
                                  widget
                                      .categoryItems[widget.category]![index]);
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
                                        widget.categoryItems[widget.category]![
                                            index],
                                        fit: BoxFit.fill,
                                      ),
                                      onTap: () {
                                        !widget.isDialog
                                            ? Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) => SeePost(
                                                    postId: widget.categoryIds[
                                                        widget
                                                            .category]![index],
                                                  ),
                                                ),
                                              )
                                            : setState(() {
                                                if (alreadyAdded) {
                                                  widget.fotoUrls.remove(widget
                                                          .categoryItems[
                                                      widget.category]![index]);
                                                  widget.ids.remove(widget
                                                          .categoryIds[
                                                      widget.category]![index]);
                                                } else {
                                                  widget.fotoUrls.add(widget
                                                          .categoryItems[
                                                      widget.category]![index]);
                                                  widget.ids.add(widget
                                                          .categoryIds[
                                                      widget.category]![index]);
                                                }
                                              });
                                      },
                                    ),
                                  ));
                            },
                          ),
                        )
                      : NoContent()
                ],
              ),
        widget.photoUrls.isEmpty
            ? NoContent()
            : GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 8.h,
                  crossAxisSpacing: 8.h,
                  childAspectRatio: 1.0,
                ),
                itemCount: widget.photoUrls.length,
                itemBuilder: (context, index) {
                  bool alreadyAdded =
                      widget.fotoUrls.contains(widget.photoUrls[index]);
                  return ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: alreadyAdded
                                ? AppTheme.vinho
                                : Colors.transparent,
                            width: 4.0,
                          ),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: InkWell(
                          child: Image.network(
                            widget.photoUrls[index],
                            fit: BoxFit.fill,
                          ),
                          onTap: () {
                            !widget.isDialog
                                ? Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => SeePost(
                                        postId: widget.clothItems[index],
                                      ),
                                    ),
                                  )
                                : setState(() {
                                    if (alreadyAdded) {
                                      widget.ids
                                          .remove(widget.clothItems[index]);
                                      widget.fotoUrls
                                          .remove(widget.photoUrls[index]);
                                    } else {
                                      widget.fotoUrls
                                          .add(widget.photoUrls[index]);
                                      widget.ids.add(widget.clothItems[index]);
                                    }
                                  });
                          },
                        ),
                      ));
                },
              ),
      ],
    );
  }
}

class NoContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Image.asset(
        'assets/NO-CONTENT.png',
        height:
            250.h, // Use 250.h para altura adaptável usando Flutter ScreenUtil
        width:
            250.w, // Use 250.w para largura adaptável usando Flutter ScreenUtil
      ),
    );
  }
}
