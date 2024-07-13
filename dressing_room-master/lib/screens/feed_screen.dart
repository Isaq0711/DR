import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math' as math;
import 'package:dressing_room/providers/bottton_nav_controller.dart';
import 'package:dressing_room/providers/isshop_provider.dart';
import 'package:dressing_room/responsive/mobile_screen_layout.dart';
import 'package:dressing_room/responsive/responsive_layout.dart';
import 'package:dressing_room/screens/shopping_cart.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:dressing_room/screens/chat_page[1].dart';
import 'package:dressing_room/screens/2_store_screen.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/rendering.dart';
import 'package:dressing_room/models/post.dart';

import 'package:dressing_room/models/votations.dart';

import 'package:flutter/foundation.dart';

import 'package:dressing_room/resources/comn[1].dart';
import 'package:dressing_room/utils/colors.dart';

import 'dart:convert';

import 'package:dressing_room/2d_cards/new_votation_card.dart';

import 'package:dressing_room/2d_cards/new_post_card.dart';
import 'package:dressing_room/2d_cards/new_product_card.dart';

double altura = 600.h;
double largura = (altura * 9) / 16;
late bool first;

double previousHorizontalPixels = largura / 2;
double previousVerticalPixels = 0.0;
bool parou = false;
late int totaldocumentos;
bool cima = false;
bool paradoverticalmente = true;
late bool direita;

class FeedScreen extends StatefulWidget {
  const FeedScreen({Key? key}) : super(key: key);

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  List<DocumentSnapshot<Map<String, dynamic>>>? _anonymousPosts;
  List<DocumentSnapshot<Map<String, dynamic>>>? _posts;
  List<DocumentSnapshot<Map<String, dynamic>>>? _products;
  List<DocumentSnapshot<Map<String, dynamic>>>? _votations;

  bool isLoading = false;

  late ScrollController scrollController;

  void _fetchAllDocuments() async {
    final anonymousPostsQuery =
        FirebaseFirestore.instance.collection('anonymous_posts').get();
    final postsQuery = FirebaseFirestore.instance.collection('posts').get();
    final votationsQuery =
        FirebaseFirestore.instance.collection('votations').get();
    final productsQuery =
        FirebaseFirestore.instance.collection('products').get();

    // Await all queries in parallel
    final results = await Future.wait(
        [anonymousPostsQuery, postsQuery, votationsQuery, productsQuery]);

    setState(() {
      _anonymousPosts = results[0].docs;
      _posts = results[1].docs;
      _votations = results[2].docs;
      _products = results[3].docs;
      totaldocumentos = Provider.of<ShopProvider>(context, listen: false).isShop
          ? _products!.length
          : _anonymousPosts!.length + _posts!.length + _votations!.length;
    });
  }

  Future<void> enviarTexto() async {
    String statusSever = 'Server online';

    if (statusSever == 'Server online') {
      try {
        // Objeto JSON que vai conter as informações de posts, posts anônimos e votações
        Map<String, dynamic> model = {
          'posts': [],
          'anonymousPosts': [],
          'votations': [],
        };

        // Obtendo dados de anonymous_posts
        var anonymousPostsSnap = await FirebaseFirestore.instance
            .collection('anonymous_posts')
            .get();
        List<Postpramandar> anonymousPosts = [];
        anonymousPostsSnap.docs.forEach((doc) {
          anonymousPosts.add(Postpramandar.fromSnap(doc));
        });
        model['anonymousPosts'] =
            anonymousPosts.map((post) => post.toJson()).toList();

        // Obtendo dados de posts
        var postsSnap =
            await FirebaseFirestore.instance.collection('posts').get();
        List<Postpramandar> posts = [];
        postsSnap.docs.forEach((doc) {
          posts.add(Postpramandar.fromSnap(doc));
        });
        model['posts'] = posts.map((post) => post.toJson()).toList();

        // Obtendo dados de votations
        var votationsSnap =
            await FirebaseFirestore.instance.collection('votations').get();
        List<Votationpramadar> votations = [];
        votationsSnap.docs.forEach((doc) {
          votations.add(Votationpramadar.fromSnap(doc));
        });
        model['votations'] =
            votations.map((votation) => votation.toJson()).toList();

        // Convertendo o objeto JSON para uma string JSON
        String jsonModel = jsonEncode(model);

        // Enviando para o servidor
        String response = await sendText(
            'Feed', jsonModel, FirebaseAuth.instance.currentUser!.uid);

        // Processando a resposta, se necessário
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

  @override
  void initState() {
    super.initState();

    scrollController = ScrollController();

    scrollController.addListener(() {
      final bool isScrollingUp =
          scrollController.position.userScrollDirection ==
              ScrollDirection.reverse;
      final bool isScrollingDown =
          scrollController.position.userScrollDirection ==
              ScrollDirection.forward;

      if (isScrollingUp) {
        //     context.read<BottonNavController>().setBottomVisible(false);
        cima = false;
        paradoverticalmente = false;
      } else if (isScrollingDown) {
        //   context.read<BottonNavController>().setBottomVisible(true);
        cima = true;
        paradoverticalmente = false;
      }
    });

    first = true;
    _fetchAllDocuments();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //  bool isBottomVisible = context.watch<BottonNavController>().isBottonVisible;
    bool isBottomVisible = true;
    final shopProvider = Provider.of<ShopProvider>(context, listen: false);
    final cartQuantityy = Provider.of<CartCounterProvider>(context)
        .cartQuantity; //está na página do isBottonVisible
    return PrimaryScrollController(
        controller: scrollController,
        child: Scaffold(
            backgroundColor: AppTheme.cinza,
            appBar: AppBar(
              toolbarHeight: 60.h,
              elevation: 0.0,
              centerTitle: false,
              backgroundColor: Colors.transparent,
              title: Padding(
                padding: EdgeInsets.only(left: 16.w),
                child: InkWell(
                  child: Image.asset(
                    'assets/LOGO-ICON.png',
                    color: AppTheme.vinho,
                    width: 55,
                    height: 55,
                  ),
                  onTap: () {
                    enviarTexto();
                  },
                ),
              ),
              actions: [
                Padding(
                    padding: EdgeInsets.symmetric(horizontal: 26.w),
                    child: Row(
                      children: [
                        IconButton(
                          icon: Icon(
                            shadows: <Shadow>[
                              Shadow(color: AppTheme.vinho, blurRadius: 2.0)
                            ],
                            CupertinoIcons.search,
                            color: AppTheme.vinho,
                          ),
                          onPressed: () {},
                        ),
                        IconButton(
                          icon: Icon(
                            shadows: <Shadow>[
                              Shadow(color: AppTheme.vinho, blurRadius: 3.0)
                            ],
                            CupertinoIcons.info_circle,
                            color: AppTheme.vinho,
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ChatPage()),
                            );
                          },
                        ),
                        shopProvider.isShop
                            ? Stack(
                                children: [
                                  if (cartQuantityy > 0)
                                    Positioned(
                                      right: 0,
                                      top: 0,
                                      child: Container(
                                        padding: EdgeInsets.all(2),
                                        decoration: BoxDecoration(
                                          color: AppTheme.vinho,
                                          borderRadius:
                                              BorderRadius.circular(7),
                                        ),
                                        constraints: BoxConstraints(
                                          minWidth: 20,
                                          minHeight: 20,
                                        ),
                                        child: Text(
                                          '$cartQuantityy',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ),
                                  IconButton(
                                    icon: Icon(
                                      shadows: <Shadow>[
                                        Shadow(
                                          color: AppTheme.vinho,
                                          blurRadius: 3.0,
                                        ),
                                      ],
                                      CupertinoIcons.shopping_cart,
                                      color: AppTheme.vinho,
                                    ),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => ShoppingCart(
                                            uid: FirebaseAuth
                                                .instance.currentUser!.uid,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              )
                            : Container()
                      ],
                    ))
              ],
            ),
            floatingActionButton: Visibility(
                visible: isBottomVisible,
                child: Container(
                  margin: EdgeInsets.only(
                    bottom: 3.h,
                  ),
                  child: FloatingActionButton(
                    onPressed: () {
                      setState(() {
                        shopProvider.isShop = !shopProvider.isShop;
                      });
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                          builder: (context) => const ResponsiveLayout(
                            mobileScreenLayout: MobileScreenLayout(),
                          ),
                        ),
                        (route) => false,
                      );
                    },
                    backgroundColor: AppTheme.vinho,
                    elevation: 2.0,
                    child: shopProvider.isShop
                        ? Icon(
                            CupertinoIcons.person_3_fill,
                            color: AppTheme.cinza,
                          )
                        : Icon(
                            CupertinoIcons.bag_fill,
                            color: AppTheme.cinza,
                          ),
                  ),
                )),
            body: _anonymousPosts == null ||
                    _posts == null ||
                    _votations == null ||
                    _products == null
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : NotificationListener<ScrollNotification>(
                    onNotification: (scrollNotification) {
                    if (scrollNotification is ScrollStartNotification) {
                      //   print("========>>> START " +
                      //       scrollNotification.metrics.toString());
                    } else if (scrollNotification is ScrollUpdateNotification) {
                      // print("========>>> UPDATE " +
                      //     scrollNotification.metrics.toString());
                      parou = false;
                    } else if (scrollNotification is ScrollEndNotification) {
                      // print("========>>> END " +
                      // scrollNotification.metrics.toString());
                      //parou = true;
                    } else if (scrollNotification is UserScrollNotification) {
                      // print("========>>> USER " +
                      // scrollNotification.metrics.toString());
                      parou = true;
                      first = false;
                    }

                    return false;
                  }, child: Builder(
                    builder: (context) {
                      List<DocumentSnapshot<Map<String, dynamic>>> allDocuments;

                      final shopProvider = context.watch<ShopProvider>();

                      if (shopProvider.isShop) {
                        allDocuments = _products!;
                      } else {
                        allDocuments = [
                          ..._anonymousPosts!,
                          ..._posts!,
                          ..._votations!,
                        ];
                      }

                      allDocuments.sort((a, b) => (b.data()!['datePublished']
                              as Timestamp)
                          .compareTo(a.data()!['datePublished'] as Timestamp));

                      return TwoDimensionalGridView(
                        diagonalDragBehavior: DiagonalDragBehavior.none,
                        delegate: TwoDimensionalChildBuilderDelegate(
                          maxXIndex: math.sqrt(allDocuments.length).ceil() - 1,
                          maxYIndex: (allDocuments.length /
                                      math.sqrt(allDocuments.length).ceil())
                                  .ceil() -
                              1,
                          builder:
                              (BuildContext context, ChildVicinity vicinity) {
                            final int index =
                                vicinity.yIndex * 5 + vicinity.xIndex;
                            if (index < allDocuments.length) {
                              final documentData = allDocuments[index].data();

                              if (documentData!.containsKey('options')) {
                                return Container(
                                  height: altura,
                                  width: largura,
                                  child: NewVotationCard(
                                    snap: documentData,
                                  ),
                                );
                              } else if (documentData.containsKey('category')) {
                                return Container(
                                  height: altura,
                                  width: largura,
                                  child: NewProductCard(
                                    snap: documentData,
                                  ),
                                );
                              } else {
                                return Container(
                                  height: altura,
                                  width: largura,
                                  child: NewPostCard(
                                    snap: documentData,
                                  ),
                                );
                              }
                            } else {
                              return Container();
                            }
                          },
                        ),
                      );
                    },
                  ))));
  }
}

class TwoDimensionalGridView extends TwoDimensionalScrollView {
  const TwoDimensionalGridView({
    Key? key,
    super.primary,
    super.mainAxis = Axis.vertical,
    super.verticalDetails = const ScrollableDetails.vertical(),
    super.horizontalDetails = const ScrollableDetails.horizontal(),
    required TwoDimensionalChildBuilderDelegate delegate,
    super.cacheExtent,
    super.diagonalDragBehavior = DiagonalDragBehavior.none,
    super.keyboardDismissBehavior = ScrollViewKeyboardDismissBehavior.manual,
    super.clipBehavior = Clip.hardEdge,
  }) : super(key: key, delegate: delegate);

  @override
  Widget buildViewport(
    BuildContext context,
    ViewportOffset verticalOffset,
    ViewportOffset horizontalOffset,
  ) {
    return TwoDimensionalGridViewport(
      key: key,
      verticalOffset: verticalOffset,
      verticalAxisDirection: verticalDetails.direction,
      horizontalOffset: horizontalOffset,
      horizontalAxisDirection: horizontalDetails.direction,
      mainAxis: mainAxis,
      delegate: delegate as TwoDimensionalChildBuilderDelegate,
      cacheExtent: cacheExtent,
      clipBehavior: clipBehavior,
    );
  }
}

class TwoDimensionalGridViewport extends TwoDimensionalViewport {
  const TwoDimensionalGridViewport({
    Key? key,
    required ViewportOffset verticalOffset,
    required AxisDirection verticalAxisDirection,
    required ViewportOffset horizontalOffset,
    required AxisDirection horizontalAxisDirection,
    required TwoDimensionalChildBuilderDelegate delegate,
    required Axis mainAxis,
    double? cacheExtent,
    Clip clipBehavior = Clip.hardEdge,
  }) : super(
          key: key,
          verticalOffset: verticalOffset,
          verticalAxisDirection: verticalAxisDirection,
          horizontalOffset: horizontalOffset,
          horizontalAxisDirection: horizontalAxisDirection,
          delegate: delegate,
          mainAxis: mainAxis,
          cacheExtent: cacheExtent,
          clipBehavior: clipBehavior,
        );

  @override
  RenderTwoDimensionalGridViewport createRenderObject(BuildContext context) {
    return RenderTwoDimensionalGridViewport(
      horizontalOffset: horizontalOffset,
      horizontalAxisDirection: horizontalAxisDirection,
      verticalOffset: verticalOffset,
      verticalAxisDirection: verticalAxisDirection,
      mainAxis: mainAxis,
      delegate: delegate as TwoDimensionalChildBuilderDelegate,
      childManager: context as TwoDimensionalChildManager,
      cacheExtent: cacheExtent,
      clipBehavior: clipBehavior,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderTwoDimensionalGridViewport renderObject,
  ) {
    renderObject
      ..horizontalOffset = horizontalOffset
      ..horizontalAxisDirection = horizontalAxisDirection
      ..verticalOffset = verticalOffset
      ..verticalAxisDirection = verticalAxisDirection
      ..mainAxis = mainAxis
      ..delegate = delegate
      ..cacheExtent = cacheExtent
      ..clipBehavior = clipBehavior;
  }
}

class RenderTwoDimensionalGridViewport extends RenderTwoDimensionalViewport {
  RenderTwoDimensionalGridViewport({
    required super.horizontalOffset,
    required super.horizontalAxisDirection,
    required super.verticalOffset,
    required super.verticalAxisDirection,
    required TwoDimensionalChildBuilderDelegate delegate,
    required super.mainAxis,
    required super.childManager,
    super.cacheExtent,
    super.clipBehavior = Clip.hardEdge,
  }) : super(delegate: delegate);

  @override
  void layoutChildSequence() {
    final double horizontalPixels = horizontalOffset.pixels;
    final double verticalPixels = verticalOffset.pixels;
    final double viewportWidth = viewportDimension.width + cacheExtent;
    final double viewportHeight = viewportDimension.height + cacheExtent;
    final TwoDimensionalChildBuilderDelegate builderDelegate =
        delegate as TwoDimensionalChildBuilderDelegate;

    final int maxRowIndex = builderDelegate.maxYIndex!;
    final int maxColumnIndex = builderDelegate.maxXIndex!;

    final int leadingColumn = math.max((horizontalPixels / largura).floor(), 0);
    final int leadingRow = math.max((verticalPixels / altura).floor(), 0);
    final int trailingColumn = math.min(
      ((horizontalPixels + viewportWidth) / largura).ceil(),
      maxColumnIndex,
    );
    final int trailingRow = math.min(
      ((verticalPixels + viewportHeight) / altura).ceil(),
      maxRowIndex,
    );

    double xLayoutOffset =
        (leadingColumn * largura) - (horizontalOffset.pixels);
    for (int column = leadingColumn; column <= trailingColumn; column++) {
      double yLayoutOffset = (leadingRow * altura) - verticalOffset.pixels;
      for (int row = leadingRow; row <= trailingRow; row++) {
        final ChildVicinity vicinity =
            ChildVicinity(xIndex: column, yIndex: row);
        final RenderBox child = buildOrObtainChildFor(vicinity)!;
        child.layout(constraints.loosen());

        parentDataOf(child).layoutOffset = Offset(xLayoutOffset, yLayoutOffset);
        yLayoutOffset += altura;
      }
      xLayoutOffset += largura;
    }

    final double verticalExtent = altura * (maxRowIndex + 1);
    verticalOffset.applyContentDimensions(
      0.0,
      clampDouble(
          verticalExtent - viewportDimension.height, 0.0, double.infinity),
    );
    final double horizontalExtent = largura * (maxColumnIndex + 1);
    horizontalOffset.applyContentDimensions(
      0.0,
      clampDouble(
          horizontalExtent - viewportDimension.width, 0.0, double.infinity),
    );
    if (first) {
      final int initialXIndex =
          ((math.sqrt(totaldocumentos).ceil() - 1) / 2).floor();
      final int initialYIndex =
          (((totaldocumentos / math.sqrt(totaldocumentos).ceil()).ceil() - 1) /
                  2)
              .floor();
      final double initialXOffset = initialXIndex * largura - 25.h;
      final double initialYOffset = initialYIndex * altura - 30.h;

      horizontalOffset.animateTo(initialXOffset,
          duration: Duration(milliseconds: 10),
          curve: Curves.fastEaseInToSlowEaseOut);
      verticalOffset.animateTo(initialYOffset,
          duration: Duration(milliseconds: 10),
          curve: Curves.fastEaseInToSlowEaseOut);
      // first = false;
    } else if (parou) {
      bool scrollingRight = horizontalPixels > previousHorizontalPixels;
      if (paradoverticalmente) {
        int stopXIndex = scrollingRight
            ? (horizontalPixels / largura).ceil()
            : (horizontalPixels / largura).floor();
        double stopXOffset = stopXIndex * largura - 25.h;
        horizontalOffset.animateTo(stopXOffset,
            duration: Duration(milliseconds: 1),
            curve: Curves.fastEaseInToSlowEaseOut);
        print(previousHorizontalPixels);
        print(horizontalPixels);
        paradoverticalmente = true;
      } else {
        int stopYIndex = cima
            ? (verticalOffset.pixels / altura).floor()
            : (verticalOffset.pixels / altura).ceil();
        double stopYOffset = stopYIndex * altura - 30.h;
        verticalOffset.animateTo(stopYOffset,
            duration: Duration(milliseconds: 1),
            curve: Curves.fastEaseInToSlowEaseOut);
      }

      parou = false;
      paradoverticalmente = true;
    }
    previousHorizontalPixels = horizontalPixels;
  }
}
