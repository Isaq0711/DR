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
            } else {
              selectedIndexes.add(index);
            }
          });
        },
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: isSelected ? AppTheme.vinho : Colors.transparent,
              width: 3.0,
            ),
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10.0),
            child: index > 0 && _files != null && _files!.isNotEmpty
                ? Image.memory(
                    _files![index - 1],
                    fit: BoxFit.cover,
                  )
                : Container(),
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
        backgroundColor: AppTheme.vinho,
        title: const Text(
          'My basket',
          style: AppTheme.subheadlinewhite,
        ),
        centerTitle: true,
      ),
       body: SingleChildScrollView(
      child: Column(
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
                Container(
                  width: MediaQuery.of(context).size.width * 0.2,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      primary: AppTheme.vinho,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    child: Text('TOP',  style: AppTheme.subtitlewhite),
                  ),
                ),
                Container(
                  width: MediaQuery.of(context).size.width * 0.25,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      primary: AppTheme.vinho,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    child: Text('BOTTOM',  style: AppTheme.subtitlewhite),
                  ),
                ),
                Container(
                  width: MediaQuery.of(context).size.width * 0.2,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      primary: AppTheme.vinho,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    child: Text('SHOES', style: AppTheme.subtitlewhite,),
                  ),
                ),
                Container(
                  width: MediaQuery.of(context).size.width * 0.2,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      primary: AppTheme.vinho,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    child: Text('COATS' ,style: AppTheme.subtitlewhite),
                  ),
                ),
              ],
            ),
          ),
            
            Container(height: MediaQuery.of(context).size.height * 0.008),
            Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height * 0.8,
              padding: EdgeInsets.symmetric(horizontal: 8.0),
              child: CustomScrollView(
                scrollDirection: Axis.vertical,
                slivers: [
                  SliverGrid(
                    gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: MediaQuery.of(context).size.width * 0.25,
                      childAspectRatio: 0.8,
                      crossAxisSpacing: 8.0,
                      mainAxisSpacing: 8.0,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (BuildContext context, int index) {
                        return buildGridViewItem(index);
                      },
                      childCount: (_files?.length ?? 0) + 1,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
