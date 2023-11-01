import 'package:flutter/material.dart';
import 'package:dressing_room/utils/colors.dart';
import 'package:intl/intl.dart';
import 'package:dressing_room/models/user.dart' as model;
import 'package:dressing_room/providers/user_provider.dart';
import 'package:provider/provider.dart';

class CommentCard extends StatelessWidget {
  final snap;
  final VoidCallback onDelete; // Adicione onDelete como um parâmetro

  CommentCard({Key? key, required this.snap, required this.onDelete})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final model.User user = Provider.of<UserProvider>(context).getUser;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundImage: NetworkImage(
              snap.data()['profilePic'],
            ),
            radius: 9,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  snap.data()['name'],
                  style: AppTheme.subtitle,
                ),
                const SizedBox(height: 4),
                Text(
                  snap.data()['text'],
                  style: AppTheme.title,
                ),
                const SizedBox(height: 4),
                Text(
                  DateFormat.yMMMd().format(
                    snap.data()['datePublished'].toDate(),
                  ),
                  style: AppTheme.caption,
                ),
              ],
            ),
          ),
          if (snap['uid'].toString() == user.uid)
            IconButton(
              icon: Icon(Icons.delete_rounded, color: Colors.grey,),
              onPressed: onDelete,
            ), // Adicione o IconButton de exclusão
        ],
      ),
    );
  }
}
