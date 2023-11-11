import 'package:flutter/material.dart';
import 'package:dressing_room/utils/colors.dart';
import 'package:gap/gap.dart';

class ShoppingCart extends StatefulWidget {
  @override
  _ShoppingCartState createState() => _ShoppingCartState();
}

class _ShoppingCartState extends State<ShoppingCart> {
  List<bool> picked = [false, false, false, false, false, false, false];
  List<int> itemPrices = [50, 60, 70, 80, 90, 100, 110];
  List<int> itemCounts = [1, 1, 1, 1, 1, 1, 1];

  int totalAmount = 0;

  pickToggle(int index) {
    setState(() {
      picked[index] = !picked[index];
      getTotalAmount();
    });
  }

  getTotalAmount() {
    var count = 0;
    for (int i = 0; i < picked.length; i++) {
      if (picked[i]) {
        count += itemPrices[i] * itemCounts[i];
      }
    }
    setState(() {
      totalAmount = count;
    });
  }

  void incrementCount(int index) {
    setState(() {
      itemCounts[index]++;
      getTotalAmount();
    });
  }

  void decrementCount(int index) {
    setState(() {
      if (itemCounts[index] > 1) {
        itemCounts[index]--;
        getTotalAmount();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: AppTheme.vinho,
        title: const Text(
          'Shopping Cart',
          style: AppTheme.subheadlinewhite,
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(50.0),
          child: Container(
            width: double.infinity,
            color: Colors.white,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                Text('Total: \$' + totalAmount.toString(), style: AppTheme.subtitle),
                SizedBox(width: 10.0),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      primary: AppTheme.vinho, // background
                      onPrimary: const Color.fromARGB(255, 255, 226, 226), // foreground
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
              itemCount: 7,
              itemBuilder: (context, index) {
                return itemCard('Item $index', 'gray', itemPrices[index].toString(), 'L',
                    'https://img.ltwebstatic.com/gspCenter/goodsImage/2022/8/6/2790396538_1018999/D16B882D6326D7F33C6F0E645346262D_thumbnail_720x.webp', true, index);
              },
            ),
          ],
        ),
      ),
    );
  }
Widget itemCard(String itemName, String color, String price, String size, String imgPath, bool available, int i) {
  return InkWell(
    onTap: () {
      if (available) {
        pickToggle(i);
      }
    },
    child: Padding(
      padding: EdgeInsets.all(10.0),
      child: Material(
        borderRadius: BorderRadius.circular(10.0),
        elevation: 3.0,
        child: Container(
          width: MediaQuery.of(context).size.width - 20.0,
          height: 150.0,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                width: 150.0,
                height: 150.0,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  image: DecorationImage(
                    image: NetworkImage(imgPath),
                    fit: BoxFit.cover,     
                  ),
                ),
              ),
              SizedBox(width: 10.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      itemName,
                      style: AppTheme.subheadline,
                    ),
                    SizedBox(height: 10.0),
                    Row(
                      children: <Widget>[
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(6.5),
                            border: Border.all(color: AppTheme.vinho, width: 2.0),
                          ),
                          child: Row(
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
                                    borderRadius: BorderRadius.circular(5.0),
                                  ),
                                  child: Icon(
                                    Icons.remove,
                                    color: AppTheme.nearlyWhite,
                                  ),
                                ),
                              ),
                              SizedBox(width: 10.0),
                              available ? Text('${itemCounts[i]}', style: AppTheme.title) : Container(),
                              SizedBox(width: 10.0),
                              GestureDetector(
                                onTap: () {
                                  if (available) {
                                    incrementCount(i);
                                  }
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: AppTheme.vinho,
                                    borderRadius: BorderRadius.circular(5.0),
                                  ),
                                  child: Icon(
                                    Icons.add,
                                    color: AppTheme.nearlyWhite,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10.0),
                    available
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                'Color: $color',
                                style: TextStyle(
                                  fontFamily: 'Quicksand',
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14.0,
                                  color: Colors.grey,
                                ),
                              ),
                              SizedBox(height: 5.0),
                              Text(
                                'Size: $size',
                                style: TextStyle(
                                  fontFamily: 'Quicksand',
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14.0,
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
                                fontSize: 12.0,
                                color: AppTheme.vinho,
                              ),
                            ),
                          ),
                    SizedBox(height: 10.0),
                    available
                        ? Text(
                            '\$${(itemPrices[i] )}',
                            style: TextStyle(
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.bold,
                              fontSize: 20.0,
                              color: AppTheme.vinho,
                            ),
                          )
                        : Container(),
                  ],
                ),
              ),
         
              Column(
                
                children: [ 
                     SizedBox(height: 10.0),   
                  Container(
                    height: 25.0,
                    width: 25.0,
                    decoration: BoxDecoration(
                      color: available ? Colors.grey.withOpacity(0.4) : Colors.red.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(12.5),
                    ),
                    child: Center(
                      child: available
                          ? Container(
                              height: 12.0,
                              width: 12.0,
                              decoration: BoxDecoration(
                                color: picked[i] ? AppTheme.vinho : Colors.grey.withOpacity(0.4),
                                borderRadius: BorderRadius.circular(6.0),
                              ),
                            )
                          : Container(),
                    ),
                  ),
                   Gap(65.0),   
                  IconButton(
                    onPressed: () {
                      // Implement your delete logic here
                    },
                    icon: Icon(Icons.delete),
                    color: Colors.grey, // Customize the color as needed
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
  );
}}