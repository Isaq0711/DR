import 'dart:typed_data';

import 'package:dressing_room/resources/firestore_methods.dart';
import 'package:dressing_room/screens/wardrobe_menu.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:dressing_room/utils/colors.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/cupertino.dart';
import 'package:dressing_room/screens/favorites_screen.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:dressing_room/screens/calendar.dart';
import 'package:gap/gap.dart';
import 'package:dressing_room/utils/utils.dart';

class OutfitScreen extends StatefulWidget {
  final String uid;
  final DateTime DATA;
  final int? troncoIndex;
  final int? pernasIndex;
  final int? pesIndex;

  const OutfitScreen(
      {Key? key,
      required this.uid,
      required this.DATA,
      required this.pernasIndex,
      required this.pesIndex,
      required this.troncoIndex})
      : super(key: key);

  @override
  _OutfitScreenState createState() => _OutfitScreenState();
}

class _OutfitScreenState extends State<OutfitScreen> {
  Future<WeatherModel> getWheather(bool isCurrentCity, String cityName) async {
    return await CallToWeatherApi().callWeatherAPi(
      isCurrentCity,
      cityName,
    );
  }

  void goToMenu() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => WardrobeMenu()),
      (route) => false,
    );
  }

  var userData = {};
  List<Map<String, dynamic>>? clothData;
  final TextEditingController _usernameController = TextEditingController();

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
  GlobalKey _globalKey = GlobalKey();
  bool notPrinting = true;
  bool isLoadingmenor = false;
  Uint8List? _capturedImage;
  int indexTempo = 0;
  DateTime? dataEscolhida;
  String? category;
  List<String> ids = [];

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

  Future<Map<String, List<String>>> getCategoryIds(
      List<String> clothItens) async {
    Map<String, List<String>> categoryIds = {};

    for (int i = 0; i < clothItens.length; i++) {
      String clothId = clothItens[i];

      var clothDataSnap = await FirebaseFirestore.instance
          .collection('clothes')
          .doc(clothId)
          .get();

      String tipo = clothDataSnap['category'];

      clothingItems.forEach((category, types) {
        if (types.contains(tipo)) {
          if (categoryIds.containsKey(category)) {
            categoryIds[category]!.add(clothId);
          } else {
            categoryIds[category] = [clothId];
          }
        }
      });
    }

    return categoryIds;
  }

  List<String> correspondingCategories = [];
  List<String> photoUrls = [];
  Map<String, List<String>> categoryItems = {};
  Map<String, List<String>> categoryIds = {};
  PageController _shirtController = PageController();
  PageController _pantsController = PageController();
  PageController _shoesController = PageController();
  Future<WeatherModel>? gettempo;
  @override
  void initState() {
    super.initState();
    setState(() {
      gettempo = getWheather(true, "");
    });
    indexTempo = (calculateIndexFromDate(widget.DATA));
    dataEscolhida = widget.DATA;
    initializeDateFormatting('pt_BR', null);
    _shirtController = PageController(initialPage: widget.troncoIndex ?? 0);
    _pantsController = PageController(initialPage: widget.pernasIndex ?? 0);
    _shoesController = PageController(initialPage: widget.pesIndex ?? 0);
    getData();
  }

  Future<Uint8List> takeScreenshot() async {
    RenderRepaintBoundary boundary =
        _globalKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
    ui.Image image = await boundary.toImage(
        pixelRatio: 3.0); // Altere o pixelRatio conforme necessário
    ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
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

  void showCalendar(context) async {
    DateTime? data = await showDialog<DateTime>(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            backgroundColor: AppTheme.cinza,
            child: CalendarScreen(title: "Choose Date", Dataaa: dataEscolhida!),
          );
        });

    if (data != null) {
      setState(() {
        dataEscolhida = data;
        indexTempo = calculateIndexFromDate(data);
      });
    }
  }

  int calculateIndexFromDate(DateTime chosenDate) {
    DateTime currentDate = DateTime.now();

    int differenceInDays = chosenDate.difference(currentDate).inDays;

    return differenceInDays;
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
      Map<String, List<String>> fetchedCategoryIds =
          await getCategoryIds(clothItens);

      setState(() {
        categoryItems = fetchedCategoryItems;
        categoryIds = fetchedCategoryIds;
      });
    } catch (e) {
      showSnackBar(context, e.toString());
      print(e);
    }

    setState(() {
      isLoading = false;
    });
  }

  Widget buildImageList(
      List<String>? images, PageController controller, int initialIndex) {
    if (images == null || images.isEmpty) {
      return SizedBox(); // ou qualquer outro widget de fallback apropriado
    }
    return SizedBox(
      height: 170.h,
      child: PageView.builder(
        controller: controller,
        itemCount: images.length,
        itemBuilder: (context, index) {
          return Stack(
            alignment: Alignment.center,
            children: [
              Image.network(
                images[index],
                fit: BoxFit.contain,
                width: 700.h,
              ),
              Positioned(
                  left: 45,
                  child: Visibility(
                    visible: notPrinting,
                    child: IconButton(
                      icon: Icon(Icons.arrow_back_ios, color: Colors.black),
                      onPressed: () {
                        if (index > 0) {
                          controller.previousPage(
                            duration: Duration(milliseconds: 300),
                            curve: Curves.ease,
                          );
                        } else {
                          controller.nextPage(
                            duration: Duration(milliseconds: 300),
                            curve: Curves.ease,
                          );
                        }
                      },
                    ),
                  )),
              Positioned(
                  right: 70,
                  top: 4,
                  child: Visibility(
                    visible: notPrinting,
                    child: IconButton(
                      icon: ImageIcon(
                        AssetImage(
                          'assets/CABIDE.png',
                        ),
                        color: AppTheme.nearlyBlack,
                        size: 30,
                      ),
                      onPressed: () {},
                    ),
                  )),
              Positioned(
                  right: 45,
                  child: Visibility(
                    visible: notPrinting,
                    child: IconButton(
                      icon: Icon(Icons.arrow_forward_ios, color: Colors.black),
                      onPressed: () {
                        if (index < images.length - 1) {
                          controller.nextPage(
                            duration: Duration(milliseconds: 300),
                            curve: Curves.ease,
                          );
                        } else {
                          controller.previousPage(
                            duration: Duration(milliseconds: 300),
                            curve: Curves.ease,
                          );
                        }
                      },
                    ),
                  )),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    String getIcon(int condition) {
      if (condition < 300) {
        return '🌩';
      } else if (condition < 400) {
        return '🌧';
      } else if (condition < 600) {
        return '☔️';
      } else if (condition < 700) {
        return '☃️';
      } else if (condition < 800) {
        return '🌫';
      } else if (condition == 800) {
        return '☀️';
      } else if (condition <= 804) {
        return '☁️';
      } else {
        return '🤷‍';
      }
    }

    return isLoading
        ? Center(
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
                TextButton(
                  onPressed: () async {
                    setState(() {
                      notPrinting = false;
                    });

                    await Future.delayed(Duration(milliseconds: 100));

                    try {
                      Uint8List? capturedImage = await takeScreenshot();

                      setState(() {
                        isLoadingmenor = true;
                      });

                      await FireStoreMethods().planLook(
                          capturedImage,
                          widget.uid,
                          dataEscolhida!,
                          categoryIds['Tronco']![
                              _shirtController.page!.round()],
                          categoryIds['Pernas']![
                              _pantsController.page!.round()],
                          categoryIds['Pés']![_shoesController.page!.round()]);

                      setState(() {
                        notPrinting = true;
                        isLoadingmenor = false;
                      });
                    } catch (e) {
                      print("Erro ao processar: $e");
                      showSnackBar(context, "Erro ao processar: $e");
                      setState(() {
                        isLoadingmenor = false;
                      });
                    }
                  },
                  child: Text(
                    "SAVE",
                    style: TextStyle(
                      color: Colors.blueAccent,
                      fontWeight: FontWeight.bold,
                      fontSize: 16.0,
                    ),
                  ),
                ),
              ],
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                setState(() {
                  _showFavorites(context);
                });
              },
              backgroundColor: AppTheme.vinho,
              elevation: 2.0,
              child: Icon(
                CupertinoIcons.heart_fill,
                color: AppTheme.cinza,
              ),
            ),
            body: isLoadingmenor
                ? LinearProgressIndicator()
                : Column(
                    children: [
                      Gap(10),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            indexTempo >= 40
                                ? SizedBox.shrink()
                                : FutureBuilder<WeatherModel>(
                                    future: gettempo,
                                    builder: (ctx, snapshot) {
                                      if (snapshot.connectionState ==
                                          ConnectionState.done) {
                                        if (snapshot.hasData) {
                                          final tempo =
                                              snapshot.data as WeatherModel;
                                          return Row(
                                            children: [
                                              Column(
                                                children: [
                                                  Text(
                                                    tempo.cityName[0],
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.black,
                                                    ),
                                                  ),
                                                  Text(
                                                    '${double.parse(tempo.temp[indexTempo]).round()}°C',
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                      color: Colors.black,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Gap(8),
                                              Text(
                                                getIcon(tempo
                                                    .condition[indexTempo]),
                                                style: TextStyle(fontSize: 25),
                                              ),
                                            ],
                                          );
                                        } else if (snapshot.connectionState ==
                                            ConnectionState.waiting) {
                                          return Center(
                                            child: CircularProgressIndicator(),
                                          );
                                        } else {
                                          return Center(
                                            child: Text(
                                                "${snapshot.connectionState} occurred",
                                                style: AppTheme.barapp),
                                          );
                                        }
                                      } else {
                                        return Center(
                                          child: Text(
                                            "Server timed out!",
                                            style: AppTheme.barapp,
                                          ),
                                        );
                                      }
                                    },
                                  ),
                            Gap(35),
                            FloatingActionButton.extended(
                              onPressed: () {
                                setState(() {});
                              },
                              backgroundColor: AppTheme.vinho,
                              elevation: 2.0,
                              label:
                                  Text("CANVAS", style: AppTheme.subtitlewhite),
                              icon: Icon(Icons.draw_outlined,
                                  color: Colors.white),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                                side: BorderSide(color: AppTheme.darkerText),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Gap(30),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              onPressed: () {},
                              icon: Icon(CupertinoIcons.heart,
                                  color: AppTheme.vinho),
                            ),
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
                              icon: Icon(Icons.calendar_today,
                                  color: AppTheme.vinho),
                            )
                          ],
                        ),
                      ),
                      Gap(15),
                      Column(
                        children: [
                          RepaintBoundary(
                            key: _globalKey,
                            child: Column(
                              children: [
                                buildImageList(categoryItems['Tronco'] ?? [],
                                    _shirtController, widget.troncoIndex!),
                                buildImageList(categoryItems['Pernas'] ?? [],
                                    _pantsController, widget.pernasIndex!),
                                buildImageList(categoryItems['Pés'] ?? [],
                                    _shoesController, widget.pesIndex!),
                                Gap(20),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
          );
  }
}
