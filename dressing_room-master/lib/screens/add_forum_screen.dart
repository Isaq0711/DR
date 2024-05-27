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

class AddForumScreen extends StatefulWidget {
  final Uint8List? image;

  const AddForumScreen({Key? key, this.image}) : super(key: key);

  @override
  _AddForumScreenState createState() => _AddForumScreenState();
}

class _AddForumScreenState extends State<AddForumScreen> {
  bool isAnonymous = false;

  String categoria1 = 'Marcas de roupas presentes';
  String categoria2 = 'Tecido da roupa';
  String categoria3 = 'Locais ou ocasião';
  String? categoriaSelecionada;
  List<String>? pecasID;
  List<String>? pecasPhotoUrls;

  List<Object> getMergedList() {
    List<Object> mergedList = [];
    if (pecasPhotoUrls != null) {
      mergedList.addAll(pecasPhotoUrls!);
    }
    if (_files != null) {
      mergedList.addAll(_files!);
    }
    return mergedList;
  }

  List<Uint8List>? _files;
  bool isLoading = false;

  final TextEditingController _descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _files = [];
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

  _selectImage(BuildContext parentContext) async {
    showDialog(
      context: parentContext,
      builder: (BuildContext context) {
        return SelectImageDialog1por1(
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
        // String res = await FireStoreMethods().uploadAnonymousPost(
        //   _descriptionController.text,
        //   _files!,
        //   pecasID,
        //   pecasPhotoUrls,
        //   uid,
        // );
        // if (res == "success") {
        //   showSnackBar(
        //     context,
        //     'Posted!',
        //   );
        //   clearImages();
        // } else {
        //   showSnackBar(context, res);
        // }
      } else {
        String res = await FireStoreMethods().uploadForum(
          _descriptionController.text,
          _files!,
          pecasID,
          pecasPhotoUrls,
          uid,
          username,
          profImage,
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

  @override
  void dispose() {
    super.dispose();
    _descriptionController.dispose();
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
    var mergedList = getMergedList();
    return _files == null
        ? Scaffold(
            body: Container(),
          )
        : Scaffold(
            resizeToAvoidBottomInset: false,
            appBar: AppBar(
                backgroundColor: Colors.transparent,
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
            body: isLoading
                ? Center(
                    child: CircularProgressIndicator(),
                  )
                : ListView(
                    children: <Widget>[
                      Column(
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
                                padding: EdgeInsets.symmetric(horizontal: 8),
                                child: Column(
                                  children: [
                                    TextField(
                                      controller: _descriptionController,
                                      style: AppTheme.title,
                                      decoration: InputDecoration(
                                        hintText:
                                            "Escreva a descrição para o fórum..",
                                        hintStyle: AppTheme.title,
                                        border: InputBorder.none,
                                      ),
                                      minLines: 1,
                                      maxLines: null,
                                    ),
                                    pecasPhotoUrls != null
                                        ? SizedBox.shrink()
                                        : SizedBox(height: 150)
                                  ],
                                ),
                              )),
                        ],
                      ),
                      mergedList.isNotEmpty
                          ? Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 10),
                              child: SizedBox(
                                height: 100.h,
                                width: double.infinity,
                                child: GridView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: mergedList.length,
                                  gridDelegate:
                                      SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 1,
                                  ),
                                  itemBuilder: (context, index) {
                                    var item = mergedList[index];
                                    return Stack(
                                      children: [
                                        Padding(
                                          padding: EdgeInsets.all(5),
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(10.0),
                                            child: item is String
                                                ? Image.network(
                                                    item,
                                                    fit: BoxFit.fill,
                                                    width: double.infinity,
                                                    height: double.infinity,
                                                  )
                                                : Image.memory(
                                                    item as Uint8List,
                                                    fit: BoxFit.fill,
                                                    width: double.infinity,
                                                    height: double.infinity,
                                                  ),
                                          ),
                                        ),
                                        Positioned(
                                          top: 0,
                                          right: 3,
                                          child: GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                if (item is String) {
                                                  pecasPhotoUrls!.remove(item);
                                                } else {
                                                  _files!.remove(item);
                                                }
                                              });
                                            },
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: AppTheme.vinho,
                                                borderRadius:
                                                    BorderRadius.circular(16.0),
                                              ),
                                              child: Padding(
                                                padding: EdgeInsets.all(3),
                                                child: Icon(
                                                  Icons.delete,
                                                  color: AppTheme.nearlyWhite,
                                                  size: 18,
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
                            )
                          : SizedBox.shrink(),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              margin: EdgeInsets.all(10),
                              child: ElevatedButton(
                                style: ButtonStyle(
                                  backgroundColor:
                                      MaterialStateProperty.all<Color>(AppTheme
                                          .vinho), // Cor de fundo do botão
                                ),
                                onPressed: () {
                                  _selectImage(context);
                                },
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.camera_alt_sharp,
                                      size: 23,
                                      color: AppTheme.cinza,
                                    ), // Exemplo de um ícone
                                    Gap(8), // Espaçamento entre o ícone e o texto
                                    Text(
                                      'Add a picture',
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
                                  backgroundColor:
                                      MaterialStateProperty.all<Color>(AppTheme
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
                                      'Tag clothes',
                                      style: AppTheme.subtitlewhite,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ]),
                    ],
                  ),
          );
  }
}
