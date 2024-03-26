import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:gap/gap.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

class ImageCropPage extends StatefulWidget {
  const ImageCropPage({Key? key}) : super(key: key);

  @override
  _ImageCropPageState createState() => _ImageCropPageState();
}

class _ImageCropPageState extends State<ImageCropPage> {
  List<Uint8List> _croppedImages = [];
  List<String> _captions = [];
  XFile? _imageFile;
  Uint8List? _originalImageBytes;

  @override
  void initState() {
    super.initState();
    _pickImage();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: Icon(Icons.skip_next),
            onPressed: () {
              print(_captions);
            },
          ),
          IconButton(
            icon: Icon(Icons.send),
            onPressed: () {
              setState(() {
                if (_originalImageBytes != null) {
                  _croppedImages.insert(0, _originalImageBytes!);
                }

                segmenta(_croppedImages);
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            height: 300.h,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10.0),
              child: _originalImageBytes != null
                  ? Image.memory(_originalImageBytes!)
                  : Container(), // Verifica se a imagem foi selecionada
            ),
          ),
          Gap(20.h),
          Expanded(
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 4.0,
                mainAxisSpacing: 4.0,
              ),
              itemCount: _croppedImages.length,
              itemBuilder: (BuildContext context, int index) {
                return GridTile(
                  child: Image.memory(_croppedImages[index]),
                  footer: Material(
                    color: Colors.transparent,
                    shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.vertical(bottom: Radius.circular(4))),
                    child: GridTileBar(
                      backgroundColor: Colors.black45,
                      title: Text(_captions.isNotEmpty
                          ? _captions[index]
                          : 'Loading...'),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _cropImage(_imageFile!.path);
        },
        child: Icon(Icons.crop),
      ),
    );
  }

  Future<void> _pickImage() async {
    final ImagePicker _imagePicker = ImagePicker();

    _imageFile = await _imagePicker.pickImage(source: ImageSource.gallery);

    if (_imageFile != null) {
      Uint8List? imageBytes = await _imageFile!.readAsBytes();
      setState(() {
        _originalImageBytes = imageBytes;
      });
    }
  }

  Future<void> _cropImage(String imagePath) async {
    final ImageCropper _imageCropper = ImageCropper();
    final croppedFile = await _imageCropper.cropImage(
      sourcePath: imagePath,
      androidUiSettings: AndroidUiSettings(
        toolbarTitle: 'Crop Item',
        toolbarColor: Colors.green,
        toolbarWidgetColor: Colors.white,
        lockAspectRatio: false,
      ),
    );

    if (croppedFile != null) {
      Uint8List? croppedBytes = await croppedFile.readAsBytes();
      if (croppedBytes != null) {
        setState(() {
          _croppedImages.add(croppedBytes!);
        });
      }
    }
  }

  String server = '192.168.1.2';
  String port = '5000';

  Future<void> segmenta(List<Uint8List> imageBytesList) async {
    var request = http.MultipartRequest(
        "POST", Uri.parse('http://$server:$port/segmentacao'));

    for (int i = 0; i < imageBytesList.length; i++) {
      final imageFile = http.MultipartFile.fromBytes(
        'image_file', // Nome do campo no servidor
        imageBytesList[i],
        filename: 'image_$i.png', // Nome do arquivo
      );
      request.files.add(imageFile);
    }
    request.headers.addAll({"X-API-Key": "dress"});
    request.fields['user'] = FirebaseAuth.instance.currentUser!.uid;
    request.fields['id_imagem'] = "teste";
    try {
      final response = await request.send();
      if (response.statusCode == 200) {
        final responseJson = await http.Response.fromStream(response);
        final captions = json.decode(responseJson.body);
        setState(() {
          _captions = captions.values.toList().cast<String>();
        });
      } else {
        throw Exception('Erro ao enviar imagem para o servidor');
      }
    } catch (e) {
      print('Erro durante a solicitação: $e');
    }
  }
}
