import 'dart:typed_data';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:dressing_room/providers/user_provider.dart';
import 'package:dressing_room/models/user.dart';
import 'package:provider/provider.dart';
import 'package:dressing_room/widgets/select_image_dialog.dart';
import 'package:dressing_room/utils/colors.dart';

class BasketScreen extends StatefulWidget {
  const BasketScreen({Key? key}) : super(key: key);

  @override
  _BasketScreenState createState() => _BasketScreenState();
}

class _BasketScreenState extends State<BasketScreen>
    with SingleTickerProviderStateMixin {
  List<Uint8List>? _files;
  bool isLoading = false;
  List<int> selectedIndexes = [];
  int? selectedButtonIndex;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  void _selectImage(BuildContext parentContext) async {
    showDialog(
      context: parentContext,
      builder: (BuildContext context) {
        return SelectImageDialog(
          onImageSelected: (Uint8List file) {
            setState(() {
              _files ??= [];
              _files!.add(file);
            });
          },
        );
      },
    );
  }

  Widget buildGridViewItem(int index) {
    final isSelected = selectedIndexes.contains(index);
    if (index == 0) {
      return InkWell(
        onTap: () => _selectImage(context),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.transparent,
              width: 3.0,
            ),
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10.0),
            child: Image.asset(
             'assets/BUTTON-ADD.png' ,
              fit: BoxFit.cover,
            ),
          ),
        ),
      );
    } else {
      return GestureDetector(
        onTap: () {
          setState(() {
            if (isSelected) {
              selectedIndexes.remove(index);
              selectedButtonIndex = null;
            } else {
              selectedIndexes.clear();
              selectedIndexes.add(index);
              selectedButtonIndex = index;
            }
          });
        },
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: isSelected ? AppTheme.vinhoescuro : Colors.transparent,
              width: 3.0,
            ),
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10.0),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: index > 0 && _files != null && _files!.isNotEmpty
                  ? Image.memory(
                      _files![index - 1],
                      fit: BoxFit.cover,
                    )
                  : Container(),
            ),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, _) {
        var user = userProvider.getUser;
        if (user != null) {
          return _buildContent(user);
        } else {
          return Container();
        }
      },
    );
  }

  Scaffold _buildContent(User user) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: AppTheme.vinho,
        title: const Text(
          'My basket',
          style: AppTheme.subheadlinewhite,
        ),
        centerTitle: true,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(height: MediaQuery.of(context).size.height * 0.008),
          TabBar(
            controller: _tabController,
            indicatorColor: AppTheme.vinhoescuro,
            labelColor: AppTheme.vinhoescuro,
            unselectedLabelColor: AppTheme.vinho,
            tabs: [
              Tab(text: 'TOP'),
              Tab(text: 'BOTTOM'),
              Tab(text: 'SHOES'),
              Tab(text: 'COATS'),
            ],
            onTap: (index) {
              setState(() {
                selectedButtonIndex = index + 1;
                selectedIndexes.clear();
              });
            },
          ),
          Container(height: MediaQuery.of(context).size.height * 0.008),
          Expanded(
            child: Container(
              width: MediaQuery.of(context).size.width,
              padding: EdgeInsets.symmetric(horizontal: 8.0),
              child: GridView.builder(
                physics: AlwaysScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: MediaQuery.of(context).size.width * 0.25,
                  childAspectRatio: 0.8,
                  crossAxisSpacing: 8.0,
                  mainAxisSpacing: 8.0,
                ),
                itemCount: (_files?.length ?? 0) + 1,
                itemBuilder: (BuildContext context, int index) {
                  return buildGridViewItem(index);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
