import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:dressing_room/utils/colors.dart';
import 'package:dressing_room/widgets/select_image_dialog.dart';

class TestAPIScreen extends StatefulWidget {
  const TestAPIScreen({Key? key}) : super(key: key);

  @override
  _TestAPIScreenState createState() => _TestAPIScreenState();
}

class _TestAPIScreenState extends State<TestAPIScreen> {
  List<Uint8List>? _files;
  List<Uint8List>? _bigfiles;
  bool isLoading = false;
  List<int> selectedIndexes = [];

  @override
  void initState() {
    super.initState();
    _selectBigImage(context);
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
            child: Image.memory(
              _files![index - 1],
              fit: BoxFit.cover,
            ),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.vinho,
        title: const Text('Test API'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: MediaQuery.of(context).size.height * 0.008),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.3,
              width: double.infinity,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.3,
                    width: double.infinity,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10.0),
                      child: _bigfiles != null && _bigfiles!.isNotEmpty
                          ? Image.memory(
                              _bigfiles![0],
                              fit: BoxFit.cover,
                            )
                          : GestureDetector(
                              onTap: () {
                                _selectBigImage(context);
                              },
                              child: Image.network(
                                'https://t4.ftcdn.net/jpg/01/64/16/59/360_F_164165971_ELxPPwdwHYEhg4vZ3F4Ej7OmZVzqq4Ov.jpg',
                                fit: BoxFit.cover,
                              ),
                            ),
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
                    backgroundColor: MaterialStateProperty.all<Color>(AppTheme.vinho),
                  ),
                  onPressed: () {
                    // TODO: Implement logic for check out
                  },
                  child: const Text('TRY OUTFIT'),
                ),
              ),
            ),
            Container(
              height: MediaQuery.of(context).size.height * 0.2,
              child: GridView.count(
                padding: EdgeInsets.all(8.0),
                crossAxisCount: 5,
                childAspectRatio: 0.7,
                mainAxisSpacing: 8.0,
                crossAxisSpacing: 8.0,
                children: List.generate((_files?.length ?? 0) + 1, (index) {
                  return buildGridViewItem(index);
                }),
              ),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.3,
              width: double.infinity,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.3,
                    width: double.infinity,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10.0),
                      child: _bigfiles != null && _bigfiles!.isNotEmpty
                          ? Image.memory(
                              _bigfiles![0],
                              fit: BoxFit.cover,
                            )
                          : Image.network(
                              'https://www.example.com/your_large_image.jpg',
                              fit: BoxFit.cover,
                            ),
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
