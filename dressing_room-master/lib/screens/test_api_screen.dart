import 'dart:typed_data';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:dressing_room/providers/user_provider.dart';
import 'package:dressing_room/models/user.dart';
import 'package:provider/provider.dart';
import 'package:dressing_room/widgets/select_image_dialog.dart';
import 'package:dressing_room/utils/colors.dart';
import 'basket_screen.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class TestAPIScreen extends StatefulWidget {
  const TestAPIScreen({Key? key}) : super(key: key);

  @override
  _TestAPIScreenState createState() => _TestAPIScreenState();
}

class _TestAPIScreenState extends State<TestAPIScreen> {
  List<Uint8List>? _files;
  List<Uint8List>? _bigfiles;
  bool isLoading = false;
  bool _showNetworkImage = false;
  Timer? _timer;
  List<int> selectedIndexes = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      _selectBigImage(context);
    });
  }

  void _showNetworkImageOnLongPress() {
    _timer = Timer(Duration(seconds: 1), () {
      setState(() {
        _showNetworkImage = true;
      });
    });
  }

  void _resetNetworkImage() {
    if (_timer != null && _timer!.isActive) {
      _timer!.cancel();
    }
    setState(() {
      _showNetworkImage = false;
    });
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

  void _selectBigImage(BuildContext parentContext) async {
    showDialog(
      context: parentContext,
      builder: (BuildContext context) {
        return SelectImageDialog(
          onImageSelected: (Uint8List file) {
            setState(() {
              _bigfiles = [];
              _bigfiles!.add(file);
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
            child:  index > 0 && _files != null && _files!.isNotEmpty
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
    return _bigfiles == null
        ? Scaffold(
            body: Container(),
          )
        : Scaffold(
            appBar: AppBar(
              backgroundColor: AppTheme.vinho,
              title: const Text('Test API' , style: AppTheme.subheadlinewhite,
              ),
              
            ),
            body: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.55,
                          width: double.infinity,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10.0),
                            
                            child: GestureDetector(
                              onLongPress: () {
                                _showNetworkImageOnLongPress();
                              },
                               onLongPressEnd: (details) {
                                  _resetNetworkImage();
                                },
                              child: _showNetworkImage
                                  ? Image.network(
                                      'https://i0.wp.com/inspi.com.br/wp-content/uploads/2019/11/bliss-Charles-ORear.jpg?fit=1000%2C804&ssl=1',
                                      fit: BoxFit.cover,
                                      height: double.infinity,
                                    width: double.infinity,
                                    )
                                  : Image.memory(
                                      _bigfiles![0],
                                      fit: BoxFit.cover,
                                      height: double.infinity,
                                    width: double.infinity,
                                    ),
                            ),
                          ),
                        ),
                      ],
                    ),
                   Container(
                  height: MediaQuery.of(context).size.height * 0.008), 
                 
              Container(
                  height: MediaQuery.of(context).size.height * 0.13,
                  child: CustomScrollView(
                    scrollDirection: Axis.horizontal,
                    slivers: [
                      SliverGrid(
                        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 200,
                          childAspectRatio: 3 / 2,
                          crossAxisSpacing: 20,
                          mainAxisSpacing: 10,
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
                 Center(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ElevatedButton(
                        style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all<Color>(AppTheme.vinho),
                        ),
                        onPressed: () {
                          // TODO: Implement logic for check out
                        },
                        child: const Text('TRY OUTFIT', style: AppTheme.subtitlewhite,),
                      ),
                    ),
                  ),
                   
              ],
            ),
            
          ),
        );
}}