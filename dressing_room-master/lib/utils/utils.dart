import 'package:flutter/material.dart';

import 'package:custom_image_crop/custom_image_crop.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'colors.dart';

Future<Uint8List> removeBg(String imagePath) async {
  var request = http.MultipartRequest(
      "POST", Uri.parse("https://api.remove.bg/v1.0/removebg"));
  request.files.add(await http.MultipartFile.fromPath("image_file", imagePath));
  request.headers.addAll({"X-API-Key": "XH5axMWfLx5SSxSFLqEvJcMA"});
  final response = await request.send();
  if (response.statusCode == 200) {
    http.Response imgRes = await http.Response.fromStream(response);
    return imgRes.bodyBytes;
  } else {
    throw Exception("Error");
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

// for displaying snackbars
showSnackBar(BuildContext context, String text) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(text),
    ),
  );
}
