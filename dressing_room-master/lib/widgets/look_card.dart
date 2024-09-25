import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dressing_room/screens/add_post_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:dressing_room/models/user.dart' as model;
import 'package:dressing_room/screens/seepost.dart';
import 'package:dressing_room/providers/user_provider.dart';
import 'package:dressing_room/screens/profile_screen.dart';
import 'package:dressing_room/utils/colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:dressing_room/utils/utils.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LookCard extends StatefulWidget {
  final snap;

  const LookCard({
    Key? key,
    required this.snap,
  }) : super(key: key);

  @override
  State<LookCard> createState() => _LookCardState();
}

class _LookCardState extends State<LookCard> {
  bool isOnMyWardrobe = false;
  bool showinfo = true;
  bool isLoading = false;
  bool showreactions = false;
  List<String> allIds = [];
  List<String> allPhotoUrls = [];
  bool isFavorite = false;
  String? username;
  String? userquecriou;
  String? profilePhoto;
  double rating = 0;

  @override
  void initState() {
    super.initState();
    getData();
  }

  getData() async {
    setState(() {
      isLoading = true;
    });
    try {
      allIds.add(widget.snap['troncoId']);
      allIds.add(widget.snap['pernasId']);
      allIds.add(widget.snap['pesId']);

      var userSnap = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.snap['uid'])
          .get();

      setState(() {
        username = userSnap['username'];
        profilePhoto = userSnap['photoUrl'];
        userquecriou = userSnap['uid'];
      });
      setState(() {});
      for (String id in allIds) {
        var clothesSnap = await FirebaseFirestore.instance
            .collection('clothes')
            .doc(id)
            .get();

        if (clothesSnap.exists) {
          allPhotoUrls.add(clothesSnap['photoUrl']);
        }
      }

      setState(() {
        // Aqui você pode adicionar allPhotoUrls a um estado específico, se necessário
        allPhotoUrls =
            allPhotoUrls; // Supondo que você tenha uma variável para armazenar isso
      });
    } catch (e) {
      showSnackBar(
        context,
        e.toString(),
      );
    }
    setState(() {
      isLoading = false;
    });
  }

  getIds() {}

  void _showClothes(context) {
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
                child: Expanded(
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
                      child: InkWell(
                        child: Text('Peças', style: AppTheme.barapp),
                        onTap: () {
                          print(allIds);
                        },
                        onDoubleTap: () {
                          getIds();
                        },
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 70),
                      child: SizedBox(
                        height: 580.h,
                        child: ListView.builder(
                          itemCount: allIds.length,
                          itemBuilder: (context, index) {
                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => SeePost(
                                      isSuggestioncliked: false,
                                      isTagclicked: false,
                                      postId: allIds[index],
                                    ),
                                  ),
                                );
                              },
                              child: Padding(
                                padding: EdgeInsets.all(6.h),
                                child: Material(
                                  borderRadius: BorderRadius.circular(10.0),
                                  elevation: 3.0,
                                  child: Container(
                                    height: 160.h,
                                    decoration: BoxDecoration(
                                      color: Colors.grey[100],
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(10.0),
                                      child: Image.network(
                                        allPhotoUrls[index],
                                        fit: BoxFit.contain,
                                        height: 150.h,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ))));
      },
    );
  }

  void showDeleteItemDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppTheme.nearlyWhite,
          title: Align(
            alignment: Alignment.center,
            child: Text(
              'Você deseja remover essa roupa?',
              style: AppTheme.subheadline,
            ),
          ),
          content: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ElevatedButton(
                child: Text(
                  'Não',
                  style: TextStyle(
                    fontFamily: 'Quicksand',
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(primary: AppTheme.vinho),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              Gap(10),
              ElevatedButton(
                child: Text(
                  'Sim',
                  style: TextStyle(
                    fontFamily: 'Quicksand',
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(primary: AppTheme.vinho),
                onPressed: () async {
                  // deletePost(widget.snap['lookId']);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, _) {
        model.User? user = userProvider.getUser;

        if (user == null) {
          return Container();
        }

        if (isLoading) {
          return Center(
            child: CircularProgressIndicator(
              color: Colors.blue,
            ),
          );
        }

        return Column(children: [
          GestureDetector(
            onHorizontalDragUpdate: (details) {
              if (details.primaryDelta! > 0) {
                Navigator.pop(context);
              }
            },
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                    height: 690.h,
                    child: AspectRatio(
                        aspectRatio: 9 / 16,
                        child: InteractiveViewer(
                            panEnabled: true,
                            minScale: 0.1,
                            maxScale: 4,
                            child: ClipRRect(
                                borderRadius: BorderRadius.circular(10.0),
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      showinfo = !showinfo;
                                    });
                                  },
                                  child: Image.network(
                                    widget.snap['look'],
                                    fit: BoxFit.contain,
                                  ),
                                ))))),
                Positioned(
                  top: 5,
                  right: 10,
                  child: Column(
                    children: [
                      SizedBox(
                        width: 35.0,
                        height: 38.0,
                        child: FloatingActionButton(
                          onPressed: () {
                            setState(() {
                              _showClothes(context);
                            });
                          },
                          backgroundColor: AppTheme.cinza,
                          elevation: 8.0,
                          shape:
                              CircleBorder(), // Makes the button more circular
                          child: Icon(
                            CupertinoIcons.tag,
                            size: 22,
                            color: AppTheme.nearlyBlack,
                          ),
                        ),
                      ),
                      Gap(5.h),
                      SizedBox(
                        width: 35.0,
                        height: 38.0,
                        child: FloatingActionButton(
                          onPressed: () async {
                            setState(() {
                              isLoading = true;
                            });

                            // Tente buscar a imagem da URL
                            try {
                              final response = await http
                                  .get(Uri.parse(widget.snap['look']));

                              if (response.statusCode == 200) {
                                // Converte a resposta em Uint8List
                                Uint8List imageBytes = response.bodyBytes;

                                // Navega para a tela de AddPost passando a imagem
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        AddPostScreen(image: imageBytes),
                                  ),
                                );
                              } else {
                                // Trate erros se a requisição falhar
                                showSnackBar(
                                    context, 'Erro ao carregar a imagem');
                              }
                            } catch (e) {
                              // Trate exceções
                              showSnackBar(context, e.toString());
                            }

                            setState(() {
                              isLoading = false;
                            });
                          },
                          backgroundColor: AppTheme.cinza,
                          elevation: 8.0,
                          shape:
                              CircleBorder(), // Makes the button more circular
                          child: Icon(
                            Icons.public,
                            size: 22,
                            color: AppTheme.nearlyBlack,
                          ),
                        ),
                      ),
                      FirebaseAuth.instance.currentUser!.uid !=
                              widget.snap['uid']
                          ? SizedBox(
                              width: 35.0,
                              height: 38.0,
                              child: FloatingActionButton(
                                  onPressed: () {
                                    showDeleteItemDialog(context);
                                  },
                                  backgroundColor: AppTheme.cinza,
                                  elevation: 8.0,
                                  shape:
                                      CircleBorder(), // Makes the button more circular
                                  child: Icon(
                                    Icons.delete_outline,
                                    color: Colors.black.withOpacity(0.6),
                                    size: 22,
                                  )),
                            )
                          : SizedBox.shrink(),
                    ],
                  ),
                ),
                Positioned(
                    bottom: 0,
                    left: 0,
                    child: Visibility(
                        visible: showinfo,
                        child: SizedBox(
                            width: MediaQuery.of(context).size.width,
                            child: Container(
                                color: AppTheme.cinza,
                                width: double.infinity,
                                child: Column(
                                  children: [
                                    Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 5),
                                        child: Column(children: [
                                          Row(
                                            children: <Widget>[
                                              CircleAvatar(
                                                radius: 16,
                                                backgroundImage: NetworkImage(
                                                  profilePhoto.toString(),
                                                ),
                                                backgroundColor: Colors
                                                    .transparent, // Define o fundo como transparente
                                              ),
                                              Expanded(
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                    left: 8,
                                                  ),
                                                  child: Column(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: <Widget>[
                                                      InkWell(
                                                        onTap: () {
                                                          Navigator.of(context)
                                                              .push(
                                                            MaterialPageRoute(
                                                              builder: (context) =>
                                                                  ProfileScreen(
                                                                uid:
                                                                    widget.snap[
                                                                        'uid'],
                                                                isMainn: false,
                                                              ),
                                                            ),
                                                          );
                                                        },
                                                        child: Text(
                                                            username.toString(),
                                                            style: AppTheme
                                                                .subtitle),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          Gap(10),
                                        ])),
                                  ],
                                  mainAxisAlignment: MainAxisAlignment.end,
                                ))))),
              ],
            ),
          ),
          Gap(15),
        ]);
      },
    );
  }
}
