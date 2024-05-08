import 'dart:math';
import 'package:dressing_room/screens/calendar.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:dressing_room/utils/colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:dressing_room/screens/outfit_screen.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:dressing_room/screens/favorites_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gap/gap.dart';
import 'package:dressing_room/utils/utils.dart';

class TinderScreen extends StatefulWidget {
  final String uid;

  const TinderScreen({Key? key, required this.uid}) : super(key: key);

  @override
  _TinderScreenState createState() => _TinderScreenState();
}

class _TinderScreenState extends State<TinderScreen> {
  var userData = {};
  List<Map<String, dynamic>>? clothData;
  final TextEditingController _usernameController = TextEditingController();
  final CardSwiperController controller = CardSwiperController();

  bool isLoading = false;
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
  String? category;
  List<String> ids = [];
  List<String> fotosUrls = [];
  List<String> clothItens = [];

  Future<Map<String, List<String>>> getCategoryItems(
      List<String> clothItens, List<String> photoUrls) async {
    Map<String, List<String>> categoryItems = {};

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
          if (categoryItems.containsKey(category)) {
            categoryItems[category]!.add(photoUrl);
          } else {
            categoryItems[category] = [photoUrl];
          }
        }
      });
    }

    return categoryItems;
  }

  List<String> correspondingCategories = [];
  DateTime? dataEscolhida;
  List<String> photoUrls = [];
  Map<String, List<String>> categoryItems = {};

  List<int> troncoIndexes = [];
  List<int> pernasIndexes = [];
  List<int> pesIndexes = [];
  late int troncoIndex;
  late int pernaIndex;
  late int pesIndex;

  @override
  void initState() {
    super.initState();
    dataEscolhida = DateTime.now();
    initializeDateFormatting('pt_BR', null);
    getData();
  }

  void showCalendar(context) async {
    DateTime? data = await showDialog<DateTime>(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
              backgroundColor: AppTheme.cinza,
              child:
                  CalendarScreen(title: "Choose Date", Dataaa: dataEscolhida!));
        });

    if (data != null) {
      setState(() {
        dataEscolhida = data;
      });
    }
  }

  void _showFavorites(context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Container(
            height: 650.h,
            child: Container(
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
                          child: Column(children: [
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
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            child: SizedBox(
                                height: 580.h,
                                child: FavoritesScreen(
                                  isShoppingBag: true,
                                )))
                      ]))
                    ])));
      },
    );
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

      var clothesSnap = await FirebaseFirestore.instance
          .collection('wardrobe')
          .doc(widget.uid)
          .collection('clothes')
          .get();

      clothItens.clear();
      photoUrls.clear();

      await Future.forEach(clothesSnap.docs, (doc) async {
        String clothId = doc['clothId'];

        clothItens.add(clothId);
        var clothDataSnap = await FirebaseFirestore.instance
            .collection('clothes')
            .doc(clothId)
            .get();

        String photoUrl = clothDataSnap['photoUrl'];

        photoUrls.add(photoUrl);
      });

      Map<String, List<String>> fetchedCategoryItems =
          await getCategoryItems(clothItens, photoUrls);

      setState(() {
        categoryItems = fetchedCategoryItems;

        troncoIndex = Random().nextInt(categoryItems['Tronco']!.length);
        pernaIndex = Random().nextInt(categoryItems['Pernas']!.length);
        pesIndex = Random().nextInt(categoryItems['Pés']!.length);
      });
    } catch (e) {
      showSnackBar(context, e.toString());
      print(e);
    }

    setState(() {
      isLoading = false;
    });
  }

  Widget buildImageList(List<String>? images, int Index) {
    if (images == null || images.isEmpty) {
      return SizedBox(); // or any other appropriate fallback widget
    }
    return SizedBox(
      height: 140.h,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Image.network(
            images[Index],
            fit: BoxFit.contain,
            width: 700.h,
          ),
        ],
      ),
    );
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
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: Icon(
                  Icons.arrow_back_ios,
                ),
              ),
              iconTheme: IconThemeData(color: AppTheme.vinho),
              backgroundColor: Colors.transparent,
              actions: [
                IconButton(
                    onPressed: () {
                      print(troncoIndex);
                      print(troncoIndexes);
                    },
                    icon: Icon(
                      shadows: <Shadow>[
                        Shadow(color: AppTheme.nearlyBlack, blurRadius: 5.0)
                      ],
                      CupertinoIcons.info,
                    ))
              ],
            ),
            body: Column(children: [
              Gap(10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: AppTheme.vinho,
                          child: Icon(Icons.wb_sunny, color: Colors.white),
                        ),
                        Gap(8),
                        Column(
                          children: [
                            Text(
                              'Sunny',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            Text(
                              '30°C',
                              style:
                                  TextStyle(fontSize: 16, color: Colors.black),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Gap(35),
                      Expanded(
                        child: Center(
                          child: Text(
                            '${DateFormat('dd', 'pt_BR').format(dataEscolhida!)} de ${DateFormat('MMMM', 'pt_BR').format(dataEscolhida!)} ',
                            style: AppTheme.subheadline,
                          ),
                        ),
                      ),
                      IconButton(
                          onPressed: () {
                            showCalendar(context);
                          },
                          icon:
                              Icon(Icons.calendar_today, color: AppTheme.vinho))
                    ],
                  )),
              Gap(7.h),
              Expanded(
                child: CardSwiper(
                  controller: controller,
                  cardsCount: categoryItems['Tronco']!.length *
                      categoryItems['Pernas']!.length *
                      categoryItems['Pés']!.length,
                  onSwipe: _onSwipe,
                  onUndo: _onUndo,
                  numberOfCardsDisplayed: 1,
                  backCardOffset: const Offset(40, 40),
                  padding: const EdgeInsets.all(24.0),
                  cardBuilder: (
                    context,
                    index,
                    horizontalThresholdPercentage,
                    verticalThresholdPercentage,
                  ) {
                    return Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12.0),
                        border:
                            Border.all(color: Colors.grey.shade600, width: 3.0),
                      ),
                      child: Column(
                        children: [
                          buildImageList(
                              categoryItems['Tronco'] ?? [], troncoIndex),
                          buildImageList(
                              categoryItems['Pernas'] ?? [], pernaIndex),
                          buildImageList(categoryItems['Pés'] ?? [], pesIndex),
                          Gap(20.h),
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Visibility(
                                  visible: troncoIndexes != null &&
                                      troncoIndexes.length > 0,
                                  child: FloatingActionButton(
                                    backgroundColor: AppTheme.vinho,
                                    onPressed: controller.undo,
                                    child: const Icon(Icons.undo_sharp),
                                  ),
                                ),
                                FloatingActionButton(
                                  backgroundColor: Colors.red[900],
                                  onPressed: () => controller
                                      .swipe(CardSwiperDirection.left),
                                  child: const Icon(Icons.close),
                                ),
                                FloatingActionButton(
                                  backgroundColor: Colors.green[900],
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => OutfitScreen(
                                                DATA: dataEscolhida!,
                                                uid: FirebaseAuth
                                                    .instance.currentUser!.uid,
                                                troncoIndex: troncoIndex,
                                                pernasIndex: pernaIndex,
                                                pesIndex: pesIndex,
                                              )),
                                    );
                                  },
                                  child: const Icon(Icons.check),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              )
            ]));
  }

  bool _onSwipe(
    int previousIndex,
    int? currentIndex,
    CardSwiperDirection direction,
  ) {
    debugPrint(
      'The card $previousIndex was swiped to the ${direction.name}. Now the card $currentIndex is on top',
    );

    setState(() {
      troncoIndexes.add(troncoIndex);
      pernasIndexes.add(pernaIndex);
      pesIndexes.add(pesIndex);

      // Gerar novos índices aleatórios
      troncoIndex = Random().nextInt(categoryItems['Tronco']!.length);
      pernaIndex = Random().nextInt(categoryItems['Pernas']!.length);
      pesIndex = Random().nextInt(categoryItems['Pés']!.length);
    });

    return true;
  }

  bool _onUndo(
    int? previousIndex,
    int currentIndex,
    CardSwiperDirection direction,
  ) {
    debugPrint(
      'The card $currentIndex was undod from the ${direction.name}',
    );

    setState(() {
      // Verificar se as listas não estão vazias antes de acessar o último elemento
      if (troncoIndexes.isNotEmpty &&
          pernasIndexes.isNotEmpty &&
          pesIndexes.isNotEmpty) {
        // Atribuir os últimos índices antes de removê-los das listas
        troncoIndex = troncoIndexes.last;
        pernaIndex = pernasIndexes.last;
        pesIndex = pesIndexes.last;

        // Remover os últimos índices das listas
        troncoIndexes.removeLast();
        pernasIndexes.removeLast();
        pesIndexes.removeLast();
      }
    });

    return true;
  }
}
