import 'dart:math';
import 'package:dressing_room/widgets/calendar.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dressing_room/resources/comn[1].dart';
import 'package:dressing_room/utils/colors.dart';
import 'package:dressing_room/models/clothes.dart';
import 'package:flutter/cupertino.dart';
import 'package:dressing_room/screens/outfit_screen.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:dressing_room/screens/favorites_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gap/gap.dart';
import 'dart:convert';
import 'package:dressing_room/utils/utils.dart';

class TinderScreen extends StatefulWidget {
  final String uid;
  final DateTime? datainicial;

  const TinderScreen({Key? key, required this.uid, required this.datainicial})
      : super(key: key);

  @override
  _TinderScreenState createState() => _TinderScreenState();
}

class _TinderScreenState extends State<TinderScreen> {
  Future<WeatherModel> getWheather(bool isCurrentCity, String cityName) async {
    return await CallToWeatherApi().callWeatherAPi(
      isCurrentCity,
      cityName,
    );
  }

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
  Map<String, List<String>> categoryIds = {};
  List<String> fotosUrls = [];
  List<String> clothItens = [];
  Future<void> enviarTexto() async {
    String statusSever = 'Server online';

    if (statusSever == 'Server online') {
      var clothesSnap = await FirebaseFirestore.instance
          .collection('wardrobe')
          .doc(widget.uid)
          .collection('clothes')
          .get();

      List<Map<String, dynamic>> clothesList = [];

      for (var doc in clothesSnap.docs) {
        String clothId = doc['clothId'];
        var clothDataSnap = await FirebaseFirestore.instance
            .collection('clothes')
            .doc(clothId)
            .get();

        ClothPraMandar cloth = ClothPraMandar.fromSnap(clothDataSnap);
        clothesList.add(cloth.toJson());
      }

      String clothesJson = jsonEncode(clothesList);

      try {
        // Construindo o payload para enviar
        Map<String, dynamic> payload = {
          'guardaRoupa': clothesJson,
          'tempo': '${tempo!.temp} ${tempo!.cityName[0]}',
          'uid': widget.uid,
        };

        String response =
            await sendText('GuardaRoupa', jsonEncode(payload), widget.uid);

        Map<String, dynamic> resultados = jsonDecode(response);

        String formattedResultados = '';
        resultados.forEach((key, value) {
          formattedResultados += '$key: $value\n';
        });

        print(formattedResultados);
      } catch (e) {
        print('Failed to send data: $e');
      }
    }
  }

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

  Future<WeatherModel>? gettempo;
  WeatherModel? tempo;
  List<String> correspondingCategories = [];
  DateTime? dataEscolhida;
  List<String> photoUrls = [];
  Map<String, List<String>> categoryItems = {};
  int indexTempo = 0;
  int cardsCount = 1;
  List<int> troncoIndexes = [];
  List<int> pernasIndexes = [];
  List<int> pesIndexes = [];
  int troncoIndex = 0;
  int pernaIndex = 0;
  int pesIndex = 0;

  @override
  void initState() {
    super.initState();
    setState(() {
      gettempo = getWheather(true, "");
    });
    indexTempo = (calculateIndexFromDate(widget.datainicial ?? DateTime.now()));
    dataEscolhida = widget.datainicial ?? DateTime.now();
    initializeDateFormatting('pt_BR', null);

    getData();
  }

  int calculateIndexFromDate(DateTime chosenDate) {
    DateTime currentDate = DateTime.now();

    int differenceInDays = chosenDate.difference(currentDate).inDays;

    return differenceInDays;
  }

  void getWeatherData() async {
    try {
      setState(() {
        isLoading = true;
      });
      tempo = await getWheather(true, "");
      indexTempo = calculateIndexFromDate(widget.datainicial ?? DateTime.now());
    } catch (e) {
      print(e);
      // Handle the error appropriately here
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void showCalendar(context) async {
    DateTime? data = await showDialog<DateTime>(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            backgroundColor: AppTheme.cinza,
            child: CalendarWidget(
              title: "Escolha uma data",
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
                  borderRadius: const BorderRadius.vertical(
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
                        const Gap(5),
                        Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: SizedBox(
                                height: 580.h,
                                child: const FavoritesScreen(
                                  isShoppingBag: true,
                                )))
                      ]))
                    ])));
      },
    );
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
      getWeatherData();

      Map<String, List<String>> fetchedCategoryItems =
          await getCategoryItems(clothItens, photoUrls);
      Map<String, List<String>> fetchedCategoryIds =
          await getCategoryIds(clothItens);

      setState(() {
        categoryItems = fetchedCategoryItems;
        categoryIds = fetchedCategoryIds;
        if (categoryItems.containsKey('Tronco') &&
            categoryItems['Tronco']!.isNotEmpty) {
          troncoIndex = Random().nextInt(categoryItems['Tronco']!.length);
        }
        if (categoryItems.containsKey('Pernas') &&
            categoryItems['Pernas']!.isNotEmpty) {
          pernaIndex = Random().nextInt(categoryItems['Pernas']!.length);
        }
        if (categoryItems.containsKey('Pés') &&
            categoryItems['Pés']!.isNotEmpty) {
          pesIndex = Random().nextInt(categoryItems['Pés']!.length);
        }
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
      return SizedBox(
        height: 70.h,
      ); // or any other appropriate fallback widget
    }
    return SizedBox(
      height: 120.h,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Image.network(
            images[Index],
            fit: BoxFit.cover,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (categoryItems['Tronco'] != null) {
      cardsCount *= categoryItems['Tronco']!.length;
    }
    if (categoryItems['Pernas'] != null) {
      cardsCount *= categoryItems['Pernas']!.length;
    }
    if (categoryItems['Pés'] != null) {
      cardsCount *= categoryItems['Pés']!.length;
    }

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
        ? const Center(
            child: CircularProgressIndicator(),
          )
        : Scaffold(
            appBar: AppBar(
              leading: IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(
                  Icons.arrow_back_ios,
                ),
              ),
              iconTheme: IconThemeData(color: AppTheme.vinho),
              backgroundColor: Colors.transparent,
              actions: [
                IconButton(
                    onPressed: () {
                      enviarTexto();
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
              const Gap(10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    indexTempo >= 40
                        ? const SizedBox.shrink()
                        : tempo != null
                            ? Row(
                                children: [
                                  Column(
                                    children: [
                                      Text(
                                        tempo!.cityName[0],
                                        style: GoogleFonts.bebasNeue(
                                          fontSize: 16,
                                          letterSpacing: 1.7,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                      ),
                                      Text(
                                        '${double.parse(tempo!.temp[indexTempo]).round()}°C',
                                        style: GoogleFonts.quicksand(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Gap(8),
                                  Text(
                                    getIcon(tempo!.condition[indexTempo]),
                                    style: const TextStyle(fontSize: 25),
                                  ),
                                ],
                              )
                            : Container(),
                    const Gap(35),
                    FloatingActionButton.extended(
                      onPressed: () {
                        setState(() {});
                      },
                      backgroundColor: AppTheme.vinho,
                      elevation: 2.0,
                      label: Text("CANVAS", style: AppTheme.subtitlewhite),
                      icon:
                          const Icon(Icons.draw_outlined, color: Colors.white),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        side: BorderSide(color: AppTheme.darkerText),
                      ),
                    ),
                  ],
                ),
              ),
              const Gap(15),
              Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Center(
                        child: InkWell(
                          child: Text(
                            '${DateFormat('dd', 'pt_BR').format(dataEscolhida!)} de ${DateFormat('MMMM', 'pt_BR').format(dataEscolhida!)} ',
                            style: AppTheme.subheadline,
                          ),
                          onTap: () {
                            showCalendar(context);
                          },
                        ),
                      ),
                      IconButton(
                          onPressed: () {
                            showCalendar(context);
                          },
                          icon: Icon(Icons.calendar_today,
                              color: AppTheme.vinho)),
                      const Spacer(),
                      InkWell(
                          onTap: () {
                            showTimePickerDialog(context);
                          },
                          child: Row(
                            children: [
                              Text(
                                DateFormat('HH:mm').format(DateTime.now()),
                                style: AppTheme.subheadline,
                              ),
                              Icon(Icons.av_timer, color: AppTheme.vinho),
                            ],
                          ))
                    ],
                  )),
              Gap(7.h),
              Expanded(
                child: CardSwiper(
                  controller: controller,
                  cardsCount: cardsCount,
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
                          const Spacer(),
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Visibility(
                                  visible: (troncoIndexes.length +
                                          pernasIndexes.length +
                                          pesIndexes.length) >
                                      0,
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
                                          TroncoList: categoryItems
                                                      .containsKey('Tronco') &&
                                                  categoryItems['Tronco']!
                                                      .isNotEmpty
                                              ? categoryItems['Tronco']!
                                              : [],
                                          PernasList: categoryItems
                                                      .containsKey('Pernas') &&
                                                  categoryItems['Pernas']!
                                                      .isNotEmpty
                                              ? categoryItems['Pernas']!
                                              : [],
                                          PesList: categoryItems
                                                      .containsKey('Pés') &&
                                                  categoryItems['Pés']!
                                                      .isNotEmpty
                                              ? categoryItems['Pés']!
                                              : [],
                                          TroncoIds: categoryIds
                                                      .containsKey('Tronco') &&
                                                  categoryIds['Tronco']!
                                                      .isNotEmpty
                                              ? categoryIds['Tronco']!
                                              : [],
                                          PernasIds: categoryIds
                                                      .containsKey('Pernas') &&
                                                  categoryIds['Pernas']!
                                                      .isNotEmpty
                                              ? categoryIds['Pernas']!
                                              : [],
                                          PesIds: categoryIds
                                                      .containsKey('Pés') &&
                                                  categoryIds['Pés']!.isNotEmpty
                                              ? categoryIds['Pés']!
                                              : [],
                                          conditions: tempo?.condition !=
                                                      null &&
                                                  tempo!.condition.isNotEmpty
                                              ? tempo!.condition
                                              : [],
                                          forecast: tempo?.temp != null &&
                                                  tempo!.temp.isNotEmpty
                                              ? tempo!.temp
                                              : [],
                                          cityName:
                                              tempo?.cityName.isNotEmpty ??
                                                      false
                                                  ? tempo!.cityName[0]
                                                  : "",
                                          DATA: dataEscolhida!,
                                          uid: widget.uid,
                                          troncoIndex: troncoIndex,
                                          pernasIndex: pernaIndex,
                                          pesIndex: pesIndex,
                                        ),
                                      ),
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
    print(categoryItems['Pernas']);

    setState(() {
      if (categoryItems.containsKey('Tronco') &&
          categoryItems['Tronco']!.isNotEmpty) {
        troncoIndexes.add(troncoIndex);
        troncoIndex = Random().nextInt(categoryItems['Tronco']!.length);
      }
      if (categoryItems.containsKey('Pernas') &&
          categoryItems['Pernas']!.isNotEmpty) {
        pernasIndexes.add(pernaIndex);
        pernaIndex = Random().nextInt(categoryItems['Pernas']!.length);
      }
      if (categoryItems.containsKey('Pés') &&
          categoryItems['Pés']!.isNotEmpty) {
        pesIndexes.add(pesIndex);
        pesIndex = Random().nextInt(categoryItems['Pés']!.length);
      }
    });

    return true;
  }

  Future<Map<String, DateTime>?> showTimePickerDialog(
      BuildContext context) async {
    return await showDialog<Map<String, DateTime>>(
      context: context,
      builder: (BuildContext context) {
        return TimePickerWidget();
      },
    );
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
      // Verifica se há índices salvos antes de desfazer a ação
      if (categoryItems.containsKey('Tronco') &&
          categoryItems['Tronco']!.isNotEmpty &&
          troncoIndexes.isNotEmpty) {
        troncoIndex = troncoIndexes.last;
        troncoIndexes.removeLast();
      }
      if (categoryItems.containsKey('Pernas') &&
          categoryItems['Pernas']!.isNotEmpty &&
          pernasIndexes.isNotEmpty) {
        pernaIndex = pernasIndexes.last;
        pernasIndexes.removeLast();
      }
      if (categoryItems.containsKey('Pés') &&
          categoryItems['Pés']!.isNotEmpty &&
          pesIndexes.isNotEmpty) {
        pesIndex = pesIndexes.last;
        pesIndexes.removeLast();
      }
    });

    return true;
  }
}

class TimePickerWidget extends StatefulWidget {
  @override
  _TimePickerWidgetState createState() => _TimePickerWidgetState();
}

class _TimePickerWidgetState extends State<TimePickerWidget> {
  late DateTime selectedStartTime;
  late DateTime selectedEndTime;

  @override
  void initState() {
    super.initState();
    List<DateTime> timeSlots = generateTimeSlots();
    selectedStartTime = timeSlots.first;
    selectedEndTime = selectedStartTime.add(const Duration(hours: 1));
  }

  // Função para gerar uma lista de horários de meia em meia hora
  List<DateTime> generateTimeSlots() {
    List<DateTime> times = [];
    DateTime now = DateTime.now().add(const Duration(minutes: 30));
    DateTime start = DateTime(
        now.year, now.month, now.day, now.hour, now.minute >= 30 ? 30 : 0);
    for (int i = 0; i < 48; i++) {
      times.add(start.add(Duration(minutes: 30 * i)));
    }
    return times;
  }

  String formatTime(DateTime time) {
    return DateFormat('HH:mm').format(time);
  }

  @override
  Widget build(BuildContext context) {
    List<DateTime> timeSlots = generateTimeSlots();

    return Dialog(
      backgroundColor: AppTheme.cinza,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Gap(5),
          Text(
            "Selecione o horário que usará o look",
            style: AppTheme.barapp.copyWith(shadows: [
              const Shadow(
                blurRadius: 1.0,
                color: Colors.black,
              ),
            ], fontSize: 15.h),
          ),
          const Gap(5),
          DropdownButton<DateTime>(
            dropdownColor: AppTheme.cinza,
            iconEnabledColor: AppTheme.vinho,
            value: timeSlots.contains(selectedStartTime)
                ? selectedStartTime
                : timeSlots.first,
            onChanged: (DateTime? newValue) {
              setState(() {
                selectedStartTime = newValue!;
                // Atualizar o horário final para ser 1h após o inicial
                selectedEndTime =
                    selectedStartTime.add(const Duration(hours: 1));
              });
            },
            items: timeSlots.map<DropdownMenuItem<DateTime>>((DateTime value) {
              return DropdownMenuItem<DateTime>(
                value: value,
                child: Text(
                  formatTime(value),
                  style: AppTheme.title,
                ),
              );
            }).toList(),
          ),
          const Gap(5),
          Text(
            "Até: ",
            style: AppTheme.dividerfont,
          ),
          const Gap(5),
          // Menu para selecionar o horário final
          DropdownButton<DateTime>(
            dropdownColor: AppTheme.cinza,
            iconEnabledColor: AppTheme.vinho,
            value: timeSlots.contains(selectedEndTime)
                ? selectedEndTime
                : selectedStartTime.add(const Duration(hours: 1)),
            onChanged: (DateTime? newValue) {
              setState(() {
                selectedEndTime = newValue!;
              });
            },
            items: timeSlots.map<DropdownMenuItem<DateTime>>((DateTime value) {
              return DropdownMenuItem<DateTime>(
                value: value,
                child: Text(
                  formatTime(value),
                  style: AppTheme.title,
                ),
              );
            }).toList(),
          ),
        ],
      ),
      // actions: [
      //   TextButton(
      //     onPressed: () {
      //       Navigator.of(context).pop(); // Fecha o diálogo sem fazer nada
      //     },
      //     child: Text('Cancelar'),
      //   ),
      //   TextButton(
      //     onPressed: () {
      //       Navigator.of(context).pop({
      //         'startTime': selectedStartTime,
      //         'endTime': selectedEndTime,
      //       }); // Fecha o diálogo e retorna os horários selecionados
      //     },
      //     child: Text('Confirmar'),
      //   ),
      // ],
    );
  }
}
