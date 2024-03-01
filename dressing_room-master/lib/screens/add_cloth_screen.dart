import 'dart:typed_data';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';
import 'package:dressing_room/widgets/select_image_dialog.dart';
import 'package:dressing_room/utils/utils.dart';
import 'package:dressing_room/utils/colors.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as img;

class AddClothScreen extends StatefulWidget {
  const AddClothScreen({Key? key}) : super(key: key);

  @override
  _AddClothScreenState createState() => _AddClothScreenState();
}

class _AddClothScreenState extends State<AddClothScreen> {
  bool _isPaintingMode = false;
  double _sliderValue = 25;
  List<Uint8List>? _files;
  bool isLoading = false;
  final TextEditingController _descriptionController = TextEditingController();
  late PageController _pageController;
  int _currentPageIndex = 0;
  Map<int, List<Offset>> _selectedPositionsMap = {};

  void _togglePaintingMode() {
    setState(() {
      _isPaintingMode = !_isPaintingMode;
    });
  }

  void _paintOnImage(Offset position) {
    if (_isPaintingMode) {
      setState(() {
        // Add the position to the selected positions list for the current image
        _selectedPositionsMap[_currentPageIndex]!.add(position);
      });
    }
  }

  void _undoPainting() {
    setState(() {
      if (_selectedPositionsMap[_currentPageIndex]!.isNotEmpty) {
        int count = 25;

        for (int i = 0; i < count; i++) {
          if (_selectedPositionsMap[_currentPageIndex]!.isNotEmpty) {
            _selectedPositionsMap[_currentPageIndex]!.removeLast();
          } else {
            break;
          }
        }
      }
    });
  }

  void _deleteCurrentImage() {
    setState(() {
      _files!.removeAt(_currentPageIndex);
      _selectedPositionsMap.remove(_currentPageIndex);
      if (_currentPageIndex >= _files!.length) {
        // Se a página atual era a última imagem, volta uma página
        _currentPageIndex = (_files!.isEmpty ? 0 : _files!.length - 1);
        _pageController.animateToPage(
          _currentPageIndex,
          duration: const Duration(milliseconds: 300),
          curve: Curves.ease,
        );
      }
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      _selectImage(context);
    });

    _pageController = PageController(initialPage: 0);
  }

  Future<File> saveBytesToFile(Uint8List bytes) async {
    Directory tempDir = await getTemporaryDirectory();
    File tempFile = File('${tempDir.path}/temp_image.png');
    await tempFile.writeAsBytes(bytes);
    return tempFile;
  }

  _selectImage(BuildContext parentContext) async {
    showDialog(
      context: parentContext,
      builder: (BuildContext context) {
        return SelectImageDialog1por1(
          onImageSelected: (Uint8List file) async {
            // Salvar temporariamente a imagem
            File tempFile = await saveBytesToFile(file);
            setState(() {
              _files ??= [];
              _files!.add(file);
              isLoading = true; // Ativar indicador de progresso
            });

            try {
              Uint8List processedImage = await removeBg(tempFile.path);
              setState(() {
                _files!.removeLast();
                _files!.add(processedImage);
                isLoading = false;
              });
            } catch (e) {
              print("Erro ao remover o fundo da imagem: $e");

              setState(() {
                isLoading = false;
              });
            }

            await tempFile.delete();
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return _files == null
        ? Container()
        : Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              leading: IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: Icon(
                  Icons.arrow_back_ios,
                  color: AppTheme.nearlyBlack,
                ),
              ),
              title: Text('Edit Cloth',
                  style: AppTheme.barapp.copyWith(
                    shadows: [
                      Shadow(
                        blurRadius: 2.0,
                        color: Colors.black,
                      ),
                    ],
                  )),
              centerTitle: true,
              bottom: PreferredSize(
                preferredSize: Size.fromHeight(40.h),
                child: Container(
                  width: double.infinity,
                  color: Colors.transparent,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      IconButton(
                        onPressed: _deleteCurrentImage,
                        icon: Icon(
                          Icons.delete,
                          color: AppTheme.vinho,
                        ),
                      ),
                      Spacer(),
                      IconButton(
                        icon: Icon(Icons.undo,
                            color:
                                (_selectedPositionsMap[_currentPageIndex] ?? [])
                                        .isEmpty
                                    ? Colors.grey
                                    : AppTheme.vinho),
                        onPressed:
                            (_selectedPositionsMap[_currentPageIndex] ?? [])
                                    .isEmpty
                                ? null
                                : _undoPainting,
                      ),
                      if (_isPaintingMode) ...[
                        PopupMenuButton(
                          itemBuilder: (BuildContext context) {
                            return [
                              PopupMenuItem(
                                child: StatefulBuilder(
                                  builder: (BuildContext context,
                                      StateSetter setState) {
                                    return Row(
                                      children: [
                                        Icon(Icons.brush),
                                        SizedBox(width: 8),
                                        Expanded(
                                          child: Slider(
                                            value: _sliderValue,
                                            min: 10,
                                            max: 100,
                                            onChanged: (value) {
                                              setState(() {
                                                _sliderValue = value;
                                              });
                                            },
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                ),
                              ),
                            ];
                          },
                          child: Icon(Icons.circle, color: Colors.grey),
                        ),
                      ],
                      IconButton(
                        icon: Icon(Icons.brush,
                            color:
                                _isPaintingMode ? AppTheme.vinho : Colors.grey),
                        onPressed: _togglePaintingMode,
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.save),
                ),
              ],
            ),
            body: Column(
              children: <Widget>[
                isLoading
                    ? LinearProgressIndicator()
                    : Flexible(
                        child: Stack(
                          children: [
                            PageView.builder(
                              physics: NeverScrollableScrollPhysics(),
                              controller: _pageController,
                              itemCount: _files!.length,
                              onPageChanged: (int index) {
                                setState(() {
                                  _currentPageIndex = index;
                                });
                              },
                              itemBuilder: (context, pageIndex) {
                                _selectedPositionsMap.putIfAbsent(
                                    pageIndex, () => []);
                                return GestureDetector(
                                  onPanUpdate: (details) {
                                    _paintOnImage(details.localPosition);
                                  },
                                  child: SizedBox(
                                      child: Stack(
                                    children: [
                                      Image.memory(
                                        _files![_currentPageIndex],
                                        fit: BoxFit.cover,
                                      ),
                                      CustomPaint(
                                        painter: _ImagePainter(
                                          image: _files![pageIndex],
                                          selectedPositions:
                                              _selectedPositionsMap[pageIndex]!,
                                          sliderValue: _sliderValue,
                                        ),
                                        child: Container(
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                              color:
                                                  Colors.black, // Cor da borda
                                              width: 2.0, // Largura da borda
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(10.0),
                                          ),
                                        ),
                                      ),
                                    ],
                                  )),
                                );
                              },
                            ),
                            if (_currentPageIndex > 0) ...[
                              Positioned(
                                top: MediaQuery.of(context).size.height / 2 -
                                    15.0,
                                left: 16.0,
                                child: GestureDetector(
                                  onTap: () {
                                    _pageController.animateToPage(
                                        _currentPageIndex - 1,
                                        duration:
                                            const Duration(milliseconds: 300),
                                        curve: Curves.ease);
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: AppTheme.vinho,
                                    ),
                                    child: const Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Icon(
                                        Icons.arrow_back_ios,
                                        color: Colors.white,
                                        size: 20.0,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                            if (_currentPageIndex < _files!.length - 1) ...[
                              Positioned(
                                top: MediaQuery.of(context).size.height / 2 -
                                    15.0,
                                right: 16.0,
                                child: GestureDetector(
                                  onTap: () {
                                    _pageController.animateToPage(
                                        _currentPageIndex + 1,
                                        duration:
                                            const Duration(milliseconds: 300),
                                        curve: Curves.ease);
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: AppTheme.vinho,
                                    ),
                                    child: const Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Icon(
                                        Icons.arrow_forward_ios,
                                        color: Colors.white,
                                        size: 20.0,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                GestureDetector(
                  onTap: () => _selectImage(context),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      const Icon(
                        Icons.add,
                        color: Colors.black,
                      ),
                      const SizedBox(width: 4),
                      const Text(
                        'Add More',
                        style: TextStyle(
                          fontFamily: 'Quicksand',
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(width: 20),
                    ],
                  ),
                ),
              ],
            ),
          );
  }
}

class _ImagePainter extends CustomPainter {
  final Uint8List image;
  final List<Offset> selectedPositions;
  final double sliderValue;

  _ImagePainter({
    required this.image,
    required this.selectedPositions,
    required this.sliderValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final image = img.decodeImage(this.image)!;
    final paint = Paint()..color = AppTheme.cinza;

    for (final position in selectedPositions) {
      final imagePosition = Offset(
        position.dx,
        position.dy,
      );
      canvas.drawCircle(imagePosition, sliderValue, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
