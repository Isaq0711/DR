import 'dart:typed_data';
import 'package:dressing_room/resources/firestore_methods.dart';
import 'package:flutter/material.dart';
import 'package:dressing_room/widgets/select_image_dialog.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:dressing_room/utils/colors.dart';
import 'package:gap/gap.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:dressing_room/responsive/mobile_screen_layout.dart';
import 'package:dressing_room/responsive/responsive_layout.dart';
import 'package:dressing_room/utils/utils.dart';

class CreateStoreScreen extends StatefulWidget {
  CreateStoreScreen({Key? key}) : super(key: key);

  @override
  _CreateStoreScreenState createState() => _CreateStoreScreenState();
}

class _CreateStoreScreenState extends State<CreateStoreScreen> {
  final TextEditingController _storenameController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  bool _isLoading = false;
  Uint8List? _image;
  Uint8List? _fotodecapa;

  @override
  void dispose() {
    super.dispose();
    _bioController.dispose();
    _storenameController.dispose();
  }

  void createStoreUser() async {
    setState(() {
      _isLoading = true;
    });

    // CreateStore user using our authmethods
    String res = await FireStoreMethods().createStore(
      _storenameController.text,
      _image!,
      FirebaseAuth.instance.currentUser!.uid,
      _fotodecapa!,
      _bioController.text,
    );
    // if string returned is success, user has been created
    if (res == "success") {
      setState(() {
        _isLoading = false;
      });

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => ResponsiveLayout(
            mobileScreenLayout: MobileScreenLayout(),
          ),
        ),
      );
    } else {
      setState(() {
        _isLoading = false;
      });
      // show the error
      showSnackBar(context, res);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: AppTheme.cinza,
            expandedHeight: 230.h,
            flexibleSpace: FlexibleSpaceBar(
              background: Padding(
                padding: const EdgeInsets.only(bottom: 15),
                child: Stack(children: <Widget>[
                  ClipPath(
                      clipper: OvalBottomClipper(),
                      child: InteractiveViewer(
                        maxScale: 10,
                        child: Image(
                          image: _fotodecapa != null
                              ? MemoryImage(_fotodecapa!)
                              : NetworkImage(
                                  'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRxyM9PAA-XOM8Yv538rJfs5MCBl7_RWIufvoDbkjnC8J4y7Uygcf8i2syt4uc7wa2vOYw&usqp=CAU',
                                ) as ImageProvider,
                          height: 245.h,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      )),
                  Positioned.fill(
                    bottom: 0,
                    child: Align(
                        alignment: AlignmentDirectional.bottomCenter,
                        child: Container(
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border:
                                    Border.all(width: 3, color: AppTheme.cinza),
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                      color: Colors.black54, blurRadius: 15)
                                ]),
                            child: Stack(
                              children: [
                                CircleAvatar(
                                  backgroundColor: Colors.grey,
                                  backgroundImage: _image != null
                                      ? MemoryImage(_image!)
                                      : NetworkImage(
                                          'https://static.vecteezy.com/system/resources/thumbnails/007/033/146/small/profile-icon-login-head-icon-vector.jpg',
                                        ) as ImageProvider,
                                  radius: 45,
                                ),
                                Positioned(
                                  bottom: 0,
                                  left: 45,
                                  child: IconButton(
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return SelectImageRedondaDialog(
                                            onImageSelected: (Uint8List file) {
                                              setState(() {
                                                _image = file;
                                              });
                                            },
                                          );
                                        },
                                      );
                                    },
                                    icon: Icon(
                                      Icons.add_a_photo,
                                      shadows: [
                                        Shadow(
                                          color: AppTheme.nearlyBlack,
                                          blurRadius: 20.0,
                                        ),
                                      ],
                                    ),
                                    color: AppTheme.nearlyWhite,
                                  ),
                                ),
                              ],
                            ))),
                  ),
                  Positioned(
                    left: 300,
                    bottom: 20,
                    child: IconButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return SelectImageCapaDialog(
                              onImageSelected: (Uint8List file) {
                                setState(() {
                                  _fotodecapa = file;
                                });
                              },
                            );
                          },
                        );
                      },
                      icon: Icon(
                        Icons.add_a_photo,
                        size: 35,
                        shadows: [
                          Shadow(
                            color: AppTheme.nearlyBlack,
                            blurRadius: 20.0,
                          ),
                        ],
                      ),
                      color: AppTheme.nearlyWhite,
                    ),
                  )
                ]),
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              Container(
                child: Theme(
                  data: Theme.of(context).copyWith(
                    textSelectionTheme: TextSelectionThemeData(
                      cursorColor: Colors.black,
                    ),
                    textTheme: TextTheme(
                      subtitle1: TextStyle(color: Colors.black),
                    ),
                    inputDecorationTheme: InputDecorationTheme(
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                      ),
                      labelStyle: TextStyle(color: Colors.black),
                      contentPadding: EdgeInsets.all(8),
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Gap(75.h),
                        TextField(
                          controller: _storenameController,
                          decoration: InputDecoration(
                            labelText: 'Nome da sua loja',
                          ),
                          style: AppTheme.dividerfont,
                          maxLines: null,
                          minLines: 1,
                          keyboardType: TextInputType.multiline,
                        ),
                        Gap(25.h),
                        TextField(
                          controller: _bioController,
                          decoration: InputDecoration(
                            labelText: 'Bio para sua loja',
                          ),
                          style: AppTheme.dividerfont,
                          maxLines: null,
                          minLines: 1,
                          keyboardType: TextInputType.multiline,
                        ),
                        Gap(25.h),
                        InkWell(
                          child: Container(
                            child: !_isLoading
                                ? Text(
                                    'CRIAR SUA LOJA',
                                    style: AppTheme.body1white,
                                  )
                                : CircularProgressIndicator(
                                    color: Colors.white,
                                  ),
                            width: double.infinity,
                            alignment: Alignment.center,
                            padding: EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4),
                              color: AppTheme.vinho,
                            ),
                          ),
                          onTap: createStoreUser,
                        ),
                        Gap(12),
                      ],
                    ),
                  ),
                ),
              )
            ]),
          ),
        ],
      ),
    );
  }
}

class OvalBottomClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 25); // Reduzi a altura da curva
    path.quadraticBezierTo(size.width / 2, size.height + 25, size.width,
        size.height - 25); // Ajustei a curva
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return false;
  }
}
