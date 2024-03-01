import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:dressing_room/utils/colors.dart';
import 'package:gap/gap.dart';
import 'package:dressing_room/screens/seepost.dart';
import 'package:dressing_room/resources/firestore_methods.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class ShoppingCart extends StatefulWidget {
  final String uid;

  const ShoppingCart({Key? key, required this.uid}) : super(key: key);

  @override
  _ShoppingCartState createState() => _ShoppingCartState();
}

class _ShoppingCartState extends State<ShoppingCart> {
  List<bool> picked = [false, false, false, false, false, false, false];

  bool isLoading = false;
  List<dynamic> itens = [];
  num totalAmount = 0;

  @override
  void initState() {
    super.initState();
    getData();
  }

  pickToggle(int index) {
    setState(() {
      picked[index] = !picked[index];
      getTotalAmount();
    });
  }

  getTotalAmount() {
    num count = 0; // Alteração para declarar 'count' como 'num'
    for (int i = 0; i < itens.length; i++) {
      if (picked[i]) {
        count += (itens[i]['price'] * itens[i]['qntspedidos']);
      }
    }
    setState(() {
      totalAmount = count;
    });
  }

  void incrementCount(int index) {
    setState(() {
      itens[index]['qntspedidos']++;
      getTotalAmount();
    });
  }

  void decrementCount(int index) {
    setState(() {
      if (itens[index]['qntspedidos'] == 1) {
        showDeleteItemDialog(context, index); // Pass the 'index' parameter
      } else if (itens[index]['qntspedidos'] > 1) {
        itens[index]['qntspedidos']--;
        getTotalAmount();
      }
    });
  }

  void showDeleteItemDialog(BuildContext context, int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppTheme.nearlyWhite,
          title: Align(
            alignment: Alignment.center,
            child: Text(
              'Do you want to delete this item?',
              style: AppTheme.subheadline,
            ),
          ),
          content: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ElevatedButton(
                child: Text(
                  'No',
                  style: TextStyle(
                    fontFamily: 'Quicksand',
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(primary: AppTheme.vinho),
                onPressed: () {
                  // Perform action for Camera option
                  Navigator.pop(context);
                },
              ),
              Gap(10.w),
              ElevatedButton(
                child: Text(
                  'Yes',
                  style: TextStyle(
                    fontFamily: 'Quicksand',
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(primary: AppTheme.vinho),
                onPressed: () async {
                  await FireStoreMethods()
                      .removeFromCart(widget.uid, itens[index]['productId']);

                  getData();

                  // Close the dialog
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  getData() async {
    setState(() {
      isLoading = true;
    });

    try {
      var snap = await FirebaseFirestore.instance
          .collection('cart')
          .doc(widget.uid)
          .get();

      if (snap.exists && snap.data() != null) {
        Map<String, dynamic> data = snap.data()!;

        itens.clear();

        data.entries.forEach((entry) {
          var itemData = entry.value;
          itemData['postId'] = entry.key; // Adiciona o campo 'postId'
          itens.add(itemData);
        });
      }
    } catch (e) {
      // Tratar exceções, se necessário
      print('Error fetching data: $e');
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const Center(
            child: CircularProgressIndicator(),
          )
        : Scaffold(
            appBar: AppBar(
              automaticallyImplyLeading: false,
              backgroundColor: Colors.transparent,
              leading: IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: Icon(
                  Icons.arrow_back_ios,
                  color: AppTheme.nearlyBlack,
                ),
              ),
              title: Text('Shopping Cart',
                  style: AppTheme.barapp.copyWith(
                    shadows: [
                      Shadow(
                        blurRadius: 2.0,
                        color: Colors.black,
                      ),
                    ],
                  )),
              centerTitle: true,
              bottom: PreferredSize(
                preferredSize: Size.fromHeight(50.0),
                child: Container(
                  width: double.infinity,
                  color: Colors.transparent,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      Text('Total: \$' + totalAmount.toString(),
                          style: AppTheme.subtitle),
                      Gap(8.w),
                      Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            primary: AppTheme.vinho, // background
                            onPrimary: const Color.fromARGB(
                                255, 255, 226, 226), // foreground
                          ),
                          child: Text('Pay Now'),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
            body: SingleChildScrollView(
              child: Column(
                children: [
                  ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: itens.length,
                    itemBuilder: (context, index) {
                      return Slidable(
                        key: ValueKey(index),
                        endActionPane: ActionPane(
                          motion: const ScrollMotion(),
                          children: [
                            SlidableAction(
                              onPressed: doNothing,
                              backgroundColor: Colors.grey,
                              foregroundColor: Colors.white,
                              icon: Icons.share,
                              label: 'Share',
                            ),
                            SlidableAction(
                              onPressed: doNothing,
                              backgroundColor: AppTheme.vinho,
                              foregroundColor: Colors.white,
                              icon: Icons.shopping_bag,
                              label: 'Basket',
                            ),
                          ],
                        ),
                        child: itemCard(
                          itens[index]['description'],
                          itens[index]['variationdescription'],
                          itens[index]['price'].toString(),
                          itens[index]['size'],
                          itens[index]['photoUrl'],
                          true,
                          index,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          );
  }

  Widget itemCard(String itemName, String color, String price, String size,
      String imgPath, bool available, int i) {
    return InkWell(
      onTap: () {
        if (available) {
          pickToggle(i);
        }
      },
      child: Padding(
        padding: EdgeInsets.all(6.h),
        child: Material(
          borderRadius: BorderRadius.circular(10.0),
          elevation: 3.0,
          child: Container(
            width: 350.w,
            height: 169.h,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                GestureDetector(
                  child: Container(
                    width: 130.w,
                    height: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      image: DecorationImage(
                        image: NetworkImage(imgPath),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            SeePost(postId: itens[i]['postId']),
                      ),
                    );
                  },
                ),
                Gap(10.w),
                Expanded(
                    child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      itemName,
                      style: AppTheme.subheadline,
                      softWrap: false,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Gap(5.h),
                    Row(
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            GestureDetector(
                              onTap: () {
                                if (available) {
                                  decrementCount(i);
                                }
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: AppTheme.vinho,
                                  borderRadius: BorderRadius.circular(15.0),
                                ),
                                child: Icon(
                                  Icons.remove,
                                  color: AppTheme.nearlyWhite,
                                ),
                              ),
                            ),
                            Gap(5.w),
                            available
                                ? Text('${itens[i]['qntspedidos']}',
                                    style: AppTheme.title)
                                : Container(),
                            Gap(5.w),
                            GestureDetector(
                              onTap: () {
                                if (available) {
                                  incrementCount(i);
                                }
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: AppTheme.vinho,
                                  borderRadius: BorderRadius.circular(15.0),
                                ),
                                child: Icon(
                                  Icons.add,
                                  color: AppTheme.nearlyWhite,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Gap(5.h),
                    available
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                'Variation: $color',
                                style: TextStyle(
                                  fontFamily: 'Quicksand',
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14.sp,
                                  color: Colors.grey,
                                ),
                              ),
                              Gap(5.h),
                              Text(
                                'Size: $size',
                                style: TextStyle(
                                  fontFamily: 'Quicksand',
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14.sp,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          )
                        : OutlinedButton(
                            onPressed: () {},
                            style: OutlinedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                              side: BorderSide(color: AppTheme.vinho),
                            ),
                            child: Text(
                              'Find Similar',
                              style: TextStyle(
                                fontFamily: 'Quicksand',
                                fontWeight: FontWeight.bold,
                                fontSize: 12.sp,
                                color: AppTheme.vinho,
                              ),
                            ),
                          ),
                    Gap(5.h),
                    available
                        ? Text(
                            '\$${itens[i]['price'].toString()}',
                            style: TextStyle(
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.bold,
                              fontSize: 20.h,
                              color: AppTheme.vinho,
                            ),
                          )
                        : Container(),
                  ],
                )),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 10.h),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        height: 25.h,
                        width: 25.h,
                        decoration: BoxDecoration(
                          color: available
                              ? Colors.grey.withOpacity(0.4)
                              : Colors.red.withOpacity(0.4),
                          borderRadius: BorderRadius.circular(12.5),
                        ),
                        child: Center(
                          child: available
                              ? Container(
                                  height: 15.h,
                                  width: 15.h,
                                  decoration: BoxDecoration(
                                    color: picked[i]
                                        ? AppTheme.vinho
                                        : Colors.grey.withOpacity(0.4),
                                    borderRadius: BorderRadius.circular(6.0),
                                  ),
                                )
                              : Container(),
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          showDeleteItemDialog(context, i);
                        },
                        icon: Icon(Icons.delete),
                        color: Colors.grey, // Customize the color as needed
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

void doNothing(BuildContext context) {}
