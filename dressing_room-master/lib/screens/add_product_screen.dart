import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:dressing_room/providers/user_provider.dart';
import 'package:dressing_room/widgets/select_image_dialog.dart';
import 'package:dressing_room/models/user.dart';
import 'package:provider/provider.dart';
import 'package:dressing_room/resources/storage_methods.dart';
import 'package:flip_card/flip_card.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:dressing_room/utils/colors.dart';
import 'package:dressing_room/models/products.dart';
import 'package:dressing_room/resources/firestore_methods.dart';
import 'package:gap/gap.dart';
import 'package:dressing_room/utils/utils.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:dressing_room/responsive/mobile_screen_layout.dart';
import 'package:dressing_room/responsive/responsive_layout.dart';
import 'package:flip_card/flip_card_controller.dart';

class AddProductScreen extends StatefulWidget {
  final String uid;
  final Uint8List? image;

  final String storename;
  final String storephoto;

  AddProductScreen(
      {Key? key,
      required this.uid,
      this.image,
      required this.storename,
      required this.storephoto})
      : super(key: key);

  @override
  _AddPostScreenState createState() => _AddPostScreenState();
}

enum SwitchOption { optionA, optionB }

class _AddPostScreenState extends State<AddProductScreen> {
  late FlipCardController _flipCardController;

  bool isFront = true;
  final ScrollController _scrollController = ScrollController();
  int lastSelectedSize = -1;
  int indexDaCategoria = 2;
  late PageController _pageController;
  late PageController _photoController;
  String selectedCategory = 'Tronco';
  String? selectedClothType;
  List<Uint8List>? _files;
  bool isLoading = false;
  bool vitrine = false;
  bool promocoes = false;
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _variationController = TextEditingController();
  TextEditingController itemCountController = TextEditingController();
  TextEditingController itempriceController = TextEditingController();
  TextEditingController itemdescriptionController = TextEditingController();
  int _currentPageIndex = 0;
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

  Map<int, VariationInfo> variation = {};
  int currentPhotoIndex = 0;
  String selectedOption = '';
  @override
  void initState() {
    super.initState();
    _flipCardController = FlipCardController();

    _files = [];
    variation[_currentPageIndex] = VariationInfo(
      photoUrls: [], // Lista de URLs de fotos inicialmente vazia
      variationdescription: "", // Descrição inicial da variação
      itemCount: 0, // Quantidade inicial de itens
      sizesAvailable: [], // Lista de tamanhos disponíveis inicialmente vazia
      photos: [], // Inicializa com as imagens selecionadas
      price: null, // Preço inicial
    );
    _pageController = PageController(initialPage: _currentPageIndex);
    _photoController = PageController(initialPage: 0);

    if (widget.image == null) {
      WidgetsBinding.instance?.addPostFrameCallback((_) {
        _selectImage(context, 0);
      });
    } else {
      _files!.add(widget.image!);
    }
  }

  _selectImage(BuildContext parentContext, int variationIndex) async {
    showDialog(
      context: parentContext,
      builder: (BuildContext context) {
        return Selectimageinitial916(
          onImageSelected: (Uint8List file) {
            setState(() {
              _files ??= [];
              _files!.add(file);

              if (variation.containsKey(variationIndex)) {
                variation[variationIndex]!.photos.add(file);
              } else {
                variation[variationIndex] = VariationInfo(
                  photoUrls: [],
                  variationdescription: "", // Descrição da variação
                  itemCount: 1,
                  sizesAvailable: [], // Tamanhos disponíveis inicialmente
                  photos: [file],
                  price: null,
                );
                setState(() {
                  _currentPageIndex++;
                  _pageController.jumpToPage(_currentPageIndex);
                });
              }
            });
          },
        );
      },
    );
  }

  _selectmoreImage(BuildContext parentContext, int variationIndex) async {
    showDialog(
      context: parentContext,
      builder: (BuildContext context) {
        return Selectimageinitial916(
          onImageSelected: (Uint8List file) {
            setState(() {
              _files ??= [];
              _files!.add(file);

              if (variation.containsKey(variationIndex)) {
                variation[variationIndex]!.photos.add(file);
                currentPhotoIndex++;
                setState(() {
                  _photoController.jumpToPage(currentPhotoIndex);
                });
              }
            });
          },
        );
      },
    );
  }

  void _scrollDown() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: Duration(seconds: 1),
      curve: Curves.fastOutSlowIn,
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

  void postImages(String uid, String username, String profImage) async {
    setState(() {
      isLoading = true;
    });

    try {
      List<Map<String, dynamic>> variations = [];

      for (int i = 0; i < variation.length; i++) {
        String? variationdescription = variation[i]?.variationdescription;
        int? itemCount = variation[i]?.itemCount;
        List<String>? sizesAvailable = variation[i]?.sizesAvailable;

        double? price = variation[i]?.price;

        List<String> photoUrls = [];

        if (variation.containsKey(i) && variation[i]!.photos.isNotEmpty) {
          for (Uint8List photo in variation[i]!.photos) {
            String photoUrl = await StorageMethods()
                .uploadImageToStorage('products', photo, true);
            photoUrls.add(photoUrl);
          }
        }

        if (sizesAvailable != null && sizesAvailable.isNotEmpty) {
          List<String> categoryOrder = categorySizes[selectedCategory] ?? [];

          sizesAvailable.sort((a, b) {
            int indexA = categoryOrder.indexOf(a);
            int indexB = categoryOrder.indexOf(b);

            return indexA.compareTo(indexB);
          });
        }

        variations.add({
          'variationdescription': variationdescription,
          'itemCount': itemCount,
          'sizesAvailable': sizesAvailable,
          'price': price,
          'photoUrls': photoUrls,
        });
      }

      String res = await FireStoreMethods().uploadProduct(
        _descriptionController.text,
        [],
        uid,
        username,
        profImage,
        variations,
        selectedCategory,
        selectedClothType!,
        vitrine,
        promocoes,
      );

      if (res == "success") {
        showSnackBar(context, 'Posted!');
        clearImages();
      } else {
        showSnackBar(context, res);
      }
    } catch (err) {
      showSnackBar(context, err.toString());
    }

    setState(() {
      isLoading = false;
    });
  }

  void _onClothTypeSelected(String clothType) {
    setState(() {
      selectedClothType = clothType;
      selectedCategory = categorySizes[clothType] as String? ?? 'Outros';
    });
  }

  void goToNextImage() {
    setState(() {
      if (variation[_currentPageIndex] != null) {
        currentPhotoIndex++;
        if (currentPhotoIndex >= variation[_currentPageIndex]!.photos.length) {
          currentPhotoIndex = 0;
        }
      }
    });
  }

  void goToPreviousImage() {
    setState(() {
      if (variation[_currentPageIndex] != null) {
        currentPhotoIndex--;
        if (currentPhotoIndex < 0) {
          currentPhotoIndex = variation[_currentPageIndex]!.photos.length - 1;
        }
      }
    });
  }

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

  void deleteCurrentImage() {
    setState(() {
      if (variation.isNotEmpty && variation[_currentPageIndex] != null) {
        variation[_currentPageIndex]!.photos.removeAt(currentPhotoIndex);

        if (variation[_currentPageIndex]!.photos.isEmpty) {
          variation.remove(_currentPageIndex);

          // Reindexa as variações após a remoção
          Map<int, VariationInfo> updatedVariation = {};
          int newIndex = 0;
          variation.forEach((index, variationInfo) {
            updatedVariation[newIndex] = variationInfo;
            newIndex++;
          });
          variation = updatedVariation;

          if (variation.isEmpty) {
            _selectImage(context, 0);
            return;
          } else {
            if (_currentPageIndex > 0) {
              setState(() {
                _currentPageIndex--;
              });
            } else {
              setState(() {
                _currentPageIndex = 0; // Retorna ao índice 0 se necessário
              });
            }
            // Atualiza o PageController para refletir o novo índice
            _pageController.jumpToPage(_currentPageIndex);
          }

          currentPhotoIndex = 0;
        } else {
          // Ajusta o índice da foto atual se a lista de fotos não estiver vazia
          if (currentPhotoIndex >=
              variation[_currentPageIndex]!.photos.length) {
            currentPhotoIndex = variation[_currentPageIndex]!.photos.length - 1;
          }
        }
      }
    });
  }

  Widget buildSwitchButton(String valuee, String label) {
    return Row(
      children: [
        Switch(
          value: valuee == "vitrine" ? vitrine : promocoes,
          onChanged: (bool value) {
            setState(() {
              valuee == "vitrine" ? vitrine = !vitrine : promocoes = !promocoes;
            });
          },
          activeColor: AppTheme.vinho,
          activeTrackColor: const Color.fromARGB(137, 189, 186, 186),
          inactiveTrackColor: AppTheme.nearlyBlack,
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            color: Colors.black,
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    super.dispose();
    _descriptionController.dispose();
    _variationController.dispose();
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
    var size = MediaQuery.of(context).size;

    return _files == null
        ? Scaffold(
            body: Container(),
          )
        : Scaffold(
            appBar: AppBar(
              elevation: 0,
              backgroundColor: Colors.transparent,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios),
                color: AppTheme.nearlyBlack,
                onPressed: clearImages,
              ),
              actions: <Widget>[
                isFront
                    ? TextButton(
                        onPressed: () {
                          _flipCardController.toggleCard();
                        },
                        child: const Text(
                          "INFO",
                          style: TextStyle(
                            color: Colors.blueAccent,
                            fontWeight: FontWeight.bold,
                            fontSize: 16.0,
                          ),
                        ),
                      )
                    : TextButton(
                        onPressed: () => postImages(
                            widget.uid, widget.storename, widget.storephoto),
                        child: const Text(
                          "Post",
                          style: TextStyle(
                            color: Colors.blueAccent,
                            fontWeight: FontWeight.bold,
                            fontSize: 16.0,
                          ),
                        ),
                      ),
              ],
              toolbarHeight: size.height * 0.055,
            ),
            body: FlipCard(
                onFlip: () {
                  setState(() {
                    isFront = !isFront;
                  });
                },
                controller: _flipCardController,
                fill: Fill.fillBack,
                direction: FlipDirection.HORIZONTAL,
                side: CardSide.FRONT,
                front:
                    ListView(controller: _scrollController, children: <Widget>[
                  isLoading
                      ? const LinearProgressIndicator()
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            GestureDetector(
                                onDoubleTap: () {
                                  print(variation[_currentPageIndex]!
                                      .sizesAvailable);
                                },
                                child: SizedBox(
                                    height: 600.h,
                                    child: Align(
                                        alignment: Alignment.center,
                                        child: AspectRatio(
                                            aspectRatio: 9 / 16,
                                            child: Container(
                                                decoration: BoxDecoration(
                                                  color: AppTheme
                                                      .nearlyWhite, // Cor de fundo
                                                  border: Border.all(
                                                    color: Colors
                                                        .black, // Cor da borda
                                                    width:
                                                        0.5, // Largura da borda
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10.0), // Raio da borda, se desejar bordas arredondadas
                                                ),
                                                child: Stack(children: [
                                                  PageView.builder(
                                                      itemCount:
                                                          variation.length,
                                                      physics:
                                                          NeverScrollableScrollPhysics(),
                                                      controller:
                                                          _pageController,
                                                      onPageChanged: (index) {
                                                        setState(() {
                                                          _currentPageIndex =
                                                              index;
                                                          currentPhotoIndex = 0;
                                                          lastSelectedSize = -1;
                                                          itemdescriptionController
                                                              .text = variation[
                                                                      _currentPageIndex]
                                                                  ?.variationdescription ??
                                                              " ${_currentPageIndex + 1}";
                                                          itemCountController
                                                                  .text =
                                                              '${variation[_currentPageIndex]?.itemCount ?? 0}';
                                                          itempriceController
                                                                  .text =
                                                              '${variation[_currentPageIndex]?.price ?? 0}';
                                                        });
                                                      },
                                                      itemBuilder: (context,
                                                          variationIndex) {
                                                        return Column(
                                                            children: [
                                                              Expanded(
                                                                child: PageView
                                                                    .builder(
                                                                  itemCount: variation[
                                                                              _currentPageIndex]
                                                                          ?.photos
                                                                          .length ??
                                                                      0, // Número de fotos por variação
                                                                  controller:
                                                                      _photoController,
                                                                  onPageChanged:
                                                                      (photoIndex) {
                                                                    setState(
                                                                        () {
                                                                      currentPhotoIndex =
                                                                          photoIndex;
                                                                    });
                                                                  },
                                                                  itemBuilder:
                                                                      (context,
                                                                          photoIndex) {
                                                                    return Stack(
                                                                      children: [
                                                                        Center(
                                                                            child:
                                                                                ClipRRect(
                                                                          borderRadius:
                                                                              BorderRadius.circular(10.0),
                                                                          child:
                                                                              Image.memory(
                                                                            variation[variationIndex]?.photos[photoIndex] ??
                                                                                Uint8List(0),
                                                                            fit:
                                                                                BoxFit.contain,
                                                                            height:
                                                                                double.infinity,
                                                                            width:
                                                                                double.infinity,
                                                                          ),
                                                                        )),
                                                                        Positioned(
                                                                          top:
                                                                              0,
                                                                          right:
                                                                              5,
                                                                          child:
                                                                              Padding(
                                                                            padding:
                                                                                const EdgeInsets.symmetric(vertical: 5),
                                                                            child:
                                                                                GestureDetector(
                                                                              onTap: () {
                                                                                deleteCurrentImage();
                                                                              },
                                                                              child: Container(
                                                                                width: 35.0,
                                                                                height: 35.0,
                                                                                decoration: BoxDecoration(
                                                                                  color: AppTheme.vinho,
                                                                                  borderRadius: BorderRadius.circular(16.0),
                                                                                ),
                                                                                child: Icon(
                                                                                  Icons.delete,
                                                                                  color: AppTheme.nearlyWhite,
                                                                                  size: 24.0,
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    );
                                                                  },
                                                                ),
                                                              ),
                                                            ]);
                                                      })
                                                ])))))),
                            Center(
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 2.5),
                                child: variation[_currentPageIndex]!
                                            .photos
                                            .length >
                                        1
                                    ? DotsIndicator(
                                        dotsCount: variation[_currentPageIndex]
                                                ?.photos
                                                .length ??
                                            0,
                                        position: currentPhotoIndex,
                                        decorator: DotsDecorator(
                                          color: AppTheme.nearlyWhite,
                                          activeColor: AppTheme.vinho,
                                          spacing: const EdgeInsets.symmetric(
                                              horizontal: 4.0),
                                          size: const Size.square(8.0),
                                          activeSize: const Size(16.0, 8.0),
                                          activeShape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(4.0),
                                          ),
                                        ),
                                      )
                                    : SizedBox.shrink(),
                              ),
                            ),
                            SizedBox(
                              width: size.width,
                              child: Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 20),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Spacer(),
                                                Text(
                                                  '\$${variation[_currentPageIndex]?.price ?? 0}', // Exibe o preço da variação atual
                                                  style:
                                                      AppTheme.subheadlinevinho,
                                                ),
                                              ],
                                            )),
                                        Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Container(
                                                margin: EdgeInsets.all(5.h),
                                                child: ElevatedButton(
                                                  style: ButtonStyle(
                                                    backgroundColor:
                                                        MaterialStateProperty
                                                            .all<Color>(AppTheme
                                                                .vinho), // Cor de fundo do botão
                                                  ),
                                                  onPressed: () {
                                                    _selectmoreImage(context,
                                                        _currentPageIndex);
                                                  },
                                                  child: Row(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      Icon(
                                                        Icons.add_circle,
                                                        size: 23,
                                                        color: AppTheme.cinza,
                                                      ), // Exemplo de um ícone
                                                      Gap(8), // Espaçamento entre o ícone e o texto
                                                      Text(
                                                        'Add Imagem',
                                                        style: AppTheme
                                                            .subtitlewhite,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              Container(
                                                margin: EdgeInsets.all(5.h),
                                                child: ElevatedButton(
                                                  style: ButtonStyle(
                                                    backgroundColor:
                                                        MaterialStateProperty
                                                            .all<Color>(AppTheme
                                                                .vinho), // Cor de fundo do botão
                                                  ),
                                                  onPressed: () {
                                                    _selectImage(context,
                                                        variation.length);
                                                  },
                                                  child: Row(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      ImageIcon(
                                                        AssetImage(
                                                            'assets/${icons[indexDaCategoria]}'),
                                                        size: 23,
                                                        color: AppTheme.cinza,
                                                      ), // Exemplo de um ícone
                                                      Gap(8), // Espaçamento entre o ícone e o texto
                                                      Text(
                                                        'Add variação',
                                                        style: AppTheme
                                                            .subtitlewhite,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ]),
                                        variation.length > 1
                                            ? SizedBox(
                                                height: size.height * 0.1,
                                                child: GridView.builder(
                                                  scrollDirection:
                                                      Axis.horizontal,
                                                  itemCount: variation.length,
                                                  gridDelegate:
                                                      SliverGridDelegateWithFixedCrossAxisCount(
                                                    crossAxisCount: 1,
                                                    crossAxisSpacing: 8.0,
                                                  ),
                                                  itemBuilder:
                                                      (context, index) {
                                                    return GestureDetector(
                                                      onTap: () {
                                                        setState(() {
                                                          _currentPageIndex =
                                                              index;
                                                          _pageController
                                                              .jumpToPage(
                                                                  index);

                                                          lastSelectedSize = -1;
                                                          currentPhotoIndex = 0;
                                                          itemdescriptionController
                                                              .text = variation[
                                                                      _currentPageIndex]
                                                                  ?.variationdescription ??
                                                              " ${_currentPageIndex + 1}";
                                                          itemCountController
                                                                  .text =
                                                              '${variation[_currentPageIndex]?.itemCount ?? 0}';
                                                          itempriceController
                                                                  .text =
                                                              '${variation[_currentPageIndex]?.price ?? 0}';
                                                        });
                                                      },
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(8.0),
                                                        child:
                                                            AnimatedContainer(
                                                          width:
                                                              size.width * 0.15,
                                                          decoration:
                                                              BoxDecoration(
                                                            border: Border.all(
                                                              color: _currentPageIndex ==
                                                                      index
                                                                  ? AppTheme
                                                                      .vinho
                                                                  : Colors
                                                                      .transparent,
                                                              width: 2,
                                                            ),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        8),
                                                          ),
                                                          duration:
                                                              const Duration(
                                                                  milliseconds:
                                                                      200),
                                                          child: ClipRRect(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        8),
                                                            child: Image.memory(
                                                              variation[index]
                                                                          ?.photos
                                                                          .isNotEmpty ==
                                                                      true
                                                                  ? variation[
                                                                          index]!
                                                                      .photos[0]
                                                                  : Uint8List(
                                                                      0),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                ),
                                              )
                                            : SizedBox.shrink(),
                                        SizedBox(
                                          height: size.height * 0.003,
                                        ),
                                        Visibility(
                                          visible: variation.length > 1,
                                          child: Text(
                                            "Variação selecionada:${variation[_currentPageIndex]?.variationdescription?.isNotEmpty == true ? variation[_currentPageIndex]!.variationdescription! : " Variation ${_currentPageIndex + 1}"}",
                                            style: AppTheme.caption,
                                          ),
                                        ),
                                        categorySizes[selectedCategory] !=
                                                    null ||
                                                categorySizes[selectedCategory]!
                                                    .isNotEmpty
                                            ? Column(
                                                children: [
                                                  SizedBox(
                                                    height: size.height * 0.006,
                                                  ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            top: 5.0,
                                                            bottom: 3.0),
                                                    child: Text(
                                                      "Tamanhos disponíveis para a peça: ",
                                                      style: AppTheme.title,
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    width: size.width * 0.9,
                                                    height: size.height * 0.08,
                                                    child: ListView.builder(
                                                      physics:
                                                          const AlwaysScrollableScrollPhysics(),
                                                      scrollDirection:
                                                          Axis.horizontal,
                                                      itemCount: categorySizes[
                                                              selectedCategory]!
                                                          .length,
                                                      itemBuilder:
                                                          (ctx, index) {
                                                        var currentSize =
                                                            categorySizes[
                                                                    selectedCategory]![
                                                                index];

                                                        // Verifica se o tamanho já está selecionado
                                                        bool isSelected = variation[
                                                                _currentPageIndex]!
                                                            .sizesAvailable
                                                            .contains(
                                                                currentSize);
                                                        bool isLastSelected =
                                                            lastSelectedSize ==
                                                                index;

                                                        return GestureDetector(
                                                          onTap: () {
                                                            setState(() {
                                                              // Obtém o tamanho atual baseado no index
                                                              var currentSize =
                                                                  categorySizes[
                                                                          selectedCategory]![
                                                                      index];

                                                              if (isSelected &&
                                                                  isLastSelected) {
                                                                // Remove o tamanho se ele já estiver selecionado e foi o último selecionado
                                                                variation[
                                                                        _currentPageIndex]!
                                                                    .sizesAvailable
                                                                    .remove(
                                                                        currentSize);
                                                                lastSelectedSize =
                                                                    -1;
                                                              } else {
                                                                if (!isSelected) {
                                                                  // Adiciona o tamanho à lista sizesAvailable
                                                                  variation[
                                                                          _currentPageIndex]!
                                                                      .sizesAvailable
                                                                      .add(
                                                                          currentSize);
                                                                }
                                                                lastSelectedSize =
                                                                    index;
                                                              }
                                                            });

                                                            // Garante que o scroll aconteça após o setState ser concluído
                                                            WidgetsBinding
                                                                .instance
                                                                .addPostFrameCallback(
                                                                    (_) {
                                                              _scrollDown();
                                                            });

                                                            // Ensure the scroll happens after the setState has completed
                                                            WidgetsBinding
                                                                .instance
                                                                .addPostFrameCallback(
                                                                    (_) {
                                                              _scrollDown();
                                                            });
                                                          },
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(10.0),
                                                            child:
                                                                AnimatedContainer(
                                                              width:
                                                                  size.width *
                                                                      0.12,
                                                              decoration:
                                                                  BoxDecoration(
                                                                color: isSelected
                                                                    ? AppTheme
                                                                        .vinho
                                                                    : Colors
                                                                        .transparent,
                                                                border:
                                                                    Border.all(
                                                                  color: isLastSelected
                                                                      ? Colors
                                                                          .blue
                                                                      : AppTheme
                                                                          .vinho,
                                                                  width: 2,
                                                                ),
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            15),
                                                              ),
                                                              duration:
                                                                  const Duration(
                                                                      milliseconds:
                                                                          200),
                                                              child: Center(
                                                                child: Text(
                                                                  currentSize,
                                                                  style:
                                                                      TextStyle(
                                                                    fontSize:
                                                                        17,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500,
                                                                    color: isSelected
                                                                        ? Colors
                                                                            .white
                                                                        : Colors
                                                                            .black,
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                    ),
                                                  ),
                                                ],
                                              )
                                            : SizedBox.shrink()
                                      ])),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 18.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (lastSelectedSize == -1)
                                    Container()
                                  else
                                    Text(
                                      "Quantos itens à venda para ${variation.length == 1 ? 'o' : variation[_currentPageIndex]?.variationdescription?.isNotEmpty == true ? variation[_currentPageIndex]!.variationdescription! : "Variação ${_currentPageIndex + 1}"} tamanho ${categorySizes[selectedCategory]![lastSelectedSize]}?",
                                      style: AppTheme.title,
                                    ),
                                  if (!(lastSelectedSize == -1))
                                    Column(
                                      children: [
                                        Gap(size.height * 0.005),
                                        SizedBox(
                                          width: 100,
                                          child: TextField(
                                            controller: itemCountController,
                                            onChanged: (value) {
                                              setState(() {
                                                if (variation.containsKey(
                                                    _currentPageIndex)) {
                                                  // Verifica se o valor pode ser convertido para um número inteiro
                                                  int parsedValue =
                                                      int.tryParse(value) ?? 0;

                                                  // Atualiza o campo itemCount da variação atual
                                                  variation[_currentPageIndex]!
                                                      .itemCount = parsedValue;
                                                }
                                              });
                                            },
                                            keyboardType: TextInputType
                                                .numberWithOptions(),
                                            style: AppTheme.subtitle,
                                            decoration: InputDecoration(
                                              hintText:
                                                  '${variation[_currentPageIndex]?.itemCount ?? 0}',
                                              hintStyle: AppTheme.subtitle,
                                              enabledBorder: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                    color: AppTheme
                                                        .nearlyBlack), // Cor da borda quando o TextField não está focado
                                              ),
                                              focusedBorder: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                    color: Colors
                                                        .blue), // Cor da borda quando o TextField está focado
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                  Gap(10)
                ]),
                back: isLoading
                    ? LinearProgressIndicator()
                    : ListView(children: [
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 5),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Gap(30),
                              Container(
                                  width: 350.w,
                                  padding: EdgeInsets.symmetric(horizontal: 8),
                                  decoration: BoxDecoration(
                                    color: AppTheme.white,
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                  child: Padding(
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 8),
                                      child: TextField(
                                        controller: _descriptionController,
                                        style: AppTheme.title,
                                        decoration: InputDecoration(
                                          hintText:
                                              "Escreva uma descrição para o produto...",
                                          hintStyle: AppTheme.title,
                                          border: InputBorder.none,
                                        ),
                                        minLines: 1,
                                        maxLines: 6,
                                      ))),
                              Gap(20),
                              Text("Categoria do produto: ",
                                  style: AppTheme.title),
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
                                          final category = clothingItems.keys
                                              .elementAt(index);
                                          return SizedBox(
                                            height: 50.0,
                                            child: ElevatedButton(
                                              onPressed: () {
                                                setState(() {
                                                  variation[_currentPageIndex]!
                                                      .sizesAvailable = [];
                                                  lastSelectedSize = -1;
                                                  selectedCategory = 'Tronco';

                                                  showCategoryDialog(
                                                      context, category,
                                                      (value) {
                                                    setState(() {
                                                      selectedClothType = value;
                                                      selectedCategory =
                                                          clothingItems.keys
                                                              .elementAt(index);
                                                      indexDaCategoria = index;
                                                    });
                                                  });
                                                });
                                              },
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    selectedCategory == category
                                                        ? AppTheme.vinho
                                                        : Colors.grey,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10.0),
                                                ),
                                              ),
                                              child: ImageIcon(
                                                AssetImage(
                                                  'assets/${icons[index]}',
                                                ),
                                                color: AppTheme.nearlyWhite,
                                                size: 20,
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
                                                  BorderRadius.circular(15),
                                            ),
                                            child: Center(
                                              child: Text(
                                                selectedClothType!,
                                                style: AppTheme.titlewhite,
                                              ),
                                            ),
                                          ),
                                          Positioned(
                                            top: 0,
                                            right: 0,
                                            child: GestureDetector(
                                              onTap: () {
                                                setState(() {
                                                  selectedClothType = null;
                                                  variation[_currentPageIndex]!
                                                      .sizesAvailable = [];
                                                  lastSelectedSize = -1;
                                                  indexDaCategoria = 3;
                                                  selectedCategory = 'Tronco';
                                                });
                                              },
                                              child: Container(
                                                padding: EdgeInsets.all(2),
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: Colors.white,
                                                ),
                                                child: Icon(
                                                  Icons.close,
                                                  color: Colors.black,
                                                  size: 16,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                              Gap(20),
                              Visibility(
                                  visible: variation.length != 1,
                                  child: DropdownButton<int>(
                                    dropdownColor: AppTheme.cinza,
                                    iconEnabledColor: AppTheme.vinho,
                                    value: _currentPageIndex,
                                    onChanged: (int? newIndex) {
                                      setState(() {
                                        _currentPageIndex = newIndex!;
                                        lastSelectedSize = -1;
                                        itemdescriptionController.text =
                                            variation[_currentPageIndex]
                                                    ?.variationdescription ??
                                                " ${_currentPageIndex + 1}";
                                        itemCountController.text =
                                            '${variation[_currentPageIndex]?.itemCount ?? 0}';
                                        itempriceController.text =
                                            '${variation[_currentPageIndex]?.price ?? 0}';
                                      });
                                    },
                                    items: variation.keys.map((index) {
                                      return DropdownMenuItem<int>(
                                        value: index,
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.image,
                                              color: AppTheme.vinho,
                                            ),
                                            Gap(8),
                                            Text(
                                              'Variation ${index + 1}',
                                              style: AppTheme.subtitle,
                                            ),
                                          ],
                                        ),
                                      );
                                    }).toList(),
                                  )),
                              Gap(size.height * 0.02),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Visibility(
                                      visible: variation.length != 1,
                                      child: Center(
                                          child: Column(children: [
                                        Text(
                                          "Descrição para variação ${_currentPageIndex + 1}:",
                                          style: AppTheme.title,
                                        ),
                                        Gap(size.height * 0.01),
                                        SizedBox(
                                          width: 300.w,
                                          child: TextField(
                                            controller:
                                                itemdescriptionController,
                                            onChanged: (value) {
                                              setState(() {
                                                // Atualiza a descrição da variação atual no mapa variation
                                                variation[_currentPageIndex]
                                                        ?.variationdescription =
                                                    value;
                                              });
                                            },
                                            keyboardType: TextInputType.text,
                                            style: AppTheme.title,
                                            decoration: InputDecoration(
                                              hintText:
                                                  "Variação ${_currentPageIndex + 1}",
                                              hintStyle: AppTheme.title,
                                              enabledBorder: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                    color: AppTheme
                                                        .nearlyBlack), // Cor da borda quando o TextField não está focado
                                              ),
                                              focusedBorder: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                    color: Colors
                                                        .blue), // Cor da borda quando o TextField está focado
                                              ),
                                            ),
                                          ),
                                        ),
                                      ]))),
                                  Gap(size.height * 0.006),
                                  Align(
                                      alignment: Alignment.center,
                                      child: Column(children: [
                                        Padding(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 10),
                                            child: Text(
                                              "Preço ${variation.length == 1 ? 'do produto' : 'da variação ${_currentPageIndex + 1}'}:",
                                              style: AppTheme.title,
                                            )),
                                        Gap(size.height * 0.002),
                                        SizedBox(
                                          width: 100,
                                          child: TextField(
                                            controller: itempriceController,
                                            onChanged: (value) {
                                              setState(() {
                                                if (variation.containsKey(
                                                    _currentPageIndex)) {
                                                  variation[_currentPageIndex]!
                                                          .price =
                                                      double.parse(value);
                                                }
                                              });
                                            },
                                            keyboardType:
                                                TextInputType.numberWithOptions(
                                                    decimal: true),
                                            style: AppTheme.title,
                                            decoration: InputDecoration(
                                              hintText:
                                                  '${variation[_currentPageIndex]?.price ?? 0}',
                                              hintStyle: AppTheme.title,
                                              enabledBorder: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                    color: AppTheme
                                                        .nearlyBlack), // Cor da borda quando o TextField não está focado
                                              ),
                                              focusedBorder: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                    color: Colors
                                                        .blue), // Cor da borda quando o TextField está focado
                                              ),
                                            ),
                                          ),
                                        ),
                                      ])),
                                  Gap(size.height * 0.002),
                                ],
                              ),
                              Gap(size.height * 0.02),
                              Text(
                                "Adicionar em:",
                                style: AppTheme.title,
                              ),
                              buildSwitchButton("vitrine", 'VITRINE'),
                              buildSwitchButton("promocoes", 'PROMOÇÕES'),
                            ],
                          ),
                        )
                      ])),
          );
  }
}
