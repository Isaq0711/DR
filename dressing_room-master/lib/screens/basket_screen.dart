import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:dressing_room/providers/user_provider.dart';
import 'package:dressing_room/models/user.dart';
import 'package:flutter/cupertino.dart';
import 'package:gap/gap.dart';
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
  List<List<Uint8List>?> _filesByTab = List.generate(4, (_) => null);
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
    final selectedTabIndex = _tabController.index;

    showDialog(
      context: parentContext,
      builder: (BuildContext context) {
        return SelectImageDialog(
          onImageSelected: (Uint8List file) {
            setState(() {
              _filesByTab[selectedTabIndex] ??= [];
              _filesByTab[selectedTabIndex]!.add(file);
            });
          },
        );
      },
    );
  }

  Widget buildGridViewItem(int index) {
    final isSelected = selectedIndexes.contains(index);
    final selectedTabIndex = _tabController.index;

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
              'assets/BUTTON-ADD.png',
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
              child: index > 0 &&
                      _filesByTab[selectedTabIndex] != null &&
                      _filesByTab[selectedTabIndex]!.isNotEmpty
                  ? Image.memory(
                      _filesByTab[selectedTabIndex]![index - 1],
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
        backgroundColor: Colors.transparent,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(
            CupertinoIcons.arrow_left,
            color: AppTheme.nearlyBlack,
          ),
        ),
        title: Text(
          'My basket',
          style: AppTheme.subheadline.copyWith(
            shadows: [
              Shadow(
                blurRadius: 2.0,
                color: Colors.black, // Cor da sombra
                // Deslocamento X e Y da sombra
              ),
            ],
          ),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 26),
            child: IconButton(
              icon: Icon(
                shadows: <Shadow>[
                  Shadow(color: AppTheme.nearlyBlack, blurRadius: 5.0)
                ],
                Icons.check,
                color: AppTheme.vinho,
              ),
              onPressed: () {},
            ),
          )
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Gap(MediaQuery.of(context).size.height * 0.008),
          TabBar(
            controller: _tabController,
            indicatorColor: AppTheme.vinhoescuro,
            labelStyle: AppTheme.subtitle.copyWith(
              shadows: [
                Shadow(
                  blurRadius: 5.0,
                  color: Colors.black, // Cor da sombra
                  // Deslocamento X e Y da sombra
                ),
              ],
            ),
            unselectedLabelColor: AppTheme.nearlyWhite,
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
                itemCount: (_filesByTab[_tabController.index]?.length ?? 0) + 1,
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
