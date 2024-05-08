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
import 'package:dressing_room/responsive/web_screen_layout.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({Key? key}) : super(key: key);

  @override
  _AddPostScreenState createState() => _AddPostScreenState();
}

enum SwitchOption { optionA, optionB, optionC }

class _AddPostScreenState extends State<AddProductScreen> {
  int lastSelectedSize = -1;
  String selectedCategory = 'TOP';
  String? selectedClothType;
  List<Uint8List>? _files;
  bool isLoading = false;
  Set<SwitchOption> selectedOptions = Set<SwitchOption>();
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

  Map<String, List<String>> categorySizes = {
    'TOP': ['XS', 'S', 'M', 'L', 'XL'],
    'BOTTOM': ['34', '36', '38', '40', '42', '44'],
    'SHOES': ['34', '35', '36', '37', '38', '39', '40', '41', '42'],
    'COATS': ['PP', 'P', 'M', 'G', 'GG'],
  };

  Map<int, VariationInfo> variation = {};
  int currentPhotoIndex = 0;
  String selectedOption = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      _selectImage(context, 0);
    });
  }

  _selectImage(BuildContext parentContext, int variationIndex) async {
    showDialog(
      context: parentContext,
      builder: (BuildContext context) {
        return SelectImageDialog(
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
                  price: 0,
                );
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
        return SelectImageDialog(
          onImageSelected: (Uint8List file) {
            setState(() {
              _files ??= [];
              _files!.add(file);

              if (variation.containsKey(variationIndex)) {
                variation[variationIndex]!.photos.add(file);
              }
            });
          },
        );
      },
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
        List<int>? sizesAvailable = variation[i]?.sizesAvailable;
        double? price = variation[i]?.price;

        List<String> photoUrls = [];

        if (variation.containsKey(i) && variation[i]!.photos.isNotEmpty) {
          for (Uint8List photo in variation[i]!.photos) {
            String photoUrl = await StorageMethods()
                .uploadImageToStorage('products', photo, true);
            photoUrls.add(photoUrl);
          }
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
        false,
        true,
        true,
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
      if (_files != null && _files!.isNotEmpty) {
        _files!.removeAt(currentPhotoIndex);

        if (_files!.isEmpty) {
          // Se não houver mais imagens, configure _files como null e chame o dialog para selecionar uma nova imagem
          _files = null;
          _selectImage(context, 0);
        } else {
          // Se ainda houver imagens restantes, ajuste o índice da página atual
          if (currentPhotoIndex >= _files!.length) {
            currentPhotoIndex = 0;
          }
        }
      }
    });
  }

  Widget buildSwitchButton(SwitchOption option, String label) {
    return Row(
      children: [
        Switch(
          value: selectedOptions.contains(option),
          onChanged: (bool value) {
            setState(() {
              if (value) {
                selectedOptions.add(option);
              } else {
                selectedOptions.remove(option);
              }
            });
          },
          activeColor: AppTheme.vinho,
          activeTrackColor: AppTheme.cinza,
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
            resizeToAvoidBottomInset: false,
            appBar: AppBar(
              elevation: 0,
              backgroundColor: AppTheme.nearlyWhite,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios),
                color: AppTheme.nearlyBlack,
                onPressed: clearImages,
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () => postImages(
                    user.uid,
                    user.username,
                    user.photoUrl,
                  ),
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
                fill: Fill.fillBack,
                direction: FlipDirection.HORIZONTAL,
                side: CardSide.FRONT,
                front: ListView(children: <Widget>[
                  isLoading
                      ? const LinearProgressIndicator()
                      : const SizedBox(height: 0.0),
                  Container(
                    decoration: BoxDecoration(
                      color: AppTheme.nearlyWhite,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GestureDetector(
                            onDoubleTap: () {},
                            onHorizontalDragEnd: (details) {
                              if (details.primaryVelocity! > 0) {
                                goToPreviousImage();
                              } else if (details.primaryVelocity! < 0) {
                                goToNextImage();
                              }
                            },
                            child: SizedBox(
                                height: 500.h,
                                child: Align(
                                  alignment: Alignment.center,
                                  child: AspectRatio(
                                    aspectRatio: 9 / 16,
                                    child: Stack(
                                      children: [
                                        ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(10.0),
                                          child: Image.memory(
                                            variation[_currentPageIndex]
                                                        ?.photos[
                                                    currentPhotoIndex] ??
                                                Uint8List(0),
                                            fit: BoxFit.cover,
                                            height: double.infinity,
                                            width: double.infinity,
                                          ),
                                        ),
                                        Positioned(
                                            top: 0,
                                            right: 5,
                                            child: Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                  vertical: 5,
                                                ),
                                                child: GestureDetector(
                                                    onTap: () {
                                                      deleteCurrentImage();
                                                    },
                                                    child: Container(
                                                      width: 35.0,
                                                      height: 35.0,
                                                      decoration: BoxDecoration(
                                                        color: AppTheme.vinho,
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                                16.0), // Borda arredondada com metade da altura para criar um círculo
                                                      ),
                                                      child: Icon(
                                                        Icons.delete,
                                                        color: AppTheme
                                                            .nearlyWhite,
                                                        size: 24.0,
                                                      ),
                                                    )))),
                                      ],
                                    ),
                                  ),
                                ))),
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.5),
                            child:
                                variation[_currentPageIndex]!.photos.length > 1
                                    ? DotsIndicator(
                                        dotsCount: variation[_currentPageIndex]
                                                ?.photos
                                                .length ??
                                            0,
                                        position: currentPhotoIndex,
                                        decorator: DotsDecorator(
                                          color: AppTheme.cinza,
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
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                        child: Text(
                                      _descriptionController.text.isEmpty
                                          ? "Description"
                                          : _descriptionController.text,
                                      style: AppTheme.subheadline,
                                    )),
                                    Gap(10),
                                    Text(
                                      '\$${variation[_currentPageIndex]?.price ?? 0}', // Exibe o preço da variação atual
                                      style: AppTheme.subheadlinevinho,
                                    ),
                                  ],
                                ),
                                Gap(
                                  size.height * 0.006,
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 10.0, top: 18.0, bottom: 10.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      GestureDetector(
                                        onTap: () => _selectImage(
                                            context, variation.length),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            const Icon(
                                              Icons.add,
                                              color: Colors.black,
                                            ),
                                            Gap(4),
                                            const Text(
                                              'Add More variations',
                                              style: TextStyle(
                                                fontFamily: 'Quicksand',
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () => _selectmoreImage(
                                            context, _currentPageIndex),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            const Icon(
                                              Icons.add,
                                              color: Colors.black,
                                            ),
                                            const SizedBox(width: 4),
                                            const Text(
                                              'Add More photos',
                                              style: TextStyle(
                                                fontFamily: 'Quicksand',
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Visibility(
                                  visible: variation.length != null &&
                                      variation.length > 1,
                                  child: SizedBox(
                                    height: size.height * 0.1,
                                    child: GridView.builder(
                                      scrollDirection: Axis.horizontal,
                                      itemCount: variation.length,
                                      gridDelegate:
                                          SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 1,
                                        crossAxisSpacing: 8.0,
                                      ),
                                      itemBuilder: (context, index) {
                                        return GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              _currentPageIndex = index;
                                              lastSelectedSize = -1;
                                              currentPhotoIndex = 0;
                                              itemdescriptionController
                                                  .text = variation[
                                                          _currentPageIndex]
                                                      ?.variationdescription ??
                                                  " ${_currentPageIndex + 1}";
                                              itemCountController.text =
                                                  '${variation[_currentPageIndex]?.itemCount ?? 0}';
                                              itempriceController.text =
                                                  '${variation[_currentPageIndex]?.price ?? 0}';
                                            });
                                          },
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: AnimatedContainer(
                                              width: size.width * 0.15,
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                  color:
                                                      _currentPageIndex == index
                                                          ? AppTheme.vinho
                                                          : Colors.transparent,
                                                  width: 2,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              duration: const Duration(
                                                  milliseconds: 200),
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                child: Image.memory(
                                                  variation[index]
                                                              ?.photos
                                                              .isNotEmpty ==
                                                          true
                                                      ? variation[index]!
                                                          .photos[0]
                                                      : Uint8List(0),
                                                ),
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: size.height * 0.003,
                                ),
                                Visibility(
                                  visible: variation.length != null &&
                                      variation.length > 1,
                                  child: Text(
                                    "Variation selected: ${variation[_currentPageIndex]?.variationdescription?.isNotEmpty == true ? variation[_currentPageIndex]!.variationdescription! : " Variation ${_currentPageIndex + 1}"}",
                                    style: AppTheme.caption,
                                  ),
                                ),
                                SizedBox(
                                  height: size.height * 0.006,
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 10.0, top: 18.0, bottom: 10.0),
                                  child: Text(
                                    "Select Sizes available for the variation: ",
                                    style: AppTheme.title,
                                  ),
                                ),
                                SizedBox(
                                  width: size.width * 0.9,
                                  height: size.height * 0.08,
                                  child: ListView.builder(
                                    physics:
                                        const AlwaysScrollableScrollPhysics(),
                                    scrollDirection: Axis.horizontal,
                                    itemCount:
                                        categorySizes[selectedCategory]!.length,
                                    itemBuilder: (ctx, index) {
                                      var current = categorySizes[
                                          selectedCategory]![index];
                                      bool isSelected =
                                          variation[_currentPageIndex]!
                                              .sizesAvailable
                                              .contains(index);
                                      bool isLastSelected =
                                          lastSelectedSize == index;

                                      return GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            if (isSelected && isLastSelected) {
                                              variation[_currentPageIndex]!
                                                  .sizesAvailable
                                                  .remove(index);
                                              lastSelectedSize = -1;
                                            } else {
                                              variation[_currentPageIndex]!
                                                  .sizesAvailable
                                                  .add(index);
                                              print(
                                                  variation[_currentPageIndex]!
                                                      .sizesAvailable);
                                              print(lastSelectedSize);
                                              lastSelectedSize = index;
                                            }
                                          });
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.all(10.0),
                                          child: AnimatedContainer(
                                            width: size.width * 0.12,
                                            decoration: BoxDecoration(
                                              color: isSelected
                                                  ? AppTheme.vinho
                                                  : Colors.transparent,
                                              border: Border.all(
                                                color: isLastSelected
                                                    ? Colors.blue
                                                    : AppTheme.vinho,
                                                width: 2,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(15),
                                            ),
                                            duration: const Duration(
                                                milliseconds: 200),
                                            child: Center(
                                              child: Text(
                                                current,
                                                style: TextStyle(
                                                  fontSize: 17,
                                                  fontWeight: FontWeight.w500,
                                                  color: isSelected
                                                      ? Colors.white
                                                      : Colors.black,
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
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 18.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (lastSelectedSize == null ||
                                  lastSelectedSize == -1)
                                Container()
                              else
                                Text(
                                  "How many items are available for ${variation[_currentPageIndex]?.variationdescription?.isNotEmpty == true ? variation[_currentPageIndex]!.variationdescription! : "Variation ${_currentPageIndex + 1}"} size ${categorySizes[selectedCategory]![lastSelectedSize]}?",
                                  style: AppTheme.title,
                                ),
                              if (!(lastSelectedSize == null ||
                                  lastSelectedSize ==
                                      -1)) // Added a separate condition for the TextField
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
                                        keyboardType:
                                            TextInputType.numberWithOptions(),
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
                  ),
                ]),
                back: ListView(children: [
                  Container(
                    height: size.height,
                    decoration: BoxDecoration(
                      color: AppTheme.nearlyWhite,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: SizedBox(
                      height: size.height * 0.45,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextField(
                              controller: _descriptionController,
                              style: AppTheme.title,
                              decoration: InputDecoration(
                                hintText:
                                    "Type a description for the product..",
                                hintStyle: AppTheme.title,
                                border: InputBorder.none,
                              ),
                            ),
                            Gap(20),
                            Text("Category of the product: ",
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
                                        final category =
                                            clothingItems.keys.elementAt(index);
                                        return SizedBox(
                                          height: 50.0,
                                          child: ElevatedButton(
                                            onPressed: () {
                                              setState(() {
                                                showCategoryDialog(
                                                    context, category, (value) {
                                                  setState(() {
                                                    selectedClothType = value;
                                                  });
                                                });
                                              });
                                            },
                                            style: ElevatedButton.styleFrom(
                                              primary:
                                                  selectedCategory == category
                                                      ? AppTheme.vinho
                                                      : Colors.grey,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10.0),
                                              ),
                                            ),
                                            child: Text(
                                              category,
                                              style: AppTheme.subtitlewhite,
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
                                              style: AppTheme.subheadlinewhite,
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
                                                size: 12,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                            Gap(20),
                            DropdownButton<int>(
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
                                      SizedBox(width: 8),
                                      Text(
                                        'Variation ${index + 1}',
                                        style: AppTheme.subtitle,
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                            Gap(size.height * 0.02),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Description for variation ${_currentPageIndex + 1}:",
                                  style: AppTheme.title,
                                ),
                                Gap(size.height * 0.01),
                                SizedBox(
                                  width: double.infinity,
                                  child: TextField(
                                    controller: itemdescriptionController,
                                    onChanged: (value) {
                                      setState(() {
                                        // Atualiza a descrição da variação atual no mapa variation
                                        variation[_currentPageIndex]
                                            ?.variationdescription = value;
                                      });
                                    },
                                    keyboardType: TextInputType.text,
                                    style: AppTheme.subtitle,
                                    decoration: InputDecoration(
                                      hintText:
                                          "variation ${_currentPageIndex + 1}",
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
                                Gap(size.height * 0.003),
                                Text(
                                  "Price for variation ${_currentPageIndex + 1}:",
                                  style: AppTheme.title,
                                ),
                                Gap(size.height * 0.002),
                                SizedBox(
                                  width: 100,
                                  child: TextField(
                                    controller: itempriceController,
                                    onChanged: (value) {
                                      setState(() {
                                        if (variation
                                            .containsKey(_currentPageIndex)) {
                                          variation[_currentPageIndex]!.price =
                                              double.parse(value);
                                        }
                                      });
                                    },
                                    keyboardType:
                                        TextInputType.numberWithOptions(
                                            decimal: true),
                                    style: AppTheme.subtitle,
                                    decoration: InputDecoration(
                                      hintText:
                                          '${variation[_currentPageIndex]?.price ?? 0}',
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
                                Gap(size.height * 0.002),
                              ],
                            ),
                            Gap(size.height * 0.02),
                            Text(
                              "Adicionar em:",
                              style: AppTheme.title,
                            ),
                            buildSwitchButton(SwitchOption.optionA, 'VITRINE'),
                            buildSwitchButton(
                                SwitchOption.optionB, 'PROMOÇÕES'),
                            buildSwitchButton(SwitchOption.optionC, 'PRODUTOS'),
                          ],
                        ),
                      ),
                    ),
                  ),
                ])));
  }
}
