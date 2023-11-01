import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dressing_room/utils/colors.dart';
import 'package:dressing_room/utils/utils.dart';
import 'package:dressing_room/resources/storage_methods.dart';

class EditProfileScreen extends StatefulWidget {
 final String uid;
 const EditProfileScreen({Key? key, required this.uid}) : super(key: key);

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  var userData = {};
  final TextEditingController _usernameController = TextEditingController();
  Uint8List? _image;
  bool isLoading = false;
  bool _isEditing = false;

  @override
void initState() {
  super.initState();
  getData();
}

  getData() async {
    setState(() {
      isLoading = true;
    });
    try {
      var userSnap = await FirebaseFirestore.instance.collection('users').doc(widget.uid).get();

      userData = userSnap.data()!;
    
      setState(() {});
    } catch (e) {
      showSnackBar(
        context,
        e.toString(),
      );
    }
    setState(() {
      isLoading = false;
    });
  }

  selectImage() async {
    final pickedImage =
        await ImagePicker().getImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      final croppedImage = await ImageCropper().cropImage(
        sourcePath: pickedImage.path,
        aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1),
        compressQuality: 70,
        maxWidth: 80,
        maxHeight: 80,
        compressFormat: ImageCompressFormat.jpg,
        androidUiSettings: AndroidUiSettings(
          toolbarColor: Colors.white,
          toolbarTitle: "Crop Image",
          statusBarColor: Colors.black,
          backgroundColor: Colors.white,
        ),
      );
      if (croppedImage != null) {
        setState(() {
          _image = croppedImage.readAsBytesSync();
        });
      }
    }
  }
void fetchUserData() async {
  
  DocumentSnapshot userSnapshot = await FirebaseFirestore.instance.collection('users').doc(widget.uid).get();

    setState(() {
      _image =  userData['photoUrl']; 
      _usernameController.text = userData['username']; 
    });
  
}
  void saveChanges() async {
   
    String newUsername = _usernameController.text;
    Uint8List? newImage = _image;

 if (_usernameController.text != "") {
 await FirebaseFirestore.instance
      .collection('users')
      .doc(widget.uid)
      .update({'username': newUsername});
 }

  if (_image != null) {
     if (_image != null) {
    String downloadUrl = await StorageMethods().uploadImageToStorage('profilePics', _image!, false);

    await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.uid)
        .update({'photoUrl': downloadUrl});
  }
  }
    Navigator.pop(context);
  }


  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const Center(
            child: CircularProgressIndicator(),
          )
        : 
     Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile', style: AppTheme.headlinewhite),
        backgroundColor: AppTheme.vinho,
        actions: [
          IconButton(
            onPressed: saveChanges,
            icon: const Icon(Icons.save),
          ),
        ],
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
         GestureDetector(
  onTap: selectImage,
  child: Stack(
    children: [
      _image != null
        ? CircleAvatar(
          radius: 64,
          backgroundImage: MemoryImage(_image!),
          backgroundColor: Colors.grey,
        )
        : CircleAvatar(
          backgroundColor: Colors.grey,
          backgroundImage: NetworkImage(userData['photoUrl']),
          radius: 64,
        ),
      Positioned(
        bottom: 0,
        right: 0,
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppTheme.vinho,
          ),
          padding: const EdgeInsets.all(8.0),
          child: Icon(
            Icons.edit,
            color: AppTheme.nearlyWhite,
          ),
        ),
      ),
    ],
  ),
),
             const SizedBox(height: 45),
   Row(
    mainAxisAlignment: MainAxisAlignment.center,
  children: [
    if (_isEditing)
      Expanded(
        child: TextField(
          controller: _usernameController,
          decoration: InputDecoration(
            labelText: "Type new Username",
            labelStyle: AppTheme.title,
            hintStyle: AppTheme.title,
          
          ),
          style: TextStyle(color: Colors.black), 
        ),
      )
    else
     Text(
            userData['username'],
            style: AppTheme.subheadline,
          ),
      
    SizedBox(width: 15),
    IconButton(
      onPressed: () {
        setState(() {
          _isEditing = true;
        });
      },
      icon: Icon(
        Icons.edit,
        color: AppTheme.nearlyBlack,
      ),
    ),
  ],
),
               
  
          ],
        ),
      ),
    );
  }
}