import 'package:flutter/material.dart';
import 'package:dressing_room/utils/colors.dart';
import 'package:gap/gap.dart';
import 'shopping_cart.dart';

class ProductScreen extends StatefulWidget {
  @override
  _ProductScreenState createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  int selectedSize = 0;
  List<String> sizes = ['PP', 'P', 'M', 'G', 'GG'];
  PageController _pageController = PageController(initialPage: 0);
  List<String> networkImages = [
    'https://img.elo7.com.br/product/main/3C26494/camiseta-lisa-cinza-mescla-masculina-de-algodao-presente-barato.jpg',
    'https://img.elo7.com.br/product/main/3C26465/camiseta-lisa-preta-masculina-de-algodao-para-eles.jpg',
    'https://img.elo7.com.br/product/main/3C2656C/camiseta-lisa-rosa-claro-masculina-de-algodao-gola-redonda.jpg',
    'https://img.elo7.com.br/product/main/3C2647A/camiseta-lisa-branca-masculina-de-algodao-camiseta-de-algodao.jpg',
  ];
  List<String> pieceDescription = ['Cinza', 'Preto', 'Rosa', 'Branco'];

  List<double> prices = [
    100.45,
    90,
    105,
    100,
  ];
  List<List<int>> numberofpieces = [
    [8, 12, 19, 10, 15], //  "Cinza"
    [10, 14, 22, 12, 18], //  "Preto"
    [15, 18, 25, 14, 20], // "Rosa"
    [12, 16, 23, 13, 17], // "Branco"
  ];

  int _currentPageIndex = 0;

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: AppTheme.nearlyBlack,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.favorite_border,
              color: AppTheme.nearlyBlack,
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.shopping_bag_outlined,
              color: AppTheme.nearlyBlack,
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.share_outlined,
              color: AppTheme.nearlyBlack,
            ),
          ),
        ],
        // Adding a Row to hold the avatar and provide space
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: AppTheme.cinza,
              radius: 15,
              backgroundImage: NetworkImage(
                'https://i.pinimg.com/564x/34/c3/57/34c357ee31431b6cd13fe1ebe1d47980.jpg',
              ),
            ),
            SizedBox(width: 10),
            Text(
              'NIKE',
              style: AppTheme.subtitle,
            )
          ],
        ),
      ),
      body: ListView(
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
                  SizedBox(
                    width: size.width,
                    height: size.height * 0.45,
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: Image.network(
                            networkImages[_currentPageIndex],
                            width: size.width,
                            fit: BoxFit.cover,
                          ),
                        )
                      ],
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
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  "Camisa ELO7",
                                  style: AppTheme.subheadline,
                                ),
                              ),
                              Gap(10),
                              Text(
                                '\$${prices[_currentPageIndex]}',
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
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Select Variation",
                                  style: AppTheme.title,
                                ),
                                // Ajuste o tamanho do espaço entre os textos conforme necessário
                                Text(
                                  '${numberofpieces[_currentPageIndex][selectedSize]}' +
                                      " Itens available",
                                  style: AppTheme.caption,
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: size.height * 0.1,
                            child: GridView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: networkImages.length,
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
                                    padding: const EdgeInsets.all(8.0),
                                    child: AnimatedContainer(
                                      width: size.width * 0.15,
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: _currentPageIndex == index
                                              ? AppTheme.vinho
                                              : Colors.transparent,
                                          width: 2,
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      duration:
                                          const Duration(milliseconds: 200),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.network(
                                          networkImages[index],
                                          fit: BoxFit.cover,
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
                          Text(
                              "Variation selected: " +
                                  '${pieceDescription[_currentPageIndex]}',
                              style: AppTheme.caption),
                          Gap(
                            size.height * 0.006,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                                left: 10.0, top: 10.0, bottom: 9.0),
                            child: Text(
                              "Select Size",
                              style: AppTheme.title,
                            ),
                          ),
                          SizedBox(
                            width: size.width * 0.9,
                            height: size.height * 0.08,
                            child: ListView.builder(
                              physics: const NeverScrollableScrollPhysics(),
                              scrollDirection: Axis.horizontal,
                              itemCount: sizes.length,
                              itemBuilder: (ctx, index) {
                                var current = sizes[index];
                                return GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        selectedSize = index;
                                      });
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.all(10.0),
                                      child: AnimatedContainer(
                                        width: size.width * 0.12,
                                        decoration: BoxDecoration(
                                          color: selectedSize == index
                                              ? AppTheme.vinho
                                              : Colors.transparent,
                                          border: Border.all(
                                              color: AppTheme.vinho, width: 2),
                                          borderRadius:
                                              BorderRadius.circular(15),
                                        ),
                                        duration:
                                            const Duration(milliseconds: 200),
                                        child: Center(
                                          child: Text(
                                            current,
                                            style: TextStyle(
                                              fontSize: 17,
                                              fontWeight: FontWeight.w500,
                                              color: selectedSize == index
                                                  ? Colors.white
                                                  : Colors.black,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ));
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Center(
                              child: ElevatedButton(
                                onPressed: () {
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
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Container(
                                                  width: size.width * 0.45,
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                    color: AppTheme.vinho,
                                                  ),
                                                  child: TextButton(
                                                    onPressed: () {
                                                      Navigator.pop(context);
                                                    },
                                                    child: Text(
                                                        'Continuar Comprando',
                                                        style: AppTheme
                                                            .subtitlewhite),
                                                  ),
                                                ),
                                                Container(
                                                  width: size.width * 0.45,
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                    color: AppTheme.vinho,
                                                  ),
                                                  child: TextButton(
                                                    onPressed: () {
                                                      Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                            builder: (context) =>
                                                                ShoppingCart()),
                                                      );
                                                    },
                                                    child: Text(
                                                        'Ir para Carrinho',
                                                        style: AppTheme
                                                            .subtitlewhite),
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
                                        'Adicionar ao Carrinho',
                                        style: TextStyle(fontSize: 16),
                                      ),
                                      SizedBox(width: 8),
                                      Icon(
                                        Icons.shopping_cart,
                                        size: 20,
                                      ),
                                    ],
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  primary: AppTheme.vinho, // Background color
                                  onPrimary: Colors.white, // Text color
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                        16), // Circular border
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
            ),
          ),
        ],
      ),
    );
  }
}
