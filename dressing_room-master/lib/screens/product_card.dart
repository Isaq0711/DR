import 'package:dressing_room/screens/store_screen.dart';
import 'package:gap/gap.dart';
import 'package:flutter/material.dart';
import 'package:dressing_room/models/user.dart' as model;
import 'package:dressing_room/providers/user_provider.dart';
import 'package:dressing_room/resources/firestore_methods.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:dressing_room/utils/colors.dart';
import 'package:dressing_room/models/products.dart';
import 'package:dressing_room/utils/utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:dressing_room/screens/shopping_cart.dart';

class ProductCard extends StatefulWidget {
  final dynamic snap;

  const ProductCard({
    Key? key,
    required this.snap,
  }) : super(key: key);

  @override
  _ProductCardState createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  String selectedSize = "";
  bool showinfo = true;
  bool isLoading = false;
  bool isAddedOnFav = false;
  bool isFavorite = false;
  int _currentPageIndex = 0;
  int _currentPhotoIndex = 0;

  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    isOnFav(
      widget.snap['productId'],
    );
    _pageController = PageController(initialPage: 0);
  }

  Future<bool> isOnFav(String postId) async {
    try {
      DocumentSnapshot fav = await FirebaseFirestore.instance
          .collection('favorites')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection('userFavorites')
          .doc(postId)
          .get();

      if (fav.exists) {
        setState(() {
          isAddedOnFav = true; // Defina o estado inicial do ícone
        });
        return true;
      } else {
        setState(() {
          isAddedOnFav = false; // Defina o estado inicial do ícone
        });
        return false;
      }
    } catch (e) {
      showSnackBar(
        context,
        e.toString(),
      );
      return false;
    }
  }

  Future<void> handleFavAction(String uid) async {
    setState(() {});

    try {
      await FireStoreMethods().toggleFavorite(widget.snap['productId'], uid);
    } catch (err) {
      showSnackBar(context, err.toString());
    }

    setState(() {});
  }

  void addtocart(String uid) async {
    setState(() {
      isLoading = true;
    });
    try {
      String res = await FireStoreMethods().uploadtoCart(
          widget.snap['description'],
          uid,
          widget.snap['username'],
          widget.snap['productId'],
          widget.snap['type'],
          widget.snap['variations'][_currentPageIndex]['variationdescription'],
          selectedSize,
          widget.snap['variations'][_currentPageIndex]['photoUrls'][0],
          widget.snap['variations'][_currentPageIndex]['price'],
          context);

      if (res == "success") {
      } else {
        showSnackBar(context, res);
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

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, _) {
        model.User? user = userProvider.getUser;
        final width = MediaQuery.of(context).size.width;

        var size = MediaQuery.of(context).size;

        if (user == null) {
          return Container();
        }

        return Column(
          children: [
            GestureDetector(
              onTap: () {
                setState(() {
                  showinfo = !showinfo;
                });
              },
              onDoubleTap: () {
                print(selectedSize);
              },
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    height: 690.h,
                    child: AspectRatio(
                      aspectRatio: 9 / 16,
                      child: PageView.builder(
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: widget.snap['variations'].length,
                        controller: _pageController,
                        onPageChanged: (index) {
                          setState(() {
                            if (_currentPageIndex != index) {
                              _currentPageIndex = index;
                              _currentPhotoIndex =
                                  0; // Reset photo index when variation changes
                            }
                          });
                        },
                        itemBuilder: (context, index) {
                          return PageView.builder(
                            itemCount: widget
                                .snap['variations'][index]['photoUrls'].length,
                            controller:
                                PageController(initialPage: _currentPhotoIndex),
                            onPageChanged: (photoIndex) {
                              setState(() {
                                _currentPhotoIndex = photoIndex;
                              });
                            },
                            itemBuilder: (context, photoIndex) {
                              return ClipRRect(
                                borderRadius: BorderRadius.circular(10.0),
                                child: Image.network(
                                  widget.snap['variations'][index]['photoUrls']
                                          [photoIndex]
                                      .toString(),
                                  fit: BoxFit.contain,
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ),
                  Positioned(
                      top: 5,
                      right: 10,
                      child: Column(children: [
                        Gap(5.h),
                        SizedBox(
                          width: 35.0,
                          height: 38.0,
                          child: FloatingActionButton(
                              onPressed: () {
                                setState(() {
                                  isAddedOnFav = !isAddedOnFav;
                                  Future.delayed(Duration(milliseconds: 500),
                                      () {
                                    isAddedOnFav
                                        ? showSnackBar(
                                            context, 'Added to Favorites')
                                        : showSnackBar(
                                            context, 'Removed from Favorites');
                                  });
                                });
                                Future.microtask(() {
                                  handleFavAction(
                                      FirebaseAuth.instance.currentUser!.uid);
                                });
                              },
                              backgroundColor: AppTheme.cinza,
                              elevation: 8.0,
                              shape:
                                  CircleBorder(), // Makes the button more circular
                              child: isAddedOnFav
                                  ? Icon(
                                      Icons.folder_copy_rounded,
                                      color: Colors.black.withOpacity(0.6),
                                      size: 22,
                                    )
                                  : Icon(
                                      Icons.folder_copy_outlined,
                                      color: Colors.black.withOpacity(0.6),
                                      size: 22,
                                    )),
                        ),
                      ])),
                  Positioned(
                      bottom: -19,
                      left: 0,
                      child: Visibility(
                          visible: showinfo,
                          child: SizedBox(
                              width: MediaQuery.of(context).size.width,
                              child: Container(
                                color: AppTheme.cinza,
                                width: double.infinity,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Center(
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 4.5),
                                        child: widget
                                                    .snap['variations']
                                                        [_currentPageIndex]
                                                        ['photoUrls']
                                                    .length >
                                                1
                                            ? DotsIndicator(
                                                dotsCount: widget
                                                    .snap['variations']
                                                        [_currentPageIndex]
                                                        ['photoUrls']
                                                    .length,
                                                position: _currentPhotoIndex,
                                                decorator: DotsDecorator(
                                                  color: AppTheme.nearlyWhite,
                                                  activeColor: AppTheme.vinho,
                                                  spacing: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 4.0),
                                                  size: const Size.square(8.0),
                                                  activeSize:
                                                      const Size(16.0, 8.0),
                                                  activeShape:
                                                      RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            4.0),
                                                  ),
                                                ),
                                              )
                                            : SizedBox.shrink(),
                                      ),
                                    ),
                                    SizedBox(
                                      child: Padding(
                                        padding: const EdgeInsets.all(10.0),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              padding: EdgeInsets.symmetric(
                                                horizontal: 10,
                                              ).copyWith(right: 0),
                                              child: Row(
                                                children: <Widget>[
                                                  CircleAvatar(
                                                    radius: 16,
                                                    backgroundImage:
                                                        NetworkImage(
                                                      widget.snap['profImage'],
                                                    ),
                                                    backgroundColor: Colors
                                                        .transparent, // Define o fundo como transparente
                                                  ),
                                                  Expanded(
                                                    child: Padding(
                                                      padding: EdgeInsets.only(
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
                                                              Navigator.of(
                                                                      context)
                                                                  .push(
                                                                MaterialPageRoute(
                                                                  builder:
                                                                      (context) =>
                                                                          StoreScreen(
                                                                    storeId: widget
                                                                            .snap[
                                                                        'uid'],
                                                                  ),
                                                                ),
                                                              );
                                                            },
                                                            child: Text(
                                                              widget.snap[
                                                                  'username'],
                                                              style: AppTheme
                                                                  .subtitle,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Gap(10.h),
                                            Padding(
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 10.w),
                                                child: Row(
                                                  children: [
                                                    Expanded(
                                                      child: Text(
                                                        widget.snap[
                                                            'description'],
                                                        style: AppTheme
                                                            .subheadline,
                                                      ),
                                                    ),
                                                    Spacer(),
                                                    Text(
                                                      '\$${widget.snap['variations'][_currentPageIndex]['price'].toString()}',
                                                      style: AppTheme
                                                          .subheadlinevinho,
                                                    ),
                                                  ],
                                                )),
                                            Padding(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 15.w,
                                                  vertical: 5),
                                              child: Row(
                                                children: [
                                                  widget.snap['variations']
                                                              .length >
                                                          1
                                                      ? Text(
                                                          "Selecionar variação: ",
                                                          style:
                                                              AppTheme.subtitle,
                                                        )
                                                      : Container(),
                                                  Spacer(),
                                                  Text(
                                                    '${widget.snap['variations'][_currentPageIndex]['itemCount'].toString()} ${widget.snap['variations'][_currentPageIndex]['itemCount'] == 1 ? 'Item disponível' : 'Itens disponíveis'}',
                                                    style: AppTheme.caption,
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Column(children: [
                                              if (widget.snap['variations']
                                                      .length >
                                                  1)
                                                Column(
                                                  children: [
                                                    SizedBox(
                                                      height: size.height * 0.1,
                                                      child: GridView.builder(
                                                        scrollDirection:
                                                            Axis.horizontal,
                                                        itemCount: widget.snap[
                                                                    'variations'] !=
                                                                null
                                                            ? widget
                                                                .snap[
                                                                    'variations']
                                                                .length
                                                            : 0,
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

                                                                _currentPhotoIndex =
                                                                    0;
                                                                _pageController
                                                                    .jumpToPage(
                                                                        _currentPageIndex);
                                                              });
                                                            },
                                                            child: Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(8.0),
                                                              child:
                                                                  AnimatedContainer(
                                                                decoration:
                                                                    BoxDecoration(
                                                                  border: Border
                                                                      .all(
                                                                    color: _currentPageIndex ==
                                                                            index
                                                                        ? AppTheme
                                                                            .vinho
                                                                        : Colors
                                                                            .transparent,
                                                                    width: 4,
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
                                                                child:
                                                                    ClipRRect(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              8),
                                                                  child: Image
                                                                      .network(
                                                                    widget.snap[
                                                                            'variations']
                                                                            [
                                                                            index]
                                                                            [
                                                                            'photoUrls']
                                                                            [0]
                                                                        .toString(),
                                                                    fit: BoxFit
                                                                        .contain,
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          );
                                                        },
                                                      ),
                                                    ),
                                                    Align(
                                                        alignment: Alignment
                                                            .centerLeft,
                                                        child: Text(
                                                          "Variação selecionada: " +
                                                              '${widget.snap['variations'][_currentPageIndex]['variationdescription']}',
                                                          style:
                                                              AppTheme.caption,
                                                        )),
                                                    Gap(
                                                      size.height * 0.010,
                                                    ),
                                                  ],
                                                )
                                            ]),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ))))
                ],
              ),
            ),
            Gap(15),
            Padding(
              padding: const EdgeInsets.only(
                left: 20.0,
                top: 10.0,
              ),
              child: Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    "Selecionar tamanho:",
                    style: AppTheme.subtitle,
                  )),
            ),
            SizedBox(
              width: size.width * 0.9,
              height: size.height * 0.08,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: widget
                    .snap['variations'][_currentPageIndex]['sizesAvailable']
                    .length,
                itemBuilder: (ctx, index) {
                  var currentSize = widget.snap['variations'][_currentPageIndex]
                      ['sizesAvailable'][index];
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedSize = currentSize;
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: AnimatedContainer(
                        width: size.width * 0.12,
                        decoration: BoxDecoration(
                          color: selectedSize == currentSize
                              ? AppTheme.vinho
                              : Colors.transparent,
                          border: Border.all(
                            color: AppTheme.vinho,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        duration: const Duration(milliseconds: 200),
                        child: Center(
                          child: Text(
                            currentSize, // Exibe o tamanho correto em vez do índice
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w500,
                              color: selectedSize == currentSize
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
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Center(
                child: ElevatedButton(
                  onPressed: () {
                    addtocart(FirebaseAuth.instance.currentUser!.uid);
                    showModalBottomSheet(
                      context: context,
                      builder: (context) {
                        return Container(
                          color: AppTheme.cinza,
                          padding: EdgeInsets.all(16),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.check_circle,
                                    color: AppTheme.vinho,
                                  ),
                                  Gap(
                                    size.width * 0.01,
                                  ),
                                  Text(
                                    "Adicionado ao carrinho",
                                    style: AppTheme.subtitle,
                                  )
                                ],
                              ),
                              Gap(
                                size.height * 0.02,
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    width: size.width * 0.45,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      color: AppTheme.vinho,
                                    ),
                                    child: TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      child: Text('Continuar comprando',
                                          style: AppTheme.subtitlewhite),
                                    ),
                                  ),
                                  Container(
                                    width: size.width * 0.45,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      color: AppTheme.vinho,
                                    ),
                                    child: TextButton(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  ShoppingCart(
                                                      uid: FirebaseAuth.instance
                                                          .currentUser!.uid)),
                                        );
                                      },
                                      child: Text(
                                        'Ir para o\n Carrinho',
                                        style: AppTheme.subtitlewhite,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Adicionar ao carrinho',
                          style: TextStyle(fontSize: 16),
                        ),
                        Gap(8),
                        Icon(
                          Icons.shopping_cart,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    primary: AppTheme.vinho,
                    onPrimary: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
            )
          ],
        );
      },
    );
  }
}
