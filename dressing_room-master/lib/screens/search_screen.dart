import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:dressing_room/screens/profile_screen.dart';
import 'package:dressing_room/utils/colors.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController searchController = TextEditingController();
  bool isShowUsers = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.vinho,
        title: Form(
          child: TextFormField(
            controller: searchController,
            decoration: const InputDecoration(
                labelText: 'Search for a user, look, store, .... '),
            onFieldSubmitted: (String _) {
              setState(() {
                isShowUsers = true;
              });
              print(_);
            },
          ),
        ),
      ),
      body: isShowUsers
          ? FutureBuilder(
              future: FirebaseFirestore.instance
                  .collection('users')
                  .where(
                    'username',
                    isGreaterThanOrEqualTo: searchController.text,
                  )
                  .get(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
                return ListView.builder(
                  itemCount: (snapshot.data! as QuerySnapshot).docs.length,
                  itemBuilder: (context, index) {
                    final doc = (snapshot.data! as QuerySnapshot).docs[index];
                    return InkWell(
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => ProfileScreen(
                            uid: doc['uid'],
                          ),
                        ),
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundImage: NetworkImage(doc['photoUrl']),
                          radius: 16,
                        ),
                        title: Text(
                          doc['username'],
                          style: AppTheme.subtitle,
                        ),
                      ),
                    );
                  },
                );
              },
            )
          : FutureBuilder(
              future: FirebaseFirestore.instance
                  .collection('products')
                  .orderBy('datePublished')
                  .get(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                final documents = (snapshot.data! as QuerySnapshot).docs;

                return GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 8.0,
                    crossAxisSpacing: 8.0,
                    childAspectRatio: 1.0,
                  ),
                  itemCount: documents.length,
                  itemBuilder: (context, index) => Image.network(
                    documents[index]['variations'][0]['photoUrls'][1]
                        .toString(),
                    fit: BoxFit.cover,
                  ),
                );
              },
            ),
    );
  }
}
