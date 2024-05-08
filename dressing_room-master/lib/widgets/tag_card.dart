import 'package:dressing_room/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dressing_room/utils/colors.dart';
import 'package:dressing_room/resources/firestore_methods.dart';
import 'package:gap/gap.dart';

class TagCard extends StatefulWidget {
  const TagCard({Key? key, required this.category}) : super(key: key);

  final String category;

  @override
  _TagCardState createState() => _TagCardState();
}

class _TagCardState extends State<TagCard> {
  final TextEditingController _textEditingController = TextEditingController();
  List<String> searchResults = [];
  List<String> results = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    getData();
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  void addToList(String itemName) {
    setState(() {
      bool userExists = (results.contains(itemName));

      if (userExists) {
        results.remove(itemName);
      } else {
        results.add(itemName);
      }
    });
  }

  getData() async {
    setState(() {
      isLoading = true;
    });

    try {
      var snap = await FirebaseFirestore.instance
          .collection('hashtags')
          .doc(widget.category)
          .get();

      if (snap.exists && snap.data() != null) {
        Map<String, dynamic> data = snap.data()!;
        searchResults.clear();

        data.keys.forEach((key) {
          searchResults.add(key);
        });

        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.only(top: 5),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(30),
                ),
              ),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Container(
                      width: 40,
                      height: 6,
                      margin: const EdgeInsets.only(top: 16, bottom: 4),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(50),
                        color: AppTheme.cinza,
                      ),
                    ),
                    Gap(5),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 40),
                            child: Text(
                              widget.category,
                              style: AppTheme.title,
                            )),
                        IconButton(
                          onPressed: () {
                            results.isEmpty
                                ? Navigator.pop(context)
                                : Navigator.pop(context, {
                                    'results': results,
                                    'category': widget.category
                                  });
                          },
                          icon: Icon(
                            Icons.check,
                            color: AppTheme.nearlyBlack,
                          ),
                        ),
                      ],
                    ),
                    Gap(15),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 26),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Icon(
                                Icons.search,
                                color: Colors.grey,
                              ),
                            ),
                            Expanded(
                              child: TextFormField(
                                style: AppTheme.subtitle,
                                controller: _textEditingController,
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText: 'Search...',
                                  hintStyle: AppTheme.subtitle
                                      .copyWith(color: Colors.grey),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Gap(5),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 26),
                      child: InkWell(
                        child: Container(
                          child: Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Icon(
                                  Icons.add,
                                  color: Colors.black,
                                ),
                              ),
                              Text(
                                "Criar categoria ",
                                style: AppTheme.caption,
                              ),
                            ],
                          ),
                        ),
                        onTap: () async {
                          setState(() {
                            if (_textEditingController.text.isNotEmpty) {
                              FireStoreMethods()
                                  .createHashtag(_textEditingController.text,
                                      widget.category)
                                  .then((result) {
                                if (result == "success") {
                                  getData();
                                } else {
                                  showSnackBar(
                                      context, "Error creating category");
                                }
                              });
                            } else {
                              showSnackBar(context, "No text written");
                            }
                          });
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 26),
                      child: SizedBox(
                        height: MediaQuery.of(context).size.height * 0.25,
                        child: ListView.builder(
                          itemCount: searchResults.length,
                          itemBuilder: (BuildContext context, int index) {
                            final bool isAdded =
                                results.contains(searchResults[index]);
                            return InkWell(
                              onTap: () {
                                addToList(searchResults[index]);
                                print(searchResults);
                              },
                              child: ListTile(
                                leading: isAdded
                                    ? Icon(Icons.check_box_outlined,
                                        color: AppTheme.nearlyBlack)
                                    : Icon(Icons.check_box_outline_blank,
                                        color: AppTheme.nearlyBlack),
                                title: Text(
                                  searchResults[index],
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class Hashtag {
  final String category;
  final String itemname;

  const Hashtag({
    required this.category,
    required this.itemname,
  });

  factory Hashtag.fromSnap(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map<String, dynamic>;

    return Hashtag(
      category: snapshot["category"] ?? '',
      itemname: snapshot["itemname"] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        "category": category,
        "itemname": itemname,
      };
}
