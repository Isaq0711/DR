import 'dart:typed_data';

import 'package:dressing_room/resources/firestore_methods.dart';
import 'package:dressing_room/screens/wardrobe_menu.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:dressing_room/utils/colors.dart';
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:dressing_room/screens/favorites_screen.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:dressing_room/widgets/calendar.dart';
import 'my_wardrobe.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gap/gap.dart';
import 'package:dressing_room/utils/utils.dart';

class OutfitScreen extends StatefulWidget {
  final String uid;
  final DateTime DATA;
  final List<String>? TroncoList;
  final List<String>? PernasList;
  final List<String>? PesList;
  final List<String>? TroncoIds;
  final List<String>? PernasIds;
  final List<String>? PesIds;
  final List<int>? conditions;
  final List<String>? forecast;
  final String? cityName;

  final int? troncoIndex;
  final int? pernasIndex;
  final int? pesIndex;

  const OutfitScreen(
      {Key? key,
      required this.uid,
      required this.DATA,
      required this.TroncoList,
      required this.PernasList,
      required this.PesList,
      required this.TroncoIds,
      required this.PernasIds,
      required this.PesIds,
      required this.conditions,
      required this.forecast,
      required this.cityName,
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

  void _showWardrobe(BuildContext context, List<String>? images,
      PageController controller, int initialIndex) async {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
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
                                Expanded(
                                  child: Center(
                                    child: Text(
                                      '',
                                      style: AppTheme.barapp.copyWith(
                                        shadows: [
                                          Shadow(
                                            blurRadius: 2.0,
                                            color: Colors.black,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                IconButton(
                                  onPressed: () {
                                    Navigator.pop(context);
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
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            child: GridView.builder(
                              shrinkWrap: true,
                              itemCount: images!.length,
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                mainAxisSpacing: 10.0,
                              ),
                              itemBuilder: (context, index) {
                                bool isIndex = index == initialIndex;
                                return ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: isIndex
                                            ? AppTheme.vinho
                                            : Colors.transparent,
                                        width: 4.0,
                                      ),
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                    child: InkWell(
                                      child: Image.network(
                                        images![index],
                                        fit: BoxFit.fill,
                                      ),
                                      onTap: () {
                                        setState(() {
                                          controller.jumpToPage(index);
                                          initialIndex = index;
                                        });
                                      },
                                    ),
                                  ),
                                );
                              },
                            ),
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  var userData = {};
  List<Map<String, dynamic>>? clothData;
  final TextEditingController _usernameController = TextEditingController();

  bool isLoading = false;
  List<String>? pecasID;
  List<String>? pecasPhotoUrls;
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

  List<String> correspondingCategories = [];
  List<String> photoUrls = [];
  Map<String, List<String>> categoryItems = {};
  Map<String, List<String>> categoryIds = {};
  PageController _shirtController = PageController();
  PageController _pantsController = PageController();
  PageController _shoesController = PageController();

  @override
  void initState() {
    super.initState();
    setState(() {});
    indexTempo = (calculateIndexFromDate(widget.DATA));
    dataEscolhida = widget.DATA;
    initializeDateFormatting('pt_BR', null);
    _shirtController = PageController(initialPage: widget.troncoIndex ?? 0);
    _pantsController = PageController(initialPage: widget.pernasIndex ?? 0);
    _shoesController = PageController(initialPage: widget.pesIndex ?? 0);
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
            child: CalendarWidget(
              title: "Choose Date",
              Dataaa: dataEscolhida!,
              isWidget: true,
            ),
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
                        onPressed: () {
                          _showWardrobe(context, images, controller,
                              controller.page!.round());
                        },
                      ))),
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
                          widget.TroncoIds![_shirtController.page!.round()],
                          widget.PernasIds![_pantsController.page!.round()],
                          widget.PesIds![_shoesController.page!.round()]);

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
                  child: FirebaseAuth.instance.currentUser!.uid == widget.uid
                      ? Text(
                          "SALVAR",
                          style: TextStyle(
                            color: Colors.blueAccent,
                            fontWeight: FontWeight.bold,
                            fontSize: 16.0,
                          ),
                        )
                      : Text(
                          "SUGERIR",
                          style: TextStyle(
                            color: Colors.blueAccent,
                            fontWeight: FontWeight.bold,
                            fontSize: 16.0,
                          ),
                        ),
                )
              ],
            ),
            // floatingActionButton: FloatingActionButton(
            //   onPressed: () {
            //     setState(() {
            //       _showFavorites(context);
            //     });
            //   },
            //   backgroundColor: AppTheme.vinho,
            //   elevation: 2.0,
            //   child: Icon(
            //     CupertinoIcons.heart_fill,
            //     color: AppTheme.cinza,
            //   ),
            // ),
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
                                : widget.forecast != null &&
                                        widget.forecast!.isNotEmpty &&
                                        widget.conditions != null &&
                                        widget.conditions!.isNotEmpty &&
                                        indexTempo < widget.forecast!.length &&
                                        indexTempo < widget.conditions!.length
                                    ? Row(
                                        children: [
                                          Column(
                                            children: [
                                              Text(
                                                widget.cityName!,
                                                style: GoogleFonts.bebasNeue(
                                                  fontSize: 16,
                                                  letterSpacing: 1.7,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black,
                                                ),
                                              ),
                                              Text(
                                                '${double.parse(widget.forecast![indexTempo]).round()}°C',
                                                style: GoogleFonts.quicksand(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w500,
                                                  color: Colors.black,
                                                ),
                                              ),
                                            ],
                                          ),
                                          Gap(8),
                                          Text(
                                            getIcon(
                                                widget.conditions![indexTempo]),
                                            style: TextStyle(fontSize: 25),
                                          ),
                                        ],
                                      )
                                    : SizedBox.shrink(),
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
                                  color: Colors.transparent),
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
                      Gap(10.h),
                      Column(
                        children: [
                          RepaintBoundary(
                            key: _globalKey,
                            child: Column(
                              children: [
                                buildImageList(widget.TroncoList ?? [],
                                    _shirtController, widget.troncoIndex!),
                                buildImageList(widget.PernasList ?? [],
                                    _pantsController, widget.pernasIndex!),
                                buildImageList(widget.PesList ?? [],
                                    _shoesController, widget.pesIndex!),
                                Gap(10.h),
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
