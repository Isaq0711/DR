import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:dressing_room/providers/user_provider.dart';
import 'package:dressing_room/widgets/select_image_dialog.dart';
import 'package:dressing_room/models/user.dart';
import 'package:provider/provider.dart';
import 'package:flip_card/flip_card.dart';
import 'package:dressing_room/utils/colors.dart';
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
  Set<int> selectedSizes = Set<int>();
  int lastSelectedIndex = -1;
  String selectedCategory = 'TOP';
  List<Uint8List>? _files;
  List<Uint8List>? _variationoptionsfiles;
  bool isLoading = false;
  Set<SwitchOption> selectedOptions = Set<SwitchOption>();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _variationController = TextEditingController();

  PageController _pageController = PageController(initialPage: 0);
  int _currentPageIndex = 0;
  Map<String, List<String>> categorySizes = {
    'TOP': ['XS', 'S', 'M', 'L', 'XL'],
    'BOTTOM': ['34', '36', '38', '40', '42', '44'],
    'SHOES': ['34', '35', '36', '37', '38', '39', '40', '41', '42'],
    'COATS': ['PP', 'P', 'M', 'G', 'GG'],
  };

  Map<int, double> piecePrices = {};
  Map<int, String> pieceDescription = {};
  String selectedOption = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      _selectImage(context);
    });
  }

  _selectImage(BuildContext parentContext) async {
    showDialog(
      context: parentContext,
      builder: (BuildContext context) {
        return SelectImageDialog(
          onImageSelected: (Uint8List file) {
            setState(() {
              _files ??= [];
              _files!.add(file);
              piecePrices[_files!.length - 1] = 0;
              pieceDescription[_files!.length - 1] = "";
            });
          },
        );
      },
    );
  }

  void goToNextImage() {
    setState(() {
      _currentPageIndex++;
      if (_currentPageIndex >= _files!.length) {
        _currentPageIndex = 0;
      }
    });
  }

  void goToPreviousImage() {
    setState(() {
      _currentPageIndex--;
      if (_currentPageIndex < 0) {
        _currentPageIndex = _files!.length - 1;
      }
    });
  }

  void postImages(String uid, String username, String profImage) async {
    setState(() {
      isLoading = true;
    });
  }

  void clearImages() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (context) => const ResponsiveLayout(
          mobileScreenLayout: MobileScreenLayout(),
          webScreenLayout: WebScreenLayout(),
        ),
      ),
      (route) => false,
    );
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
    _pageController.dispose();
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
              backgroundColor: AppTheme.nearlyWhite,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                color: AppTheme.nearlyBlack,
                onPressed: clearImages,
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () => postImages(
                    user.uid!,
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
                front: ListView(
                  children: [
                    Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.grey,
                          ),
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
                                width: size.width,
                                height: size.height * 0.5,
                                child: Stack(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8.0),
                                      child: Image.memory(
                                        _files![_currentPageIndex],
                                        width: size.width,
                                        height: size.height * 0.5,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    Positioned(
                                        bottom: 8.0,
                                        right: 8.0,
                                        child: GestureDetector(
                                            onTap: () {
                                              // Adicione a lógica para deletar a imagem
                                            },
                                            child: Container(
                                              width:
                                                  35.0, // Largura do Container
                                              height:
                                                  35.0, // Altura do Container
                                              decoration: BoxDecoration(
                                                color: AppTheme.vinho,
                                                borderRadius: BorderRadius.circular(
                                                    16.0), // Borda arredondada com metade da altura para criar um círculo
                                              ),
                                              child: Icon(
                                                Icons.delete,
                                                color: AppTheme.nearlyWhite,
                                                size: 24.0,
                                              ),
                                            ))),
                                  ],
                                ),
                              ),
                            ),
                            Center(
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 4.5),
                                child: _files != null && _files!.length > 1
                                    ? DotsIndicator(
                                        dotsCount: _files!.length,
                                        position: _currentPageIndex.toInt(),
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
                                          '\$${piecePrices[_currentPageIndex]}',
                                          style: AppTheme.subheadlinevinho,
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      height: size.height * 0.006,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: 10.0, top: 18.0, bottom: 10.0),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          GestureDetector(
                                            onTap: () => _selectImage(context),
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
                                            onTap: () => _selectImage(context),
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
                                      visible:
                                          _files != null && _files!.length > 1,
                                      child: SizedBox(
                                        height: size.height * 0.1,
                                        child: GridView.builder(
                                          scrollDirection: Axis.horizontal,
                                          itemCount: _files!.length,
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
                                                });
                                              },
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: AnimatedContainer(
                                                  width: size.width * 0.15,
                                                  decoration: BoxDecoration(
                                                    border: Border.all(
                                                      color:
                                                          _currentPageIndex ==
                                                                  index
                                                              ? AppTheme.vinho
                                                              : Colors
                                                                  .transparent,
                                                      width: 2,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                  ),
                                                  duration: const Duration(
                                                      milliseconds: 200),
                                                  child: ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                    child: Image.memory(
                                                      _files![index],
                                                      fit: BoxFit.cover,
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
                                      visible:
                                          _files != null && _files!.length > 1,
                                      child: Text(
                                        "Variation selected: " +
                                            '${pieceDescription[_currentPageIndex]}',
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
                                            categorySizes[selectedCategory]!
                                                .length,
                                        itemBuilder: (ctx, index) {
                                          var current = categorySizes[
                                              selectedCategory]![index];
                                          bool isSelected =
                                              selectedSizes.contains(index);
                                          bool isLastSelected =
                                              lastSelectedIndex == index;

                                          return GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                if (isSelected &&
                                                    isLastSelected) {
                                                  selectedSizes.remove(index);
                                                  lastSelectedIndex = -1;
                                                } else {
                                                  selectedSizes.add(index);
                                                  lastSelectedIndex = index;
                                                }
                                              });
                                            },
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(10.0),
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
                                                      fontWeight:
                                                          FontWeight.w500,
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
                                  Text(
                                    "How many itens are available for variation ${_currentPageIndex + 1}? ",
                                    style: AppTheme.title,
                                  ),
                                  Gap(size.height * 0.005),
                                  SizedBox(
                                    width: 100,
                                    child: TextField(
                                      onChanged: (value) {
                                        setState(() {});
                                      },
                                      keyboardType:
                                          TextInputType.numberWithOptions(),
                                      style: AppTheme.subtitle,
                                      decoration: InputDecoration(
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
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                back: ListView(children: [
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Container(
                      height: size.height,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.grey,
                        ),
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
                                decoration: const InputDecoration(
                                  hintText:
                                      "Type a description for the product..",
                                  hintStyle: AppTheme.title,
                                  border: InputBorder.none,
                                ),
                              ),
                              SizedBox(height: 20),
                              Text("Category of the product: ",
                                  style: AppTheme.title),
                              SizedBox(height: 10),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  ElevatedButton(
                                    onPressed: () {
                                      setState(() {
                                        selectedCategory = 'TOP';
                                      });
                                    },
                                    style: ElevatedButton.styleFrom(
                                      primary: selectedCategory == 'TOP'
                                          ? AppTheme.vinho
                                          : Colors.grey,
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                      ),
                                    ),
                                    child: Text('TOP',
                                        style: AppTheme.subtitlewhite),
                                  ),
                                  ElevatedButton(
                                    onPressed: () {
                                      setState(() {
                                        selectedCategory = 'BOTTOM';
                                      });
                                    },
                                    style: ElevatedButton.styleFrom(
                                      primary: selectedCategory == 'BOTTOM'
                                          ? AppTheme.vinho
                                          : Colors.grey,
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                      ),
                                    ),
                                    child: Text('BOTTOM',
                                        style: AppTheme.subtitlewhite),
                                  ),
                                  ElevatedButton(
                                    onPressed: () {
                                      setState(() {
                                        selectedCategory = 'SHOES';
                                      });
                                    },
                                    style: ElevatedButton.styleFrom(
                                      primary: selectedCategory == 'SHOES'
                                          ? AppTheme.vinho
                                          : Colors.grey,
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                      ),
                                    ),
                                    child: Text('SHOES',
                                        style: AppTheme.subtitlewhite),
                                  ),
                                  ElevatedButton(
                                    onPressed: () {
                                      setState(() {
                                        selectedCategory = 'COATS';
                                      });
                                    },
                                    style: ElevatedButton.styleFrom(
                                      primary: selectedCategory == 'COATS'
                                          ? AppTheme.vinho
                                          : Colors.grey,
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                      ),
                                    ),
                                    child: Text('COATS',
                                        style: AppTheme.subtitlewhite),
                                  ),
                                ],
                              ),
                              SizedBox(height: 20),
                              DropdownButton<int>(
                                dropdownColor: AppTheme.cinza,
                                iconEnabledColor: AppTheme.vinho,
                                value: _currentPageIndex,
                                onChanged: (int? newIndex) {
                                  setState(() {
                                    _currentPageIndex = newIndex!;
                                    _descriptionController.text =
                                        pieceDescription[_currentPageIndex] ??
                                            "";
                                  });
                                },
                                items: List.generate(_files!.length, (index) {
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
                                }),
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
                                      onChanged: (value) {
                                        setState(() {
                                          pieceDescription[_currentPageIndex] =
                                              value;
                                        });
                                      },
                                      keyboardType: TextInputType.text,
                                      style: AppTheme.subtitle,
                                      decoration: InputDecoration(
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
                                      onChanged: (value) {
                                        setState(() {
                                          piecePrices[_currentPageIndex] =
                                              double.parse(value);
                                        });
                                      },
                                      keyboardType:
                                          TextInputType.numberWithOptions(
                                              decimal: true),
                                      style: AppTheme.subtitle,
                                      decoration: InputDecoration(
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
                              buildSwitchButton(
                                  SwitchOption.optionA, 'VITRINE'),
                              buildSwitchButton(
                                  SwitchOption.optionB, 'PROMOÇÕES'),
                              buildSwitchButton(
                                  SwitchOption.optionC, 'PRODUTOS'),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ])));
  }
}
