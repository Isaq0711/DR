import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:custom_image_crop/custom_image_crop.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'dart:typed_data';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:dressing_room/resources/comn[1].dart';

String server = '192.168.1.2';
String port = '5000';
Future<Uint8List> removeBg(String imagePath) async {
  var request =
      http.MultipartRequest("POST", Uri.parse('http://$server:$port/removebg'));
  request.files.add(await http.MultipartFile.fromPath("image_file", imagePath));
  request.headers.addAll({"X-API-Key": "dress"});
  request.fields['user'] = FirebaseAuth.instance.currentUser!.uid;

  final response = await Future.any([
    request.send(),
    Future.delayed(Duration(seconds: 2), () => null) // Timeout after 2 seconds
  ]);

  if (response == null) {
    // Se a resposta for nula (timeout), retorne a imagem original
    return await File(imagePath).readAsBytes();
  } else if (response is http.StreamedResponse && response.statusCode == 200) {
    // Se a resposta for bem-sucedida, retorne os bytes da imagem removida do fundo
    http.Response imgRes = await http.Response.fromStream(response);
    return imgRes.bodyBytes;
  } else {
    return await File(imagePath).readAsBytes();
  }
}

pickImage(ImageSource source) async {
  final ImagePicker _imagePicker = ImagePicker();
  final ImageCropper _imageCropper = ImageCropper();
  XFile? _file = await _imagePicker.pickImage(source: source);
  if (_file != null) {
    // Crop the image
    final croppedFile = await ImageCropper().cropImage(
      sourcePath: _file.path,
      aspectRatio: CropAspectRatio(
        ratioX: 9,
        ratioY: 16,
      ),
      compressQuality: 100,
      androidUiSettings: AndroidUiSettings(
        toolbarTitle: 'Crop Image',
        toolbarColor: AppTheme.vinho,
        toolbarWidgetColor: Colors.white,
      ),
    );

    if (croppedFile != null) {
      return await croppedFile.readAsBytes();
    }
  }

  print('No Image Selected');
}

pickImage1por1(ImageSource source) async {
  final ImagePicker _imagePicker = ImagePicker();
  final ImageCropper _imageCropper = ImageCropper();
  XFile? _file = await _imagePicker.pickImage(source: source);
  if (_file != null) {
    // Crop the image
    final croppedFile = await ImageCropper().cropImage(
      maxHeight: 800.h.toInt(),
      sourcePath: _file.path,
      androidUiSettings: AndroidUiSettings(
        toolbarTitle: 'Crop Item',
        toolbarColor: AppTheme.vinho,
        toolbarWidgetColor: Colors.white,
        lockAspectRatio: false,
      ),
    );

    if (croppedFile != null) {
      return await croppedFile.readAsBytes();
    }
  }
}

showSnackBar(BuildContext context, String text) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(text),
    ),
  );
}
