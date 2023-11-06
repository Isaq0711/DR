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

class _BasketScreenState extends State<BasketScreen> {
  List<Uint8List>? _files;
  bool isLoading = false;
  Timer? _timer;
  List<int> selectedIndexes = [];
  int? selectedButtonIndex;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback((_) {});
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
            child: Image.network(
              'https://www.creativefabrica.com/wp-content/uploads/2019/05/Add-icon-by-ahlangraphic-1-580x386.jpg',
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
          Container(
            padding: EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      selectedButtonIndex = 1;
                      selectedIndexes.clear();
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    primary: selectedButtonIndex == 1 ? AppTheme.vinhoescuro : AppTheme.vinho,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  child: Text('TOP', style: AppTheme.subtitlewhite),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      selectedButtonIndex = 2;
                      selectedIndexes.clear();
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    primary: selectedButtonIndex == 2 ? AppTheme.vinhoescuro : AppTheme.vinho,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  child: Text('BOTTOM', style: AppTheme.subtitlewhite),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      selectedButtonIndex = 3;
                      selectedIndexes.clear();
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    primary: selectedButtonIndex == 3 ? AppTheme.vinhoescuro : AppTheme.vinho,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  child: Text(
                    'SHOES',
                    style: AppTheme.subtitlewhite,
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      selectedButtonIndex = 4;
                      selectedIndexes.clear();
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    primary: selectedButtonIndex == 4 ? AppTheme.vinhoescuro : AppTheme.vinho,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  child: Text('COATS', style: AppTheme.subtitlewhite),
                ),
              ],
            ),
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
