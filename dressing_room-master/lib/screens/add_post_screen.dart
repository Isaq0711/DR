import 'dart:typed_data';
import 'package:dressing_room/responsive/mobile_screen_layout.dart';
import 'package:dressing_room/responsive/responsive_layout.dart';
import 'seepost.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:flip_card/flip_card.dart';
import 'package:dressing_room/providers/user_provider.dart';
import 'package:dressing_room/resources/firestore_methods.dart';
import 'package:dressing_room/utils/colors.dart';
import 'package:dressing_room/utils/utils.dart';
import 'package:dressing_room/widgets/select_image_dialog.dart';
import 'package:dressing_room/widgets/tag_card.dart';
import 'package:dressing_room/widgets/friends_list.dart';
import 'package:dressing_room/models/user.dart';
import 'package:provider/provider.dart';
import 'my_wardrobe.dart';

class AddPostScreen extends StatefulWidget {
  final Uint8List? image;

  const AddPostScreen({Key? key, this.image}) : super(key: key);

  @override
  _AddPostScreenState createState() => _AddPostScreenState();
}

enum SwitchOption { optionA, optionB, optionC }

class _AddPostScreenState extends State<AddPostScreen> {
  bool isAnonymous = false;
  String selectedCategory = 'Public';
  String categoria1 = 'Marcas de roupas presentes';
  String categoria2 = 'Tecido da roupa';
  String categoria3 = 'Locais ou ocasião';
  String? categoriaSelecionada;
  List<String>? pecasID;
  List<String>? pecasPhotoUrls;
  List<String>? marcas;
  List<String>? tecido;
  List<String>? where;
  List<Uint8List>? _files;
  bool isLoading = false;

  Set<SwitchOption> selectedOptions = Set<SwitchOption>();
  final TextEditingController _descriptionController = TextEditingController();
  PageController _pageController = PageController(initialPage: 0);
  int _currentPageIndex = 0;

  @override
  void initState() {
    super.initState();
    _files = [];

    if (widget.image == null) {
      WidgetsBinding.instance!.addPostFrameCallback((_) {
        _selectImage(context);
      });
    } else {
      _files!.add(widget.image!);
    }
  }

  void _showWardrobe(BuildContext context, String uid) async {
    var wardrobeResult = await showModalBottomSheet(
      backgroundColor: AppTheme.cinza,
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Container(
          height: 650.h,
          child: Wardrobe(
            uid: uid,
            isDialog: true,
          ),
        );
      },
    );
    setState(() {
      Set<String> uniqueIdResults =
          Set.from(wardrobeResult['wardroberesultsID']);
      pecasID != null && pecasID!.isNotEmpty
          ? pecasID!.addAll(uniqueIdResults.difference(pecasID!.toSet()))
          : pecasID = wardrobeResult['wardroberesultsID'];

      Set<String> uniquePhotoResults =
          Set.from(wardrobeResult['wardroberesultsPhotos']);
      pecasPhotoUrls != null && pecasPhotoUrls!.isNotEmpty
          ? pecasPhotoUrls!
              .addAll(uniquePhotoResults.difference(pecasPhotoUrls!.toSet()))
          : pecasPhotoUrls = wardrobeResult['wardroberesultsPhotos'];
    });
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
      if (categoriaa == categoria3)
        setState(() {
          Set<String> uniqueResults = Set.from(results);
          where != null && where!.isNotEmpty
              ? where!.addAll(uniqueResults.difference(where!.toSet()))
              : where = results;
        });
    }
  }

  void exibirList(BuildContext context, String uid) async {
    String? categoria = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return FriendsListDialog(
          uid: uid,
        );
      },
    );

    if (categoria != null) {
      setState(() {
        categoriaSelecionada = categoria;
      });
    }
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
            });
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
      if (isAnonymous) {
        String res = await FireStoreMethods().uploadAnonymousPost(
          _descriptionController.text,
          _files!,
          pecasID,
          pecasPhotoUrls,
          uid,
        );
        if (res == "success") {
          showSnackBar(
            context,
            'Posted!',
          );
          clearImages();
        } else {
          showSnackBar(context, res);
        }
      } else {
        String res = await FireStoreMethods().uploadPost(
            _descriptionController.text,
            _files!,
            pecasID,
            pecasPhotoUrls,
            uid,
            username,
            profImage,
            0);
        if (res == "success") {
          showSnackBar(
            context,
            'Posted!',
          );
          clearImages();
        } else {
          showSnackBar(context, res);
        }
      }
    } catch (err) {
      showSnackBar(
        context,
        err.toString(),
      );
    }

    setState(() {
      isLoading = false;
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
    return _files == null
        ? Scaffold(
            body: Container(),
          )
        : Scaffold(
            resizeToAvoidBottomInset: false,
            appBar: AppBar(
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
                      "POST",
                      style: TextStyle(
                        color: Colors.blueAccent,
                        fontWeight: FontWeight.bold,
                        fontSize: 16.0,
                      ),
                    ),
                  ),
                ],
                toolbarHeight: 50.h),
            body: FlipCard(
                fill: Fill.fillBack,
                direction: FlipDirection.HORIZONTAL,
                side: CardSide.FRONT,
                front: isLoading
                    ? LinearProgressIndicator()
                    : ListView(children: <Widget>[
                        Container(
                          decoration: BoxDecoration(
                            color: AppTheme.nearlyWhite,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                height: 600.h,
                                child: Stack(
                                  children: [
                                    Align(
                                      alignment: Alignment.center,
                                      child: AspectRatio(
                                        aspectRatio: 9 / 16,
                                        child: Stack(
                                          children: [
                                            PageView.builder(
                                              controller: _pageController,
                                              itemCount: _files!.length,
                                              onPageChanged: (int index) {
                                                setState(() {
                                                  _currentPageIndex = index;
                                                });
                                              },
                                              itemBuilder:
                                                  (context, pageIndex) {
                                                return ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10.0),
                                                  child: Image.memory(
                                                    _files![pageIndex],
                                                    fit: BoxFit.cover,
                                                    height: double.infinity,
                                                    width: double.infinity,
                                                  ),
                                                );
                                              },
                                            ),
                                            Positioned(
                                              top: 0,
                                              right: 5,
                                              child: Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                    vertical: 5,
                                                  ),
                                                  child: GestureDetector(
                                                      onTap: () {
                                                        setState(() {
                                                          _files!.removeAt(
                                                              _currentPageIndex);
                                                        });
                                                      },
                                                      child: Container(
                                                        width: 35.0,
                                                        height: 35.0,
                                                        decoration:
                                                            BoxDecoration(
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
                                                      ))),
                                            ),
                                            Positioned(
                                              bottom: 0,
                                              child: pecasPhotoUrls != null
                                                  ? Padding(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                        horizontal: 10,
                                                        vertical: 5,
                                                      ),
                                                      child: Container(
                                                        height: 76.h,
                                                        width: 300.w,
                                                        child: GridView.builder(
                                                          scrollDirection:
                                                              Axis.horizontal,
                                                          itemCount:
                                                              pecasPhotoUrls!
                                                                  .length,
                                                          gridDelegate:
                                                              SliverGridDelegateWithFixedCrossAxisCount(
                                                            crossAxisCount: 1,
                                                            mainAxisSpacing: 4,
                                                          ),
                                                          itemBuilder:
                                                              (context, index) {
                                                            return GestureDetector(
                                                              onTap: () {
                                                                Navigator.push(
                                                                  context,
                                                                  MaterialPageRoute(
                                                                    builder:
                                                                        (context) =>
                                                                            SeePost(
                                                                      postId: pecasID![
                                                                          index],
                                                                    ),
                                                                  ),
                                                                );
                                                              },
                                                              child: Container(
                                                                  decoration: BoxDecoration(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              10.0),
                                                                      color: Colors
                                                                          .white24),
                                                                  child: Stack(
                                                                      children: [
                                                                        ClipRRect(
                                                                          borderRadius:
                                                                              BorderRadius.circular(10.0),
                                                                          child:
                                                                              Image.network(
                                                                            pecasPhotoUrls![index],
                                                                            fit:
                                                                                BoxFit.fill,
                                                                            height:
                                                                                76.h, // Garante a altura adequada para a imagem
                                                                            width:
                                                                                300.w,
                                                                          ),
                                                                        ),
                                                                        Positioned(
                                                                            child:
                                                                                Positioned(
                                                                          child: InkWell(
                                                                              onTap: () {
                                                                                setState(() {
                                                                                  pecasPhotoUrls!.removeAt(index);
                                                                                  pecasID!.removeAt(index);
                                                                                });
                                                                              },
                                                                              child: Padding(
                                                                                padding: const EdgeInsets.symmetric(
                                                                                  horizontal: 3,
                                                                                  vertical: 3,
                                                                                ),
                                                                                child: Container(
                                                                                  decoration: BoxDecoration(
                                                                                    color: AppTheme.vinho,
                                                                                    borderRadius: BorderRadius.circular(10),
                                                                                  ),
                                                                                  child: Icon(Icons.delete, size: 17),
                                                                                ),
                                                                              )),
                                                                        ))
                                                                      ])),
                                                            );
                                                          },
                                                        ),
                                                      ))
                                                  : SizedBox.shrink(),
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      margin: EdgeInsets.all(10),
                                      child: ElevatedButton(
                                        style: ButtonStyle(
                                          backgroundColor: MaterialStateProperty
                                              .all<Color>(AppTheme
                                                  .vinho), // Cor de fundo do botão
                                        ),
                                        onPressed: () {
                                          _selectImage(context);
                                        },
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              Icons.add_circle,
                                              size: 23,
                                              color: AppTheme.cinza,
                                            ), // Exemplo de um ícone
                                            Gap(8), // Espaçamento entre o ícone e o texto
                                            Text(
                                              'Add more',
                                              style: AppTheme.subtitlewhite,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Container(
                                      margin: EdgeInsets.all(10),
                                      child: ElevatedButton(
                                        style: ButtonStyle(
                                          backgroundColor: MaterialStateProperty
                                              .all<Color>(AppTheme
                                                  .vinho), // Cor de fundo do botão
                                        ),
                                        onPressed: () {
                                          _showWardrobe(context, user.uid);
                                        },
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            ImageIcon(
                                              AssetImage(
                                                'assets/CABIDE.png',
                                              ),
                                              size: 23,
                                              color: AppTheme.cinza,
                                            ), // Exemplo de um ícone
                                            Gap(8), // Espaçamento entre o ícone e o texto
                                            Text(
                                              'Clothes',
                                              style: AppTheme.subtitlewhite,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ]),
                              _files!.length > 1
                                  ? Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                      ),
                                      child: SizedBox(
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.1,
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
                                                    _pageController
                                                        .animateToPage(
                                                      index,
                                                      duration: const Duration(
                                                          milliseconds: 300),
                                                      curve: Curves.ease,
                                                    );
                                                  });
                                                },
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    border: Border.all(
                                                      color:
                                                          _currentPageIndex ==
                                                                  index
                                                              ? AppTheme.vinho
                                                              : Colors
                                                                  .transparent,
                                                      width: 3.0,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10.0),
                                                  ),
                                                  child: ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10.0),
                                                    child: Image.memory(
                                                      _files![index],
                                                      fit: BoxFit.fill,
                                                    ),
                                                  ),
                                                ));
                                          },
                                        ),
                                      ))
                                  : Gap(
                                      MediaQuery.of(context).size.height * 0.1)
                            ],
                          ),
                        ),
                      ]),
                back: isLoading
                    ? LinearProgressIndicator()
                    : Container(
                        decoration: BoxDecoration(
                          color: AppTheme.nearlyWhite,
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
                                      "Type a description for the product..",
                                  hintStyle: AppTheme.title,
                                  border: InputBorder.none,
                                ),
                              ),
                            ),
                            Gap(20),
                            Divider(
                              color: Colors.grey,
                            ),
                            Text(
                              "Category of the post",
                              style: AppTheme.dividerfont,
                            ),
                            Gap(5),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    'Anonymous Post',
                                    style: AppTheme.subtitle,
                                  ),
                                  Checkbox(
                                    value: isAnonymous,
                                    activeColor:
                                        const Color.fromARGB(0, 124, 78, 78),
                                    checkColor: AppTheme.vinho,
                                    onChanged: (value) {
                                      setState(() {
                                        isAnonymous = value!;
                                      });
                                    },
                                    materialTapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                    visualDensity: VisualDensity.compact,
                                    side: BorderSide(
                                      color: Colors.black,
                                      width: 1.0,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Gap(10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      selectedCategory = 'Public';
                                    });
                                  },
                                  style: ElevatedButton.styleFrom(
                                    primary: selectedCategory == 'Public'
                                        ? AppTheme.vinho
                                        : Colors.grey,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                  ),
                                  child: Text('Public',
                                      style: AppTheme.subtitlewhite),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      selectedCategory = 'Followers';
                                    });
                                  },
                                  style: ElevatedButton.styleFrom(
                                    primary: selectedCategory == 'Followers'
                                        ? AppTheme.vinho
                                        : Colors.grey,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                  ),
                                  child: Text('Followers',
                                      style: AppTheme.subtitlewhite),
                                ),
                                ElevatedButton(
                                    onPressed: () {
                                      setState(() {
                                        exibirList(context, user.uid);
                                        selectedCategory = 'List';
                                      });
                                    },
                                    style: ElevatedButton.styleFrom(
                                      primary: selectedCategory == 'List'
                                          ? AppTheme.vinho
                                          : Colors.grey,
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                      ),
                                    ),
                                    child: categoriaSelecionada == null
                                        ? Text('List',
                                            style: AppTheme.subtitlewhite)
                                        : Text(categoriaSelecionada!,
                                            style: AppTheme.subtitlewhite)),
                              ],
                            ),
                            Gap(MediaQuery.of(context).size.height * 0.003),
                            Divider(
                              color: Colors.grey,
                            ),
                            Text(
                              "Post information",
                              style: AppTheme.dividerfont,
                            ),
                            Expanded(
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Center(
                                        child: Text(
                                          "Marcas de roupas presentes:",
                                          style: AppTheme.title,
                                        ),
                                      ),
                                      Gap(MediaQuery.of(context).size.height *
                                          0.005),
                                      SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.9,
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.08,
                                        child: Row(
                                          children: [
                                            // Item fixo
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(10.0),
                                              child: Container(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.2,
                                                decoration: BoxDecoration(
                                                  color: AppTheme.cinza,
                                                  borderRadius:
                                                      BorderRadius.circular(15),
                                                ),
                                                child: Center(
                                                  child: IconButton(
                                                    onPressed: () {
                                                      exibirTagCard(
                                                          context, categoria1);
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
                                                          marcas!.isNotEmpty
                                                      ? ListView.builder(
                                                          scrollDirection:
                                                              Axis.horizontal,
                                                          itemCount:
                                                              marcas!.length,
                                                          itemBuilder:
                                                              (ctx, index) {
                                                            return Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(
                                                                      10.0),
                                                              child: Stack(
                                                                children: [
                                                                  Container(
                                                                    width: MediaQuery.of(context)
                                                                            .size
                                                                            .width *
                                                                        0.2,
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      color: AppTheme
                                                                          .cinza,
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              15),
                                                                    ),
                                                                    child:
                                                                        Center(
                                                                      child:
                                                                          Text(
                                                                        marcas![
                                                                            index],
                                                                        style: AppTheme
                                                                            .subtitle,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  Positioned(
                                                                    top: 0,
                                                                    right: 0,
                                                                    child:
                                                                        GestureDetector(
                                                                      onTap:
                                                                          () {
                                                                        setState(
                                                                            () {
                                                                          marcas!
                                                                              .remove(marcas![index]);
                                                                        });
                                                                      },
                                                                      child:
                                                                          Container(
                                                                        padding:
                                                                            EdgeInsets.all(2),
                                                                        decoration:
                                                                            BoxDecoration(
                                                                          shape:
                                                                              BoxShape.circle,
                                                                          color:
                                                                              Colors.white,
                                                                        ),
                                                                        child:
                                                                            Icon(
                                                                          Icons
                                                                              .close,
                                                                          color:
                                                                              Colors.black,
                                                                          size:
                                                                              12,
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
                                                    const EdgeInsets.all(10.0),
                                                child: Container(
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.2,
                                                  decoration: BoxDecoration(
                                                    color: AppTheme.cinza,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            15),
                                                  ),
                                                  child: Center(
                                                    child: IconButton(
                                                      onPressed: () {
                                                        exibirTagCard(context,
                                                            categoria2);
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
                                                      tecido != null &&
                                                              tecido!.isNotEmpty
                                                          ? ListView.builder(
                                                              scrollDirection:
                                                                  Axis.horizontal,
                                                              itemCount: tecido!
                                                                  .length,
                                                              itemBuilder:
                                                                  (ctx, index) {
                                                                return Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .all(
                                                                          10.0),
                                                                  child: Stack(
                                                                    children: [
                                                                      Container(
                                                                        width: MediaQuery.of(context).size.width *
                                                                            0.2,
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
                                                                            style:
                                                                                AppTheme.subtitle,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      Positioned(
                                                                        top: 0,
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
                                                                            padding:
                                                                                EdgeInsets.all(2),
                                                                            decoration:
                                                                                BoxDecoration(
                                                                              shape: BoxShape.circle,
                                                                              color: Colors.white,
                                                                            ),
                                                                            child:
                                                                                Icon(
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
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 26,
                                        ),
                                        child: Text(
                                          "Para qual local ou ocasião você vai usar o look?",
                                          style: AppTheme.title,
                                        ),
                                      ),
                                      Gap(MediaQuery.of(context).size.height *
                                          0.002),
                                      SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.9,
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.08,
                                        child: Row(
                                          children: [
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(10.0),
                                              child: Container(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.2,
                                                decoration: BoxDecoration(
                                                  color: AppTheme.cinza,
                                                  borderRadius:
                                                      BorderRadius.circular(15),
                                                ),
                                                child: Center(
                                                  child: IconButton(
                                                    onPressed: () {
                                                      exibirTagCard(
                                                          context, categoria3);
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
                                                    where != null &&
                                                            where!.isNotEmpty
                                                        ? ListView.builder(
                                                            scrollDirection:
                                                                Axis.horizontal,
                                                            itemCount:
                                                                where!.length,
                                                            itemBuilder:
                                                                (ctx, index) {
                                                              return Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .all(
                                                                        10.0),
                                                                child: Stack(
                                                                  children: [
                                                                    Container(
                                                                      decoration:
                                                                          BoxDecoration(
                                                                        color: AppTheme
                                                                            .cinza,
                                                                        borderRadius:
                                                                            BorderRadius.circular(15),
                                                                      ),
                                                                      child:
                                                                          Center(
                                                                        child: Padding(
                                                                            padding: EdgeInsets.symmetric(horizontal: 10),
                                                                            child: Text(
                                                                              where![index],
                                                                              style: AppTheme.subtitle,
                                                                            )),
                                                                      ),
                                                                    ),
                                                                    Positioned(
                                                                      top: 0,
                                                                      right: 0,
                                                                      child:
                                                                          GestureDetector(
                                                                        onTap:
                                                                            () {
                                                                          setState(
                                                                              () {
                                                                            where!.remove(where![index]);
                                                                          });
                                                                        },
                                                                        child:
                                                                            Container(
                                                                          padding:
                                                                              EdgeInsets.all(2),
                                                                          decoration:
                                                                              BoxDecoration(
                                                                            shape:
                                                                                BoxShape.circle,
                                                                            color:
                                                                                Colors.white,
                                                                          ),
                                                                          child:
                                                                              Icon(
                                                                            Icons.close,
                                                                            color:
                                                                                Colors.black,
                                                                            size:
                                                                                12,
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
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ))));
  }
}
