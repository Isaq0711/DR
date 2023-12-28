import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dressing_room/utils/colors.dart';
import 'package:dressing_room/resources/firestore_methods.dart';
import 'package:gap/gap.dart';

class FriendsListDialog extends StatelessWidget {
  const FriendsListDialog({Key? key, required this.uid}) : super(key: key);

  final String uid;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: FriendsList(uid: uid),
    );
  }
}

class FriendsList extends StatefulWidget {
  const FriendsList({Key? key, required this.uid}) : super(key: key);

  final String uid;

  @override
  _FriendsListState createState() => _FriendsListState();
}

class _FriendsListState extends State<FriendsList> {
  final TextEditingController searchListController = TextEditingController();
  final TextEditingController listNameController = TextEditingController();
  final TextEditingController listAddUsersController = TextEditingController();
  bool isLoading = false;
  bool isList = true;
  Map<String, bool> expandedItems = {};
  List<String> searchResults = [];
  List<dynamic> listResults = [];
  List<String> userNameResults = [];
  List<String> userPhotoResults = [];
  List<String> userIdResults = [];
  List<String>? uids = [];
  List<String>? usernames = [];
  List<String>? lista = [];
  List<String>? usernamelist = [];
  List<String>? photolist = [];
  List<String>? userphotos = [];
  List<dynamic> listnames = [];
  String selectedUsername = '';

  @override
  void initState() {
    super.initState();

    getData();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void selectedList(String username) {
    setState(() {
      if (selectedUsername == username) {
        selectedUsername = '';
      } else {
        selectedUsername = username;
      }
    });
  }

  void addToList(String username, String userPhoto, String uid) {
    setState(() {
      bool userExists = (usernames?.contains(username) ?? false) ||
          (userphotos?.contains(userPhoto) ?? false);

      if (userExists) {
        usernames?.remove(username);
        userphotos?.remove(userPhoto);
        uids?.remove(uid);
      } else {
        usernames?.add(username);
        userphotos?.add(userPhoto);
        uids?.add(uid);
      }
    });
  }

  getData() async {
    setState(() {
      isLoading = true;
    });

    try {
      var snap = await FirebaseFirestore.instance
          .collection('lists')
          .doc(widget.uid)
          .get();

      if (snap.exists && snap.data() != null) {
        Map<String, dynamic> data = snap.data()!;
        listnames.clear();

        data.keys.forEach((key) {
          listnames.add(key);
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

  Future<List<String>> getUsersFromList(String listName) async {
    setState(() {
      isLoading = true;
    });

    usernamelist = [];
    photolist = [];
    lista = [];
    try {
      var snap = await FirebaseFirestore.instance
          .collection('lists')
          .doc(widget.uid)
          .get();

      if (snap.exists && snap.data() != null) {
        var data = snap.data()!;
        if (data.containsKey(listName)) {
          var lista = List<String>.from(data[listName]['users'] ?? []);

          for (var userId in lista) {
            var userSnap = await FirebaseFirestore.instance
                .collection('users')
                .doc(userId)
                .get();

            if (userSnap.exists && userSnap.data() != null) {
              var userData = userSnap.data()!;
              usernamelist!.add(userData['username']);
              photolist!.add(userData['photoUrl']);
            }
          }
        }
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching users on list: $e');
      setState(() {
        isLoading = false;
      });
    }

    return usernamelist!;
  }

  Future<void> _searchUsers(String searchText) async {
    QuerySnapshot<Map<String, dynamic>> querySnapshot = await FirebaseFirestore
        .instance
        .collection('users')
        .where('username', isGreaterThanOrEqualTo: searchText)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      setState(() {
        searchResults.clear();
        userNameResults.clear();
        userPhotoResults.clear();
        userIdResults.clear();
        for (QueryDocumentSnapshot<Map<String, dynamic>> documentSnapshot
            in querySnapshot.docs) {
          searchResults.add(documentSnapshot.data()['username'] ?? '');
          userNameResults.add(documentSnapshot.data()['username'] ?? '');
          userPhotoResults.add(documentSnapshot.data()['photoUrl'] ?? '');
          userIdResults.add(documentSnapshot.data()['uid'] ?? '');
        }
      });
    } else {
      setState(() {
        searchResults.clear();
        userNameResults.clear();
        userPhotoResults.clear();
        userIdResults.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.8,
      padding: const EdgeInsets.only(top: 5),
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(30),
          bottom: Radius.circular(30),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(children: [
            Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(
                  Icons.arrow_back_rounded,
                  color: AppTheme.nearlyBlack,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 45),
              child: Text("Lista de amigos", style: AppTheme.title),
            ),
            IconButton(
              onPressed: () {
                selectedUsername == ''
                    ? Navigator.pop(context)
                    : Navigator.pop(context, selectedUsername);
              },
              icon: const Icon(
                Icons.check,
                color: AppTheme.nearlyBlack,
              ),
            ),
          ]),
          Gap(12),
          isList
              ? Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
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
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black,
                            ),
                            controller: searchListController,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: 'Search for lists...',
                              hintStyle: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                            onFieldSubmitted: (String searchText) {
                              _searchUsers(searchText);
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: IconButton(
                            onPressed: () {
                              setState(() {
                                searchListController.text = "";
                              });
                            },
                            icon: Icon(
                              Icons.close,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : SizedBox(),
          Gap(8),
          Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                        child: InkWell(
                      onTap: () {
                        setState(() {
                          isList = false;
                          searchListController.text = "";
                        });
                      },
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
                            "New list",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    )),
                    isList
                        ? Gap(0.1)
                        : IconButton(
                            onPressed: () {
                              setState(() {
                                isList = true;
                              });
                            },
                            icon: Icon(
                              Icons.close,
                              color: AppTheme.nearlyBlack,
                            ),
                          ),
                  ])),
          Gap(13),
          isList
              ? Container()
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                        padding: EdgeInsets.symmetric(horizontal: 22),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text("New list name",
                              style: AppTheme.dividerfont),
                        )),
                    Gap(5),
                    Container(
                        width: MediaQuery.of(context).size.width * 0.7,
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          child: TextField(
                            controller: listNameController,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.black,
                            ),
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: 'Write new list name...',
                              hintStyle: TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                            // Adicione aqui a lógica para adicionar o nome da nova lista
                          ),
                        )),
                    Gap(10),
                    Container(
                      width: MediaQuery.of(context).size.width * 0.7,
                      padding: EdgeInsets.symmetric(horizontal: 8),
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
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.black,
                              ),
                              controller: listAddUsersController,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: 'Search users...',
                                hintStyle: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                              onFieldSubmitted: (String searchText) {
                                _searchUsers(searchText);
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: IconButton(
                              onPressed: () {
                                setState(() {
                                  listAddUsersController.text = "";
                                });
                              },
                              icon: Icon(
                                Icons.close,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.35,
                      child: Container(
                        child: listAddUsersController.text == ""
                            ? Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 16),
                                child: Container(
                                  child: ListView.builder(
                                    itemCount: usernames?.length,
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                      return ListTile(
                                          leading: CircleAvatar(
                                            backgroundImage: NetworkImage(
                                                userphotos![index]),
                                            radius: 16,
                                          ),
                                          title: Text(
                                            usernames![index],
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.black,
                                            ),
                                          ),
                                          trailing: Icon(
                                              Icons.check_box_outlined,
                                              color: AppTheme.nearlyBlack),
                                          onTap: () {
                                            addToList(
                                                usernames![index],
                                                userphotos![index],
                                                uids![index]);
                                          });
                                    },
                                  ),
                                ),
                              )
                            : Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 16),
                                child: Container(
                                  child: ListView.builder(
                                    itemCount: userNameResults.length,
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                      final bool isAdded = usernames?.contains(
                                              userNameResults[index]) ??
                                          false;

                                      return ListTile(
                                          leading: CircleAvatar(
                                            backgroundImage: NetworkImage(
                                                userPhotoResults[index]),
                                            radius: 16,
                                          ),
                                          title: Text(
                                            userNameResults[index],
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.black,
                                            ),
                                          ),
                                          trailing: isAdded
                                              ? Icon(Icons.check_box_outlined,
                                                  color: AppTheme.nearlyBlack)
                                              : Icon(
                                                  Icons.check_box_outline_blank,
                                                  color: AppTheme.nearlyBlack),
                                          onTap: () {
                                            addToList(
                                                userNameResults[index],
                                                userPhotoResults[index],
                                                userIdResults[index]);
                                          });
                                    },
                                  ),
                                ),
                              ),
                      ),
                    ),
                    Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: Center(
                            child: ElevatedButton(
                          onPressed: () {
                            FireStoreMethods().uploadList(
                                widget.uid, listNameController.text, uids);
                            setState(() {
                              isList = true;
                            });
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(1.0),
                            child: Text(
                              'Create List',
                              style: TextStyle(fontSize: 14),
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            primary: AppTheme.vinho,
                            onPrimary: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        )))
                  ],
                ),
          Gap(12),
          Expanded(
            child: Container(
                child: isList
                    ? Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Container(
                          child: ListView.builder(
                            itemCount: listnames.length,
                            itemBuilder: (BuildContext context, int index) {
                              final bool isAdded =
                                  selectedUsername == listnames[index];

                              return Column(
                                children: [
                                  ListTile(
                                    leading: isAdded
                                        ? Icon(Icons.check_box_outlined,
                                            color: AppTheme.nearlyBlack)
                                        : Icon(Icons.check_box_outline_blank,
                                            color: AppTheme.nearlyBlack),
                                    title: Text(
                                      listnames[index],
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.black,
                                      ),
                                    ),
                                    trailing: IconButton(
                                      onPressed: () {
                                        setState(() {
                                          selectedUsername = listnames[index];
                                          getUsersFromList(listnames[index]);

                                          if (expandedItems
                                              .containsKey(listnames[index])) {
                                            expandedItems
                                                .remove(listnames[index]);
                                          } else {
                                            expandedItems.clear();
                                            expandedItems[listnames[index]] =
                                                true;
                                          }
                                        });
                                      },
                                      icon: Icon(Icons.add,
                                          color: AppTheme.nearlyBlack),
                                    ),
                                    onTap: () {
                                      setState(() {
                                        selectedUsername = listnames[index];
                                        getUsersFromList(listnames[index]);
                                        expandedItems.clear();
                                      });
                                    },
                                  ),
                                  if (expandedItems
                                          .containsKey(listnames[index]) &&
                                      expandedItems[listnames[index]] == true)
                                    SizedBox(
                                      child: ListView.builder(
                                        itemCount: usernamelist!.length,
                                        shrinkWrap: true,
                                        itemBuilder:
                                            (BuildContext context, int index1) {
                                          return Column(
                                            children: [
                                              ListTile(
                                                leading: CircleAvatar(
                                                  backgroundImage: NetworkImage(
                                                      photolist![index1]),
                                                  radius: 16,
                                                ),
                                                title: Text(
                                                  usernamelist![index1],
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    color: Colors.black,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          );
                                        },
                                      ),
                                    ),
                                ],
                              );
                            },
                          ),
                        ),
                      )
                    : null),
          ),
        ],
      ),
    );
  }
}

class Lista {
  final String uid;
  final String listname;
  final List<String>? users;
  final DateTime dateAdded;

  const Lista({
    required this.uid,
    required this.listname,
    required this.users,
    required this.dateAdded,
  });

  factory Lista.fromSnap(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map<String, dynamic>;

    return Lista(
      uid: snapshot["uid"] ?? '',
      dateAdded: snapshot["dateAdded"] != null
          ? (snapshot["dateAdded"] as Timestamp).toDate()
          : DateTime.now(),
      listname: snapshot["listname"] ?? '',
      users: List<String>.from(snapshot["users"] ?? []),
    );
  }

  Map<String, dynamic> toJson() => {
        "uid": uid,
        "listname": listname,
        "dateAdded": dateAdded,
        "users": users
      };
}
