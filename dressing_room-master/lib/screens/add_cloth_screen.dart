import 'dart:typed_data';
import 'package:dressing_room/responsive/mobile_screen_layout.dart';
import 'package:dressing_room/responsive/responsive_layout.dart';
import 'package:flip_card/flip_card_controller.dart';
import 'package:dressing_room/resources/firestore_methods.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';
import 'package:flip_card/flip_card.dart';
import 'package:dressing_room/widgets/select_image_dialog.dart';
import 'package:dressing_room/utils/utils.dart';
import 'package:gap/gap.dart';
import 'package:dressing_room/widgets/tag_card.dart';
import 'package:dressing_room/providers/user_provider.dart';
import 'package:dressing_room/models/user.dart';
import 'package:dressing_room/widgets/friends_list.dart';
import 'package:dressing_room/utils/colors.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/rendering.dart';
import 'dart:ui' as ui;
import 'package:provider/provider.dart';
import 'package:image/image.dart' as img;
import 'package:flutter/services.dart';

class AddClothScreen extends StatefulWidget {
  const AddClothScreen({Key? key}) : super(key: key);

  @override
  _AddClothScreenState createState() => _AddClothScreenState();
}

class _AddClothScreenState extends State<AddClothScreen> {
  GlobalKey<FlipCardState> cardKey = GlobalKey<FlipCardState>();
  bool _isPaintingMode = false;
  bool isFront = true;
  bool isSelected = false;
  bool isPublic = true;
  GlobalKey _globalKey = GlobalKey();

  List<List<Offset>> _paintHistory = [];
  List<double> _sliderValues = [];
  String selectedCategory = 'TOP';
  String? selectedClothType;
  String categoria1 = 'Marcas de roupas presentes';
  String categoria2 = 'Tecido da roupa';
  String categoria3 = 'Locais ou ocasião';
  List<String>? marcas;
  List<String>? tecido;
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
  late Offset _draggedImagePosition;
  double _sliderValue = 25;
  double _scale = 1.0;
  List<Uint8List>? _files;
  late FlipCardController _flipCardController;
  bool isLoading = false;
  bool _isDraggingImage = false;
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _barCodeController = TextEditingController();
  late PageController _pageController;
  int _currentPageIndex = 0;
  Map<int, List<Offset>> _selectedPositionsMap = {};

  void clearImages() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (context) => const ResponsiveLayout(
          mobileScreenLayout: MobileScreenLayout(),
        ),
      ),
      (route) => false,
    );
  }

  void showCategoryDialog(BuildContext context, String category,
      Function(String?) setSelectedClothType) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Dialog(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(30),
                    bottom: Radius.circular(30),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Gap(10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Spacer(),
                        Text(category, style: AppTheme.title),
                        Spacer(),
                        IconButton(
                          icon: Icon(
                            Icons.check,
                            color: AppTheme.nearlyBlack,
                          ),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    ),
                    Gap(10),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.75,
                      child: ScrollbarTheme(
                        data: ScrollbarThemeData(
                          thumbColor: MaterialStateProperty.all(Colors.black45),
                        ),
                        child: Scrollbar(
                          thickness: 6,
                          thumbVisibility: true,
                          child: ListView.builder(
                            itemCount: clothingItems[category]!.length,
                            itemBuilder: (BuildContext context, int index) {
                              bool isSelected = selectedClothType ==
                                  clothingItems[category]![index];
                              return ListTile(
                                title: Text(
                                  clothingItems[category]![index],
                                  style: AppTheme.subheadline,
                                ),
                                trailing: isSelected
                                    ? Icon(Icons.check_box_outlined,
                                        color: AppTheme.nearlyBlack)
                                    : Icon(Icons.check_box_outline_blank,
                                        color: AppTheme.nearlyBlack),
                                onTap: () {
                                  setState(() {
                                    if (!isSelected) {
                                      selectedClothType =
                                          clothingItems[category]![index];
                                    } else {
                                      selectedClothType = null;
                                    }
                                    setSelectedClothType(
                                        selectedClothType); // Atualize o estado fora do diálogo
                                  });
                                },
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _saveImage(String uid) async {
    try {
      setState(() {
        isLoading = true;
      });
      if (_globalKey.currentContext != null) {
        RenderRepaintBoundary? boundary = _globalKey.currentContext!
            .findRenderObject() as RenderRepaintBoundary?;
        if (boundary != null) {
          ui.Image image = await boundary.toImage(pixelRatio: 1.0);
          ByteData? byteData =
              await image.toByteData(format: ui.ImageByteFormat.png);
          Uint8List pngBytes = byteData!.buffer.asUint8List();
          File tempFile2 = await saveBytesToFile(pngBytes);

          try {
            Uint8List? processedImage2 = await removeBg(tempFile2.path);
            setState(() {
              isLoading = true;
            });

            String res = await FireStoreMethods().uploadCloth(
                _descriptionController.text,
                processedImage2!,
                uid,
                selectedClothType,
                isPublic,
                _barCodeController.text,
                marcas,
                tecido);

            if (res == "success") {
              showSnackBar(context, 'Posted!');

              clearImages();
            } else {
              showSnackBar(context, res);
            }
          } catch (err) {
            showSnackBar(context, err.toString());
          }
        }
      }
    } catch (e) {
      showSnackBar(context, e.toString());
    }
  }

  void exibirTagCard(
    BuildContext context,
    String category,
  ) async {
    var result = await showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return TagCard(
          category: category,
        );
      },
    );

    if (result != null &&
        result['results'] != null &&
        result['category'] != null) {
      List<String> results = List<String>.from(result['results']);
      String categoriaa = result['category'];

      if (categoriaa == categoria1)
        setState(() {
          Set<String> uniqueResults = Set.from(results);

          marcas != null && marcas!.isNotEmpty
              ? marcas!.addAll(uniqueResults.difference(marcas!.toSet()))
              : marcas = results;
        });
      if (categoriaa == categoria2)
        setState(() {
          Set<String> uniqueResults = Set.from(results);
          tecido != null && tecido!.isNotEmpty
              ? tecido!.addAll(uniqueResults.difference(tecido!.toSet()))
              : tecido = results;
        });
    }
  }

  void _paintOnImage(Offset position) {
    if (_isPaintingMode) {
      setState(() {
        if (_isDraggingImage) {
          _draggedImagePosition += position;
        } else {
          Offset adjustedPosition = position - _draggedImagePosition;
          _selectedPositionsMap[_currentPageIndex]!.add(adjustedPosition);
          _sliderValues.add(_sliderValue);
        }
      });
    }
  }

  void _endPainting() {
    setState(() {
      if (!_isPaintingMode) return;
      _paintHistory.add(List.from(_selectedPositionsMap[_currentPageIndex]!));
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _selectImage(context);
    });
    _flipCardController = FlipCardController();

    _draggedImagePosition = Offset.zero;
    _pageController = PageController(
      initialPage: 0,
    );
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
        return SelectImageDialog1por1(
          onImageSelected: (Uint8List file) async {
            File tempFile = await saveBytesToFile(file);
            setState(() {
              _files ??= [];
              _files!.add(file);
              isLoading = true;
            });

            try {
              Uint8List? processedImage = await removeBg(tempFile.path);
              setState(() {
                _files!.removeLast();
                _files!.add(processedImage!);
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
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, _) {
        var user = userProvider.getUser;
        if (user != null) {
          return _buildContent(user);
        } else {
          return Container();
        }
      },
    );
  }

  Scaffold _buildContent(User user) {
    return _files == null
        ? Scaffold(
            body: Container(),
          )
        : Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              leading: IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: Icon(
                  Icons.arrow_back_ios,
                  color: AppTheme.nearlyBlack,
                ),
              ),
              bottom: PreferredSize(
                preferredSize: Size.fromHeight(40.h),
                child: Container(
                  width: double.infinity,
                  color: Colors.transparent,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      Spacer(),
                      IconButton(
                        icon: Icon(
                          Icons.undo,
                          color: _paintHistory.isNotEmpty
                              ? AppTheme.vinho
                              : Colors.grey,
                        ),
                        onPressed: _paintHistory.isNotEmpty
                            ? () {
                                setState(() {
                                  _sliderValues.removeRange(
                                      _paintHistory.last.length - 1,
                                      _sliderValues.length);
                                  _paintHistory.removeLast();
                                  _selectedPositionsMap[_currentPageIndex] =
                                      List.from(_paintHistory.isNotEmpty
                                          ? _paintHistory.last
                                          : []);
                                });
                                print(_sliderValues);
                              }
                            : null,
                      ),
                      if (_isPaintingMode) ...[
                        PopupMenuButton(
                          itemBuilder: (BuildContext context) {
                            return [
                              PopupMenuItem(
                                child: StatefulBuilder(
                                  builder: (BuildContext context,
                                      StateSetter setState) {
                                    return Row(
                                      children: [
                                        ImageIcon(
                                          AssetImage(
                                            'assets/BORRACHA.png',
                                          ),
                                          color: AppTheme.nearlyWhite,
                                        ),
                                        Expanded(
                                          child: Slider(
                                            value: _sliderValue,
                                            min: 10,
                                            max: 120,
                                            onChanged: (value) {
                                              setState(() {
                                                _sliderValue = value;
                                              });
                                            },
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                ),
                              ),
                            ];
                          },
                          child: Icon(Icons.circle, color: AppTheme.vinho),
                        ),
                      ],
                      IconButton(
                          icon: ImageIcon(
                              AssetImage(
                                'assets/BORRACHA.png',
                              ),
                              color: _isPaintingMode
                                  ? AppTheme.vinho
                                  : Colors.grey),
                          onPressed: () {
                            setState(() {
                              _isPaintingMode = !_isPaintingMode;
                              if (_isPaintingMode) {
                                _isDraggingImage = false;
                              }
                            });
                          }),
                      IconButton(
                        icon: Icon(Icons.my_location,
                            color: _isDraggingImage
                                ? AppTheme.vinho
                                : Colors.grey),
                        onPressed: () {
                          setState(() {
                            _isDraggingImage = !_isDraggingImage;
                            if (_isDraggingImage) {
                              _isPaintingMode = false;
                            }
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                isFront
                    ? IconButton(
                        onPressed: () {
                          _flipCardController.toggleCard();
                        },
                        icon: Icon(Icons.info, color: Colors.blue),
                      )
                    : IconButton(
                        onPressed: () {
                          if (selectedClothType != null) {
                            _saveImage(user.uid);
                          } else {
                            showSnackBar(
                                context, "Choose a category for your cloth");
                          }
                        },
                        icon: const Icon(
                          Icons.save,
                          color: Colors.blue,
                        ),
                      ),
              ],
            ),
            body: FlipCard(
                onFlip: () {
                  setState(() {
                    isFront = !isFront;
                  });
                },
                key: cardKey,
                controller: _flipCardController,
                fill: Fill.fillBack,
                direction: FlipDirection.HORIZONTAL,
                side: CardSide.FRONT,
                front: Card(
                    color: AppTheme.cinza,
                    child: Column(
                      children: <Widget>[
                        isLoading
                            ? LinearProgressIndicator()
                            : Flexible(
                                child: Center(
                                child: RepaintBoundary(
                                    key: _globalKey,
                                    child: SizedBox(
                                        height: 670.h,
                                        child: AspectRatio(
                                          aspectRatio: 9 / 16,
                                          child: Stack(children: [
                                            Container(
                                              color: AppTheme.cinza,
                                              child: PageView.builder(
                                                physics:
                                                    NeverScrollableScrollPhysics(),
                                                controller: _pageController,
                                                itemCount: _files!.length,
                                                onPageChanged: (int index) {
                                                  setState(() {
                                                    _currentPageIndex = index;
                                                  });
                                                },
                                                itemBuilder:
                                                    (context, pageIndex) {
                                                  _selectedPositionsMap
                                                      .putIfAbsent(
                                                          pageIndex, () => []);
                                                  return GestureDetector(
                                                    onTapDown: (details) {
                                                      if (_isPaintingMode) {
                                                        _paintOnImage(details
                                                            .localPosition);
                                                      } else if (!_isDraggingImage) {
                                                        // _flipCardController
                                                        //     .toggleCard();
                                                      }
                                                    },
                                                    onPanUpdate: (details) {
                                                      if (_isPaintingMode) {
                                                        _paintOnImage(details
                                                            .localPosition);
                                                        print(_sliderValues);
                                                        print(_sliderValue);
                                                      } else if (_isDraggingImage) {
                                                        setState(() {
                                                          _draggedImagePosition +=
                                                              details.delta;
                                                        });
                                                      }
                                                    },
                                                    onPanEnd: (details) {
                                                      _endPainting();
                                                    },
                                                    onTapUp: (details) {
                                                      _endPainting();
                                                    },
                                                    child: SizedBox(
                                                      child: Stack(
                                                        children: [
                                                          Transform.scale(
                                                            scale: _scale,
                                                            child: Stack(
                                                              children: [
                                                                Transform
                                                                    .translate(
                                                                  offset:
                                                                      _draggedImagePosition,
                                                                  child: Image
                                                                      .memory(
                                                                    _files![
                                                                        _currentPageIndex],
                                                                    fit: BoxFit
                                                                        .cover,
                                                                  ),
                                                                ),
                                                                Positioned.fill(
                                                                  child:
                                                                      CustomPaint(
                                                                    painter:
                                                                        _ImagePainter(
                                                                      image: _files![
                                                                          pageIndex],
                                                                      selectedPositions:
                                                                          _selectedPositionsMap[
                                                                              pageIndex]!,
                                                                      sliderValues:
                                                                          _sliderValues,
                                                                      imageOffset:
                                                                          _draggedImagePosition,
                                                                      scale:
                                                                          _scale,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                          Positioned.fill(
                                                            child: Container(
                                                              decoration:
                                                                  BoxDecoration(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            10),
                                                                border:
                                                                    Border.all(
                                                                  color: AppTheme
                                                                      .vinho,
                                                                ),
                                                              ),
                                                              // Seu conteúdo aqui
                                                            ),
                                                          ),
                                                          Positioned(
                                                            bottom: 5,
                                                            right: 30.w,
                                                            child: Row(
                                                              children: [
                                                                InkWell(
                                                                  child:
                                                                      Container(
                                                                    decoration: BoxDecoration(
                                                                        borderRadius:
                                                                            BorderRadius.circular(
                                                                                10),
                                                                        color: AppTheme
                                                                            .vinho),
                                                                    child: Icon(
                                                                        Icons
                                                                            .zoom_out,
                                                                        size:
                                                                            45),
                                                                  ),
                                                                  onTap: () {
                                                                    setState(
                                                                        () {
                                                                      _scale -=
                                                                          0.05;
                                                                    });
                                                                  },
                                                                ),
                                                                Gap(10),
                                                                InkWell(
                                                                  child: Container(
                                                                      decoration: BoxDecoration(
                                                                          borderRadius: BorderRadius.circular(
                                                                              10),
                                                                          color: AppTheme
                                                                              .vinho),
                                                                      child: Icon(
                                                                          Icons
                                                                              .zoom_in,
                                                                          size:
                                                                              45)),
                                                                  onTap: () {
                                                                    setState(
                                                                        () {
                                                                      _scale +=
                                                                          0.05;
                                                                    });
                                                                  },
                                                                )
                                                              ],
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  );
                                                },
                                              ),
                                            )
                                          ]),
                                        ))),
                              ))
                      ],
                    )),
                back: SingleChildScrollView(
                    child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: isLoading
                            ? LinearProgressIndicator()
                            : Container(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.grey,
                                  ),
                                  color: AppTheme.nearlyWhite,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Column(
                                  children: [
                                    Text(
                                      "Description",
                                      style: AppTheme.dividerfont,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: TextField(
                                        controller: _descriptionController,
                                        style: AppTheme.title,
                                        decoration: InputDecoration(
                                          hintText:
                                              "Type the name of the cloth..",
                                          hintStyle: AppTheme.title,
                                          border: InputBorder.none,
                                        ),
                                      ),
                                    ),
                                    Gap(10),
                                    Divider(
                                      color: AppTheme.cinza,
                                    ),
                                    Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          ElevatedButton(
                                            onPressed: () {
                                              setState(() {
                                                isPublic = !isPublic;
                                              });
                                            },
                                            style: ElevatedButton.styleFrom(
                                              primary: isPublic
                                                  ? AppTheme.vinho
                                                  : Colors.grey,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10.0),
                                              ),
                                            ),
                                            child: Text('Public',
                                                style: AppTheme.subtitlewhite),
                                          ),
                                          ElevatedButton(
                                            onPressed: () {
                                              setState(() {
                                                isPublic = !isPublic;
                                              });
                                            },
                                            style: ElevatedButton.styleFrom(
                                              primary: !isPublic
                                                  ? AppTheme.vinho
                                                  : Colors.grey,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10.0),
                                              ),
                                            ),
                                            child: Text('Private',
                                                style: AppTheme.subtitlewhite),
                                          ),
                                        ]),
                                    Gap(10),
                                    Divider(
                                      color: AppTheme.cinza,
                                    ),
                                    Text(
                                      "Category of the cloth",
                                      style: AppTheme.dividerfont,
                                    ),
                                    Gap(10),
                                    selectedClothType == null
                                        ? Wrap(
                                            spacing:
                                                10.0, // Espaçamento horizontal entre os botões
                                            runSpacing:
                                                5.0, // Espaçamento vertical entre os botões
                                            children: List.generate(
                                              clothingItems.length,
                                              (index) {
                                                final category = clothingItems
                                                    .keys
                                                    .elementAt(index);
                                                return SizedBox(
                                                  height: 50.0,
                                                  child: ElevatedButton(
                                                    onPressed: () {
                                                      setState(() {
                                                        selectedCategory =
                                                            category;
                                                        showCategoryDialog(
                                                            context, category,
                                                            (value) {
                                                          setState(() {
                                                            selectedClothType =
                                                                value;
                                                          });
                                                        });
                                                      });
                                                    },
                                                    style: ElevatedButton
                                                        .styleFrom(
                                                      primary:
                                                          selectedCategory ==
                                                                  category
                                                              ? AppTheme.vinho
                                                              : Colors.grey,
                                                      shape:
                                                          RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10.0),
                                                      ),
                                                    ),
                                                    child: Text(
                                                      category,
                                                      style: AppTheme
                                                          .subtitlewhite,
                                                    ),
                                                  ),
                                                );
                                              },
                                            ),
                                          )
                                        : Padding(
                                            padding: const EdgeInsets.all(10.0),
                                            child: Stack(
                                              children: [
                                                Container(
                                                  width: 120.w,
                                                  height: 50.h,
                                                  decoration: BoxDecoration(
                                                    color: AppTheme.vinho,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            15),
                                                  ),
                                                  child: Center(
                                                    child: Text(
                                                      selectedClothType!,
                                                      style: AppTheme
                                                          .subheadlinewhite,
                                                    ),
                                                  ),
                                                ),
                                                Positioned(
                                                  top: 0,
                                                  right: 0,
                                                  child: GestureDetector(
                                                    onTap: () {
                                                      setState(() {
                                                        selectedClothType =
                                                            null;
                                                      });
                                                    },
                                                    child: Container(
                                                      padding:
                                                          EdgeInsets.all(2),
                                                      decoration: BoxDecoration(
                                                        shape: BoxShape.circle,
                                                        color: Colors.white,
                                                      ),
                                                      child: Icon(
                                                        Icons.close,
                                                        color: Colors.black,
                                                        size: 18,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                    Gap(MediaQuery.of(context).size.height *
                                        0.003),
                                    Divider(
                                      color: AppTheme.cinza,
                                    ),
                                    Text(
                                      "Post information",
                                      style: AppTheme.dividerfont,
                                    ),
                                    Gap(10),
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Gap(10),
                                            Center(
                                              child: Text(
                                                "Marcas de roupas presentes:",
                                                style: AppTheme.title,
                                              ),
                                            ),
                                            Gap(MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                0.005),
                                            SizedBox(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.9,
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .height *
                                                  0.08,
                                              child: Row(
                                                children: [
                                                  // Item fixo
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            10.0),
                                                    child: Container(
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              0.2,
                                                      decoration: BoxDecoration(
                                                        color: AppTheme.cinza,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(15),
                                                      ),
                                                      child: Center(
                                                        child: IconButton(
                                                          onPressed: () {
                                                            exibirTagCard(
                                                                context,
                                                                categoria1);
                                                          },
                                                          icon: Icon(
                                                            Icons.add,
                                                            color: Colors.black,
                                                            size: 18,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  // Lista rolável
                                                  Expanded(
                                                    child:
                                                        marcas != null &&
                                                                marcas!
                                                                    .isNotEmpty
                                                            ? ListView.builder(
                                                                scrollDirection:
                                                                    Axis.horizontal,
                                                                itemCount:
                                                                    marcas!
                                                                        .length,
                                                                itemBuilder:
                                                                    (ctx,
                                                                        index) {
                                                                  return Padding(
                                                                    padding:
                                                                        const EdgeInsets
                                                                            .all(
                                                                            10.0),
                                                                    child:
                                                                        Stack(
                                                                      children: [
                                                                        Container(
                                                                          width:
                                                                              MediaQuery.of(context).size.width * 0.2,
                                                                          decoration:
                                                                              BoxDecoration(
                                                                            color:
                                                                                AppTheme.cinza,
                                                                            borderRadius:
                                                                                BorderRadius.circular(15),
                                                                          ),
                                                                          child:
                                                                              Center(
                                                                            child:
                                                                                Text(
                                                                              marcas![index],
                                                                              style: AppTheme.subtitle,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                        Positioned(
                                                                          top:
                                                                              0,
                                                                          right:
                                                                              0,
                                                                          child:
                                                                              GestureDetector(
                                                                            onTap:
                                                                                () {
                                                                              setState(() {
                                                                                marcas!.remove(marcas![index]);
                                                                              });
                                                                            },
                                                                            child:
                                                                                Container(
                                                                              padding: EdgeInsets.all(2),
                                                                              decoration: BoxDecoration(
                                                                                shape: BoxShape.circle,
                                                                                color: Colors.white,
                                                                              ),
                                                                              child: Icon(
                                                                                Icons.close,
                                                                                color: Colors.black,
                                                                                size: 12,
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  );
                                                                },
                                                              )
                                                            : Container(),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                        Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Gap(10),
                                              Center(
                                                child: Text(
                                                  "Tecido da roupa:",
                                                  style: AppTheme.title,
                                                ),
                                              ),
                                              SizedBox(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.9,
                                                height: MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                    0.08,
                                                child: Row(
                                                  children: [
                                                    // Item fixo
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              10.0),
                                                      child: Container(
                                                        width: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width *
                                                            0.2,
                                                        decoration:
                                                            BoxDecoration(
                                                          color: AppTheme.cinza,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(15),
                                                        ),
                                                        child: Center(
                                                          child: IconButton(
                                                            onPressed: () {
                                                              exibirTagCard(
                                                                  context,
                                                                  categoria2);
                                                            },
                                                            icon: Icon(
                                                              Icons.add,
                                                              color:
                                                                  Colors.black,
                                                              size: 18,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    // Lista rolável
                                                    Expanded(
                                                        child: tecido != null &&
                                                                tecido!
                                                                    .isNotEmpty
                                                            ? ListView.builder(
                                                                scrollDirection:
                                                                    Axis.horizontal,
                                                                itemCount:
                                                                    tecido!
                                                                        .length,
                                                                itemBuilder:
                                                                    (ctx,
                                                                        index) {
                                                                  return Padding(
                                                                    padding:
                                                                        const EdgeInsets
                                                                            .all(
                                                                            10.0),
                                                                    child:
                                                                        Stack(
                                                                      children: [
                                                                        Container(
                                                                          width:
                                                                              MediaQuery.of(context).size.width * 0.2,
                                                                          decoration:
                                                                              BoxDecoration(
                                                                            color:
                                                                                AppTheme.cinza,
                                                                            borderRadius:
                                                                                BorderRadius.circular(15),
                                                                          ),
                                                                          child:
                                                                              Center(
                                                                            child:
                                                                                Text(
                                                                              tecido![index],
                                                                              style: AppTheme.subtitle,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                        Positioned(
                                                                          top:
                                                                              0,
                                                                          right:
                                                                              0,
                                                                          child:
                                                                              GestureDetector(
                                                                            onTap:
                                                                                () {
                                                                              setState(() {
                                                                                tecido!.remove(tecido![index]);
                                                                              });
                                                                            },
                                                                            child:
                                                                                Container(
                                                                              padding: EdgeInsets.all(2),
                                                                              decoration: BoxDecoration(
                                                                                shape: BoxShape.circle,
                                                                                color: Colors.white,
                                                                              ),
                                                                              child: Icon(
                                                                                Icons.close,
                                                                                color: Colors.black,
                                                                                size: 12,
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  );
                                                                },
                                                              )
                                                            : Container()),
                                                  ],
                                                ),
                                              ),
                                            ]),
                                        Gap(10),
                                        Column(
                                          children: [
                                            Text("Código de Barras:",
                                                style: AppTheme.title),
                                            SizedBox(height: 10),
                                            Container(
                                              width: 350.w,
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 8),
                                              decoration: BoxDecoration(
                                                color: Colors.grey[200],
                                                borderRadius:
                                                    BorderRadius.circular(10.0),
                                              ),
                                              child: Row(
                                                children: [
                                                  Expanded(
                                                    child: TextField(
                                                      controller:
                                                          _barCodeController,
                                                      style: TextStyle(
                                                        fontSize: 14,
                                                        color: Colors.black,
                                                      ),
                                                      decoration:
                                                          InputDecoration(
                                                        border:
                                                            InputBorder.none,
                                                        hintText:
                                                            'Paste or write the barcode here...',
                                                        hintStyle: TextStyle(
                                                          fontSize: 14,
                                                          color: Colors.grey,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  IconButton(
                                                    onPressed: () {
                                                      // Adicione sua lógica aqui para o botão de envio
                                                    },
                                                    icon: Icon(
                                                      Icons.photo,
                                                      color:
                                                          AppTheme.nearlyBlack,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Gap(10)
                                          ],
                                        )
                                      ],
                                    ),
                                  ],
                                ))))));
  }
}

class _ImagePainter extends CustomPainter {
  final Uint8List image;
  final List<Offset> selectedPositions;
  final List<double> sliderValues;

  final double scale;
  final Offset imageOffset;

  _ImagePainter({
    required this.image,
    required this.selectedPositions,
    required this.sliderValues,
    required this.scale,
    required this.imageOffset,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (int i = 0; i < selectedPositions.length; i++) {
      final position = selectedPositions[i];
      final sliderValue = sliderValues[i];
      final paint = Paint()..color = AppTheme.cinza;
      final imagePosition = Offset(
        position.dx + imageOffset.dx,
        position.dy + imageOffset.dy,
      );
      canvas.drawCircle(imagePosition, sliderValue, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
