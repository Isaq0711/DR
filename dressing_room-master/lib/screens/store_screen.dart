import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';
import 'package:dressing_room/resources/firestore_methods.dart';
import 'package:dressing_room/utils/colors.dart';
import 'package:dressing_room/utils/utils.dart';
import 'package:gap/gap.dart';
import 'seepost.dart';
import 'package:dressing_room/widgets/follow_button.dart';

class StoreScreen extends StatefulWidget {
  final String uid;

  const StoreScreen({Key? key, required this.uid}) : super(key: key);

  @override
  _StoreScreenState createState() => _StoreScreenState();
}

class _StoreScreenState extends State<StoreScreen>
    with SingleTickerProviderStateMixin {
  var userData = {};
  int postLen = 0;
  int followers = 0;
  int following = 0;
  bool isFollowing = false;
  bool isLoading = false;
  final double drawerWidth = 300.0;
  String fotodecapa =
      "https://i0.wp.com/chronos-stores.com/wp-content/uploads/2021/07/026-white-gold-gucci-patterned-wallpaper.jpg?fit=810%2C1080&ssl=1";
  bool showmore = false;
  String selectedOption = "Destaque";
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
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
          .collection('products')
          .where('uid', isEqualTo: widget.uid)
          .get();

      postLen = postSnap.docs.length;
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

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const Center(
            child: CircularProgressIndicator(),
          )
        : Scaffold(
            body: CustomScrollView(slivers: <Widget>[
            SliverAppBar(
              backgroundColor: AppTheme.cinza,
              expandedHeight: 255.h,
              flexibleSpace: FlexibleSpaceBar(
                background: Padding(
                    padding: const EdgeInsets.only(bottom: 15),
                    child: Stack(
                      children: <Widget>[
                        Container(
                          child: Hero(
                            tag: fotodecapa,
                            child: ClipShadowPath(
                              shadow: Shadow(blurRadius: 30),
                              clipper: CustomOvalClipper(),
                              child: Image(
                                image: NetworkImage(
                                  fotodecapa,
                                ),
                                height: 245.h,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                        Positioned.fill(
                          bottom: 0,
                          child: Align(
                              alignment: AlignmentDirectional.bottomCenter,
                              child: Container(
                                decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                        width: 3, color: AppTheme.cinza),
                                    color: Colors.white,
                                    boxShadow: [
                                      BoxShadow(
                                          color: Colors.black54, blurRadius: 15)
                                    ]),
                                child: CircleAvatar(
                                  backgroundColor: Colors.grey,
                                  backgroundImage: NetworkImage(
                                    userData['photoUrl'],
                                  ),
                                  radius: 45,
                                ),
                              )),
                        ),
                        Positioned(
                          right: 15.w,
                          top: 30.h,
                          child: IconButton(
                            icon: Icon(
                              shadows: <Shadow>[
                                Shadow(
                                    color: AppTheme.nearlyBlack,
                                    blurRadius: 5.0)
                              ],
                              Icons.edit,
                              color: AppTheme.nearlyWhite,
                            ),
                            onPressed: () {},
                          ),
                        )
                      ],
                    )),
              ),
            ),
            SliverFixedExtentList(
                delegate: SliverChildBuilderDelegate(
                  (context, position) {
                    return Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                userData['username'],
                                style: AppTheme.title,
                              ),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  buildStatColumn(postLen, "Products"),
                                  buildStatColumn(followers, "Promototions"),
                                  buildStatColumn(following, "Representantes"),
                                ],
                              ),
                              Gap(12.h),
                              Positioned(
                                child: isFollowing
                                    ? Row(
                                        children: [
                                          FollowButton2(
                                            text: 'Unfollow',
                                            backgroundColor: AppTheme.vinho,
                                            textColor: AppTheme.nearlyWhite,
                                            borderColor: Colors.grey,
                                            function: () async {
                                              await FireStoreMethods()
                                                  .followUser(
                                                FirebaseAuth
                                                    .instance.currentUser!.uid,
                                                userData['uid'],
                                              );

                                              setState(() {
                                                isFollowing = false;
                                                followers--;
                                              });
                                            },
                                          ),
                                          Gap(2.w),
                                          FollowButton2(
                                              backgroundColor: AppTheme.vinho,
                                              borderColor: Colors.grey,
                                              text: "Ativiar sino",
                                              textColor: AppTheme.nearlyWhite)
                                        ],
                                      )
                                    : FollowButton(
                                        text: 'Follow',
                                        backgroundColor: AppTheme.vinho,
                                        textColor: AppTheme.nearlyWhite,
                                        borderColor: Colors.grey,
                                        function: () async {
                                          await FireStoreMethods().followUser(
                                            FirebaseAuth
                                                .instance.currentUser!.uid,
                                            userData['uid'],
                                          );

                                          setState(() {
                                            isFollowing = true;
                                            followers++;
                                          });
                                        },
                                      ),
                              ),
                              Gap(15.h),
                              Positioned(
                                top: 366.h,
                                child: Container(
                                  color: Colors.transparent,
                                  child: TabBar(
                                    isScrollable: true,
                                    dividerColor: AppTheme.nearlyWhite,
                                    indicatorColor: AppTheme.vinho,
                                    labelColor: AppTheme.vinho,
                                    labelStyle: AppTheme.caption.copyWith(
                                      shadows: [
                                        Shadow(
                                          blurRadius: 3.0,
                                          color: Colors.black, // Cor da sombra
                                          // Deslocamento X e Y da sombra
                                        ),
                                      ],
                                    ),
                                    unselectedLabelColor: AppTheme.nearlyWhite,
                                    controller: _tabController,
                                    tabs: [
                                      Tab(text: 'Destaque'),
                                      Tab(text: 'For you'),
                                      showmore
                                          ? Row(
                                              children: [
                                                Tab(text: 'Show less'),
                                                IconButton(
                                                  icon: Icon(
                                                    Icons.remove,
                                                    color: Colors.white,
                                                  ),
                                                  onPressed: () {
                                                    setState(() {
                                                      showmore = !showmore;
                                                    });
                                                  },
                                                ),
                                              ],
                                            )
                                          : Row(
                                              children: [
                                                Tab(text: 'Show more'),
                                                IconButton(
                                                  icon: Icon(
                                                    CupertinoIcons
                                                        .add_circled_solid,
                                                    shadows: <Shadow>[
                                                      Shadow(
                                                          color: AppTheme
                                                              .nearlyBlack,
                                                          blurRadius: 10.0)
                                                    ],
                                                    color: Colors.white,
                                                  ),
                                                  onPressed: () {
                                                    setState(() {
                                                      showmore = !showmore;
                                                    });
                                                  },
                                                ),
                                              ],
                                            )
                                    ],
                                    onTap: (index) {
                                      setState(() {
                                        selectedOption =
                                            index == 0 ? 'Destaque' : 'For you';
                                      });
                                    },
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                        if (selectedOption == "Destaque")
                          (postLen == 0)
                              ? Container(
                                  child: Image.asset(
                                    'assets/NO-CONTENT.png',
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16),
                                      child: Row(
                                        children: [
                                          Text(
                                            "VITRINE",
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

                                        return Container(
                                          height: 160,
                                          child: ListView.builder(
                                            itemCount: (snapshot.data!
                                                    as QuerySnapshot)
                                                .docs
                                                .length,
                                            scrollDirection: Axis.horizontal,
                                            itemBuilder: (context, index) {
                                              DocumentSnapshot snap = (snapshot
                                                      .data! as QuerySnapshot)
                                                  .docs[index];

                                              return GestureDetector(
                                                onTap: () {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          SeePost(
                                                              postId: snap[
                                                                  'productId']),
                                                    ),
                                                  );
                                                },
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                    child: Container(
                                                        width: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width *
                                                            0.4,
                                                        decoration:
                                                            BoxDecoration(
                                                          border: Border.all(
                                                            color: Colors.grey
                                                                .withOpacity(
                                                                    0.5), // Cor da borda sombreada
                                                            width:
                                                                1.0, // Largura da borda
                                                          ),
                                                          color: Colors
                                                              .transparent,
                                                        ),
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Container(
                                                              height: 120,
                                                              decoration:
                                                                  BoxDecoration(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            10),
                                                                image:
                                                                    DecorationImage(
                                                                  image: NetworkImage(
                                                                      snap['variations']
                                                                              [
                                                                              0]
                                                                          [
                                                                          'photoUrls'][0]),
                                                                  fit: BoxFit
                                                                      .cover,
                                                                ),
                                                              ),
                                                            ),
                                                            Padding(
                                                                padding: EdgeInsets
                                                                    .symmetric(
                                                                        horizontal:
                                                                            8),
                                                                child: Row(
                                                                  children: [
                                                                    Text(
                                                                      snap[
                                                                          'description'],
                                                                      style: AppTheme
                                                                          .subtitle,
                                                                    ),
                                                                    Spacer(),
                                                                    Text(
                                                                      '\$' +
                                                                          snap['variations'][0]['price']
                                                                              .toString(),
                                                                      style:
                                                                          TextStyle(
                                                                        fontFamily:
                                                                            'Montserrat',
                                                                        fontWeight:
                                                                            FontWeight.bold,
                                                                        color: AppTheme
                                                                            .vinho,
                                                                      ),
                                                                    )
                                                                  ],
                                                                ))
                                                          ],
                                                        )),
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                        );
                                      },
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16),
                                      child: Row(
                                        children: [
                                          Text(
                                            FirebaseAuth.instance.currentUser!
                                                        .uid ==
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
                                            itemCount: (snapshot.data!
                                                    as QuerySnapshot)
                                                .docs
                                                .length,
                                            scrollDirection: Axis.horizontal,
                                            itemBuilder: (context, index) {
                                              DocumentSnapshot snap = (snapshot
                                                      .data! as QuerySnapshot)
                                                  .docs[index];

                                              return GestureDetector(
                                                onTap: () {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          SeePost(
                                                              postId: snap[
                                                                  'votationId']),
                                                    ),
                                                  );
                                                },
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                    child: Container(
                                                      width: 150,
                                                      decoration: BoxDecoration(
                                                        color: Colors.grey,
                                                      ),
                                                      child: Image(
                                                        image: NetworkImage(
                                                            snap['options'][0]
                                                                ['photoUrl']),
                                                        fit: BoxFit.cover,
                                                      ),
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
                        if (selectedOption == "For you") ...[
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
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          child: Container(
                                            width: 150,
                                            decoration: BoxDecoration(
                                              color: Colors.grey,
                                            ),
                                            child: Container(
                                              width: 150,
                                              decoration: BoxDecoration(
                                                color: Colors.grey,
                                              ),
                                              child: Image(
                                                image: NetworkImage(
                                                    snap['photoUrls'][0]),
                                                fit: BoxFit.cover,
                                              ),
                                            ),
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
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          child: Container(
                                            width: 150,
                                            decoration: BoxDecoration(
                                              color: Colors.grey,
                                            ),
                                            child: Image(
                                              image: NetworkImage(
                                                  snap['photoUrls'][0]),
                                              fit: BoxFit.cover,
                                            ),
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
                    );
                  },
                  childCount: 1,
                ),
                itemExtent: 750.h),
          ]));
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

class CustomOvalClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0.0, size.height - 50);
    path.quadraticBezierTo(
      size.width / 4,
      size.height,
      size.width / 2,
      size.height,
    );
    path.quadraticBezierTo(
      size.width - size.width / 4,
      size.height,
      size.width,
      size.height - 50,
    );
    path.lineTo(size.width, 0.0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class ClipShadowPath extends StatelessWidget {
  final Shadow shadow;
  final CustomClipper<Path> clipper;
  final Widget child;

  ClipShadowPath({
    required this.shadow,
    required this.clipper,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _ClipShadowShadowPainter(
        clipper: this.clipper,
        shadow: this.shadow,
      ),
      child: ClipPath(child: child, clipper: this.clipper),
    );
  }
}

class _ClipShadowShadowPainter extends CustomPainter {
  final Shadow shadow;
  final CustomClipper<Path> clipper;

  _ClipShadowShadowPainter({required this.shadow, required this.clipper});

  @override
  void paint(Canvas canvas, Size size) {
    var paint = shadow.toPaint();
    var clipPath = clipper.getClip(size).shift(shadow.offset);
    canvas.drawPath(clipPath, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
