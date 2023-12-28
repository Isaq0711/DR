import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dressing_room/utils/colors.dart';
import 'package:dressing_room/utils/utils.dart';

class SelectImageDialog extends StatelessWidget {
  final Function(Uint8List) onImageSelected;

  SelectImageDialog({required this.onImageSelected});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppTheme.nearlyWhite,
      title: Align(
        alignment: Alignment.center,
        child: const Text(
          'UPLOAD',
          style: AppTheme.subheadline,
        ),
      ),
      content: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ElevatedButton.icon(
            icon: Icon(Icons.camera),
            label: const Text(
              'Camera',
              style: TextStyle(
                fontFamily: 'Quicksand',
                fontWeight: FontWeight.bold,
              ),
            ),
            style: ElevatedButton.styleFrom(primary: AppTheme.vinho),
            onPressed: () async {
              Navigator.pop(context);
              Uint8List? file = await pickImage(ImageSource.camera);
              if (file != null) {
                onImageSelected(file);
              }
            },
          ),
          SizedBox(
            width: 10,
          ),
          ElevatedButton.icon(
            icon: Icon(Icons.photo_library),
            label: const Text(
              'Gallery',
              style: TextStyle(
                fontFamily: 'Quicksand',
                fontWeight: FontWeight.bold,
              ),
            ),
            style: ElevatedButton.styleFrom(primary: AppTheme.vinho),
            onPressed: () async {
              Navigator.of(context).pop();
              Uint8List? file = await pickImage(ImageSource.gallery);
              if (file != null) {
                onImageSelected(file);
              }
            },
          ),
        ],
      ),
    );
  }
}
