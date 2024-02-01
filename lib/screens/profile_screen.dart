import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:dressing_room/resources/auth_methods.dart';
import 'package:dressing_room/resources/firestore_methods.dart';
import 'package:dressing_room/screens/login_screen.dart';
import 'package:dressing_room/utils/colors.dart';
import 'package:dressing_room/utils/utils.dart';
import 'edit_profile_screen.dart';
import 'seepost.dart';
import 'package:dressing_room/widgets/follow_button.dart';

class ProfileScreen extends StatefulWidget {
  final String uid;

  const ProfileScreen({Key? key, required this.uid}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  var userData = {};
  int postLen = 0;
  int followers = 0;
  int following = 0;
  bool isFollowing = false;
  bool isLoading = false;
  final double drawerWidth = 300.0;
  bool isDrawerOpen = false;
  String selectedOption = "public";
  final AssetImage placeholderImage = AssetImage('assets/NO-CONTENT.png');

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
      var userSnap = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.uid)
          .get();

      var postSnap = await FirebaseFirestore.instance
          .collection('posts')
          .where('uid', isEqualTo: widget.uid)
          .get();

      var votationSnap = await FirebaseFirestore.instance
          .collection('votations')
          .where('uid', isEqualTo: widget.uid)
          .get();

      postLen = postSnap.docs.length + votationSnap.docs.length;
      userData = userSnap.data()!;
      followers = userSnap.data()!['followers'].length;
      following = userSnap.data()!['following'].length;
      isFollowing = userSnap
          .data()!['followers']
          .contains(FirebaseAuth.instance.currentUser!.uid);
      setState(() {});
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

  void openDrawer() {
    setState(() {
      isDrawerOpen = true;
    });
  }

  void closeDrawer() {
    setState(() {
      isDrawerOpen = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const Center(
            child: CircularProgressIndicator(),
          )
        : GestureDetector(
            onTap: closeDrawer,
            child: Stack(
              children: [
                Scaffold(
                  appBar: AppBar(
                    title: const Text(
                      "Profile",
                      style: AppTheme.subheadlinewhite,
                    ),
                    centerTitle: true,
                    backgroundColor: AppTheme.vinho,
                    actions: [
                      if (FirebaseAuth.instance.currentUser!.uid == widget.uid)
                        IconButton(
                          icon: const Icon(
                            CupertinoIcons.list_dash,
                            color: AppTheme.nearlyWhite,
                          ),
                          onPressed: openDrawer,
                        ),
                    ],
                  ),
                  body: ListView(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            CircleAvatar(
                              backgroundColor: Colors.grey,
                              backgroundImage: NetworkImage(
                                userData['photoUrl'],
                              ),
                              radius: 45,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              userData['username'],
                              style: AppTheme.title,
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                buildStatColumn(postLen, "publications"),
                                buildStatColumn(followers, "followers"),
                                buildStatColumn(following, "following"),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                if (FirebaseAuth.instance.currentUser!.uid ==
                                    widget.uid)
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16),
                                    child: Row(
                                      children: [
                                        PopupMenuButton<String>(
                                          icon: Icon(
                                            Icons.list,
                                            size: 46,
                                            color: AppTheme.vinho,
                                          ),
                                          onSelected: (String value) {
                                            setState(() {
                                              selectedOption = value;
                                            });
                                          },
                                          itemBuilder: (BuildContext context) =>
                                              <PopupMenuEntry<String>>[
                                            PopupMenuItem<String>(
                                              value: 'public',
                                              child: Text('public',
                                                  style: AppTheme
                                                      .subheadlinewhite),
                                            ),
                                            PopupMenuItem<String>(
                                              value: 'private',
                                              child: Text('private',
                                                  style: AppTheme
                                                      .subheadlinewhite),
                                            ),
                                          ],
                                          color: AppTheme.vinho,
                                        ),
                                      ],
                                    ),
                                  )
                                else if (isFollowing)
                                  FollowButton(
                                    text: 'Unfollow',
                                    backgroundColor: AppTheme.vinho,
                                    textColor: AppTheme.nearlyWhite,
                                    borderColor: Colors.grey,
                                    function: () async {
                                      await FireStoreMethods().followUser(
                                        FirebaseAuth.instance.currentUser!.uid,
                                        userData['uid'],
                                      );

                                      setState(() {
                                        isFollowing = false;
                                        followers--;
                                      });
                                    },
                                  )
                                else
                                  FollowButton(
                                    text: 'Follow',
                                    backgroundColor: AppTheme.vinho,
                                    textColor: AppTheme.nearlyWhite,
                                    borderColor: Colors.grey,
                                    function: () async {
                                      await FireStoreMethods().followUser(
                                        FirebaseAuth.instance.currentUser!.uid,
                                        userData['uid'],
                                      );

                                      setState(() {
                                        isFollowing = true;
                                        followers++;
                                      });
                                    },
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const Divider(),
                      if (selectedOption == "public")
                        Column(
                          children: [
                            const Divider(),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              child: Row(
                                children: [
                                  Text(
                                    FirebaseAuth.instance.currentUser!.uid ==
                                            widget.uid
                                        ? "My Looks"
                                        : "Looks",
                                    style: AppTheme.subheadline,
                                  ),
                                ],
                              ),
                            ),
                            FutureBuilder(
                              future: FirebaseFirestore.instance
                                  .collection('products')
                                  .where('uid', isEqualTo: widget.uid)
                                  .get(),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const Center(
                                    child: CircularProgressIndicator(),
                                  );
                                }

                                return SizedBox(
                                  height: 150,
                                  child: ListView.builder(
                                    itemCount: (snapshot.data! as QuerySnapshot)
                                        .docs
                                        .length,
                                    scrollDirection: Axis.horizontal,
                                    itemBuilder: (context, index) {
                                      DocumentSnapshot snap =
                                          (snapshot.data! as QuerySnapshot)
                                              .docs[index];

                                      return GestureDetector(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => SeePost(
                                                  postId: snap['postId']),
                                            ),
                                          );
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Container(
                                            width: 150,
                                            decoration: BoxDecoration(
                                              color: Colors.grey,
                                              borderRadius:
                                                  BorderRadius.circular(15),
                                            ),
                                            child: Image(
                                              image: NetworkImage(
                                                  snap['photoUrls'][0]),
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                );
                              },
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              child: Row(
                                children: [
                                  Text(
                                    FirebaseAuth.instance.currentUser!.uid ==
                                            widget.uid
                                        ? "My Votations"
                                        : "Votations",
                                    style: AppTheme.subheadline,
                                  ),
                                ],
                              ),
                            ),
                            FutureBuilder(
                              future: FirebaseFirestore.instance
                                  .collection('votations')
                                  .where('uid', isEqualTo: widget.uid)
                                  .get(),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const Center(
                                    child: CircularProgressIndicator(),
                                  );
                                }

                                return SizedBox(
                                  height: 150,
                                  child: ListView.builder(
                                    itemCount: (snapshot.data! as QuerySnapshot)
                                        .docs
                                        .length,
                                    scrollDirection: Axis.horizontal,
                                    itemBuilder: (context, index) {
                                      DocumentSnapshot snap =
                                          (snapshot.data! as QuerySnapshot)
                                              .docs[index];

                                      return GestureDetector(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => SeePost(
                                                  postId: snap['votationId']),
                                            ),
                                          );
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Container(
                                            width: 150,
                                            decoration: BoxDecoration(
                                              color: Colors.grey,
                                              borderRadius:
                                                  BorderRadius.circular(15),
                                            ),
                                            child: Image(
                                              image: NetworkImage(
                                                  snap['options'][0]
                                                      ['photoUrl']),
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      if (selectedOption == "private") ...[
                        const Divider(),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            children: [
                              Text(
                                "Anonymous Posts",
                                style: AppTheme.subheadline,
                              ),
                            ],
                          ),
                        ),
                        FutureBuilder(
                          future: FirebaseFirestore.instance
                              .collection('anonymous_posts')
                              .where('uid', isEqualTo: widget.uid)
                              .get(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }

                            return SizedBox(
                              height: 150,
                              child: ListView.builder(
                                itemCount: (snapshot.data! as QuerySnapshot)
                                    .docs
                                    .length,
                                scrollDirection: Axis.horizontal,
                                itemBuilder: (context, index) {
                                  DocumentSnapshot snap =
                                      (snapshot.data! as QuerySnapshot)
                                          .docs[index];

                                  return GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              SeePost(postId: snap['postId']),
                                        ),
                                      );
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Container(
                                        width: 150,
                                        decoration: BoxDecoration(
                                          color: Colors.grey,
                                          borderRadius:
                                              BorderRadius.circular(15),
                                        ),
                                        child: Image(
                                          image: NetworkImage(
                                              snap['photoUrls'][0]),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        ),
                        const Divider(),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            children: [
                              Text(
                                "Favorites",
                                style: AppTheme.subheadline,
                              ),
                            ],
                          ),
                        ),
                        FutureBuilder(
                          future: FirebaseFirestore.instance
                              .collection('favorites')
                              .doc(widget
                                  .uid) // Use the user's ID as the document ID
                              .collection('userFavorites')
                              .get(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }

                            List<QueryDocumentSnapshot> favorites =
                                (snapshot.data! as QuerySnapshot).docs;

                            return SizedBox(
                              height: 150,
                              child: ListView.builder(
                                itemCount: favorites.length,
                                scrollDirection: Axis.horizontal,
                                itemBuilder: (context, index) {
                                  dynamic snap = favorites[index];

                                  return GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              SeePost(postId: snap['postId']),
                                        ),
                                      );
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Container(
                                        width: 150,
                                        decoration: BoxDecoration(
                                          color: Colors.grey,
                                          borderRadius:
                                              BorderRadius.circular(15),
                                        ),
                                        child: Image(
                                          image: NetworkImage(
                                              snap['photoUrls'][0]),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        ),
                      ],
                    ],
                  ),
                  backgroundColor: AppTheme.cinza,
                ),
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 300),
                  top: 0,
                  right: isDrawerOpen ? 0 : -drawerWidth,
                  bottom: 0,
                  width: drawerWidth,
                  child: Container(
                    color: const Color.fromARGB(255, 80, 55, 67),
                    child: Column(
                      children: [
                        AppBar(
                          automaticallyImplyLeading: false,
                          backgroundColor: AppTheme.vinho,
                        ),
                        SizedBox(height: 16),
                        CircleAvatar(
                          backgroundColor: Colors.grey,
                          backgroundImage: NetworkImage(
                            userData['photoUrl'],
                          ),
                          radius: 40,
                        ),
                        SizedBox(height: 16),
                        ListTile(
                          leading: const Icon(
                            Icons.edit,
                            color: AppTheme.nearlyWhite,
                          ),
                          title: Text(
                            "Edit Profile",
                            style: AppTheme.subheadlinewhite,
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => EditProfileScreen(
                                      uid: FirebaseAuth
                                          .instance.currentUser!.uid)),
                            );
                            ;
                          },
                        ),
                        Divider(),
                        ListTile(
                          leading: const Icon(
                            Icons.favorite,
                            color: AppTheme.nearlyWhite,
                          ),
                          title: Text(
                            "Favorites",
                            style: AppTheme.subheadlinewhite,
                          ),
                          onTap: () {},
                        ),
                        ListTile(
                          leading: const Icon(
                            Icons.shopping_basket_rounded,
                            color: AppTheme.nearlyWhite,
                          ),
                          title: Text(
                            "Basket",
                            style: AppTheme.subheadlinewhite,
                          ),
                          onTap: () {},
                        ),
                        Divider(),
                        ListTile(
                          leading: const Icon(
                            Icons.logout,
                            color: AppTheme.nearlyWhite,
                          ),
                          title: Text(
                            "Logout",
                            style: AppTheme.subheadlinewhite,
                          ),
                          onTap: () {
                            AuthMethods().signOut().then((value) {
                              Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => LoginScreen()),
                                  (Route<dynamic> route) => false);
                            });
                          },
                        ),
                        Align(
                          child: Text("Version: development"),
                          alignment: Alignment.bottomCenter,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
  }

  Column buildStatColumn(int count, String label) {
    return Column(
      children: [
        Text(
          count.toString(),
          style: AppTheme.title,
        ),
        Text(
          label,
          style: AppTheme.subtitle,
        ),
      ],
    );
  }
}
