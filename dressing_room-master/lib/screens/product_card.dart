import 'package:dressing_room/screens/store_screen.dart';
import 'package:gap/gap.dart';
import 'package:flutter/material.dart';
import 'package:dressing_room/models/user.dart' as model;
import 'package:dressing_room/providers/user_provider.dart';
import 'package:dressing_room/resources/firestore_methods.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:dressing_room/utils/colors.dart';
import 'package:dressing_room/utils/utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:dressing_room/screens/shopping_cart.dart';
import 'package:dots_indicator/dots_indicator.dart';

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
  int selectedSize = 0;
  bool showinfo = true;
  bool isLoading = false;
  Map<String, List<String>> categorySizes = {
    'Pernas': ['34', '36', '38', '40', '42', '44'],
    'Pés': ['34', '35', '36', '37', '38', '39', '40', '41', '42'],
    'Tronco': ['PP', 'P', 'M', 'G', 'GG', 'XGG'],
    'Body (corpo inteiro)': ['PP', 'P', 'M', 'G', 'GG', 'XGG'],
    'Top (cabeça)': ['P', 'M', 'G'],
    "Mão": [],
    "Pulso": [],
    "Pescoço": [],
    "Cintura": ['34', '36', '38', '40', '42', '44'],
    'Rosto': [],
  };
  int _currentPageIndex = 0;
  int _currentPhotoIndex = 0;
  List<String> availableSizes = [];
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    generateAvailableSizes();
    _pageController = PageController(initialPage: 0);
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
          availableSizes[selectedSize],
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

  void generateAvailableSizes() {
    List<dynamic>? sizesIndices = widget.snap['variations'][_currentPageIndex]
        ['sizesAvailable'] as List<dynamic>;

    if (sizesIndices.isNotEmpty) {
      String selectedCategory = widget.snap['category'];

      availableSizes = sizesIndices.map((index) {
        return categorySizes[selectedCategory]![index];
      }).toList();
    }
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onDoubleTap: () {},
              onTap: () {
                setState(() {
                  showinfo = !showinfo;
                });
              },
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    height: 690.h,
                    child: AspectRatio(
                      aspectRatio: 9 / 16,
                      child: PageView.builder(
                        itemCount: widget
                            .snap['variations'][_currentPageIndex]['photoUrls']
                            .length,
                        controller: _pageController,
                        onPageChanged: (index) {
                          setState(() {
                            if (_currentPhotoIndex != index) {
                              setState(() {
                                _currentPhotoIndex = index;
                                print(_currentPhotoIndex);
                                print(index);
                              });
                            } else {
                              _pageController.jumpToPage(_currentPhotoIndex);
                            }
                          });
                        },
                        itemBuilder: (context, index) {
                          return ClipRRect(
                            borderRadius: BorderRadius.circular(10.0),
                            child: Image.network(
                              widget.snap['variations'][_currentPageIndex]
                                      ['photoUrls'][_currentPhotoIndex]
                                  .toString(),
                              fit: BoxFit.cover,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
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
                                                        [_currentPageIndex]![
                                                        'photoUrls']
                                                    .length >
                                                1
                                            ? DotsIndicator(
                                                dotsCount: widget
                                                        .snap['variations'][
                                                            _currentPageIndex]![
                                                            'photoUrls']
                                                        .length ??
                                                    0,
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
                                            Gap(15),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    widget.snap['description'],
                                                    style: AppTheme.subheadline,
                                                  ),
                                                ),
                                                Gap(10),
                                                Text(
                                                  '\$${widget.snap['variations'][_currentPageIndex]['price'].toString()}',
                                                  style:
                                                      AppTheme.subheadlinevinho,
                                                ),
                                              ],
                                            ),
                                            Gap(
                                              size.height * 0.006,
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 10.0,
                                                  top: 18.0,
                                                  bottom: 10.0),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  widget.snap['variations']
                                                              .length >
                                                          1
                                                      ? Text(
                                                          "Selecionar variação",
                                                          style: AppTheme.title,
                                                        )
                                                      : Container(),
                                                  Text(
                                                    '${widget.snap['variations'][_currentPageIndex]['itemCount'].toString()}' +
                                                        " Items disponíveis",
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
                                                                generateAvailableSizes();
                                                                _currentPhotoIndex =
                                                                    0;
                                                                _pageController
                                                                    .jumpToPage(
                                                                        0);
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
                                                                        .cover,
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          );
                                                        },
                                                      ),
                                                    ),
                                                    Gap(
                                                      size.height * 0.003,
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
                                                      size.height * 0.006,
                                                    ),
                                                  ],
                                                )
                                            ]),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                left: 10.0,
                                                top: 10.0,
                                              ),
                                              child: Text(
                                                "Selecionar tamanho",
                                                style: AppTheme.dividerfont
                                                    .copyWith(
                                                        fontSize: 13,
                                                        color: AppTheme
                                                            .nearlyBlack),
                                              ),
                                            ),
                                            SizedBox(
                                              width: size.width * 0.9,
                                              height: size.height * 0.08,
                                              child: ListView.builder(
                                                scrollDirection:
                                                    Axis.horizontal,
                                                itemCount:
                                                    availableSizes.length,
                                                itemBuilder: (ctx, index) {
                                                  var currentSize =
                                                      availableSizes[index];
                                                  return GestureDetector(
                                                    onTap: () {
                                                      setState(() {
                                                        selectedSize = index;
                                                      });
                                                    },
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              10.0),
                                                      child: AnimatedContainer(
                                                        width:
                                                            size.width * 0.12,
                                                        decoration:
                                                            BoxDecoration(
                                                          color: selectedSize ==
                                                                  index
                                                              ? AppTheme.vinho
                                                              : Colors
                                                                  .transparent,
                                                          border: Border.all(
                                                            color:
                                                                AppTheme.vinho,
                                                            width: 2,
                                                          ),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(15),
                                                        ),
                                                        duration:
                                                            const Duration(
                                                                milliseconds:
                                                                    200),
                                                        child: Center(
                                                          child: Text(
                                                            currentSize,
                                                            style: TextStyle(
                                                              fontSize: 17,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                              color:
                                                                  selectedSize ==
                                                                          index
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
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(10.0),
                                              child: Center(
                                                child: ElevatedButton(
                                                  onPressed: () {
                                                    addtocart(FirebaseAuth
                                                        .instance
                                                        .currentUser!
                                                        .uid);
                                                    showModalBottomSheet(
                                                      context: context,
                                                      builder: (context) {
                                                        return Container(
                                                          color: AppTheme.cinza,
                                                          padding:
                                                              EdgeInsets.all(
                                                                  16),
                                                          child: Column(
                                                            mainAxisSize:
                                                                MainAxisSize
                                                                    .min,
                                                            children: [
                                                              Row(
                                                                children: [
                                                                  Icon(
                                                                    Icons
                                                                        .check_circle,
                                                                    color: AppTheme
                                                                        .vinho,
                                                                  ),
                                                                  Gap(
                                                                    size.width *
                                                                        0.01,
                                                                  ),
                                                                  Text(
                                                                    "Added to cart",
                                                                    style: AppTheme
                                                                        .subtitle,
                                                                  )
                                                                ],
                                                              ),
                                                              Gap(
                                                                size.height *
                                                                    0.02,
                                                              ),
                                                              Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .spaceBetween,
                                                                children: [
                                                                  Container(
                                                                    width: size
                                                                            .width *
                                                                        0.45,
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              8),
                                                                      color: AppTheme
                                                                          .vinho,
                                                                    ),
                                                                    child:
                                                                        TextButton(
                                                                      onPressed:
                                                                          () {
                                                                        Navigator.pop(
                                                                            context);
                                                                      },
                                                                      child: Text(
                                                                          'Continue Shopping',
                                                                          style:
                                                                              AppTheme.subtitlewhite),
                                                                    ),
                                                                  ),
                                                                  Container(
                                                                    width: size
                                                                            .width *
                                                                        0.45,
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              8),
                                                                      color: AppTheme
                                                                          .vinho,
                                                                    ),
                                                                    child:
                                                                        TextButton(
                                                                      onPressed:
                                                                          () {
                                                                        Navigator
                                                                            .push(
                                                                          context,
                                                                          MaterialPageRoute(
                                                                              builder: (context) => ShoppingCart(uid: FirebaseAuth.instance.currentUser!.uid)),
                                                                        );
                                                                      },
                                                                      child: Text(
                                                                          'Go to Cart',
                                                                          style:
                                                                              AppTheme.subtitlewhite),
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
                                                    padding:
                                                        const EdgeInsets.all(
                                                            12.0),
                                                    child: Row(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        Text(
                                                          'Adicionar ao carrinho',
                                                          style: TextStyle(
                                                              fontSize: 16),
                                                        ),
                                                        Gap(8),
                                                        Icon(
                                                          Icons.shopping_cart,
                                                          size: 20,
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    primary: AppTheme.vinho,
                                                    onPrimary: Colors.white,
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              16),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            )
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
          ],
        );
      },
    );
  }
}
