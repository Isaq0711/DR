import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'colors.dart';

// for picking up image from gallery
pickImage(ImageSource source) async {
  final ImagePicker _imagePicker = ImagePicker();
  final ImageCropper _imageCropper = ImageCropper();
  XFile? _file = await _imagePicker.pickImage(source: source);
  if (_file != null) {
    // Crop the image
    final croppedFile = await ImageCropper().cropImage(
      sourcePath: _file.path,
      aspectRatio: CropAspectRatio(
        ratioX: 1, // You can customize the aspect ratio here
        ratioY: 1,
      ),
      compressQuality: 100, // Adjust the image quality (0 - 100)
      maxWidth: 800, // Limit the maximum width of the cropped image
      maxHeight: 800, // Limit the maximum height of the cropped image
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