import 'package:flutter/material.dart';
import 'package:dressing_room/utils/colors.dart';

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
                    'https://m.media-amazon.com/images/I/51fjba7LiFL._AC_SX569_.jpg', true, index);
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
            padding: EdgeInsets.only(left: 15.0, right: 10.0),
            width: MediaQuery.of(context).size.width - 20.0,
            height: 150.0,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Row(
              children: <Widget>[
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
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
                  ],
                ),
                SizedBox(width: 10.0),
                Container(
                  height: 150.0,
                  width: 125.0,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(imgPath),
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                SizedBox(width: 4.0),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Text(
                          itemName,
                          style: AppTheme.body1,
                        ),
                        SizedBox(width: 7.0),
                        available ? Text('x${itemCounts[i]}', style: TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.bold, fontSize: 14.0, color: Colors.grey)) : Container(),
                        IconButton(
                          icon: Icon(Icons.add, color: AppTheme.vinho),
                          onPressed: () {
                            if (available) {
                              incrementCount(i);
                            }
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.remove, color: AppTheme.vinho),
                          onPressed: () {
                            if (available) {
                              decrementCount(i);
                            }
                          },
                        ),
                      ],
                    ),
                    SizedBox(height: 7.0),
                    available
                        ? Column(
                            children: <Widget>[
                              Text(
                                'Color: ' + color,
                                style: TextStyle(
                                  fontFamily: 'Quicksand',
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14.0,
                                  color: Colors.grey,
                                ),
                              ),
                              Text(
                                'Size: ' + size,
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
                    SizedBox(height: 7.0),
                    available
                        ? Text(
                            '\$' + (itemPrices[i] * itemCounts[i]).toString(),
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
