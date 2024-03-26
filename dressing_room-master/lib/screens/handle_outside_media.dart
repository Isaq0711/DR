import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'add_post_screen.dart';
import 'package:flutter/services.dart';
import 'package:dressing_room/utils/colors.dart';
import 'package:gap/gap.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class HandleOutsideMedia extends StatefulWidget {
  @override
  _HandleOutsideMediaState createState() => _HandleOutsideMediaState();
}

class _HandleOutsideMediaState extends State<HandleOutsideMedia> {
  late StreamSubscription _intentSub;
  final TextEditingController urlController = TextEditingController();
  final _sharedFiles = <SharedMediaFile>[];

  @override
  void initState() {
    super.initState();

    _intentSub = ReceiveSharingIntent.getMediaStream().listen((value) {
      if (value.isNotEmpty) {
        setState(() {
          _sharedFiles.clear();
          _sharedFiles.addAll(value);
        });
      }
    }, onError: (err) {
      print("getMediaStream error: $err");
    });

    ReceiveSharingIntent.getInitialMedia().then((value) {
      if (value.isNotEmpty) {
        setState(() {
          _sharedFiles.clear();
          _sharedFiles.addAll(value);
        });
      }
    });
  }

  @override
  void dispose() {
    _intentSub.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isImageUrl(String url) {
      return url.startsWith('http') &&
          (url.endsWith('.png') ||
              url.endsWith('.jpg') ||
              url.endsWith('.jpeg') ||
              url.endsWith('.gif'));
    }

    // void _pasteImageFromClipboard() async {
    //     ClipboardData? clipboardData =
    //         await Clipboard.getData(Clipboard.kDataBitmap);

    //     if (clipboardData != null && clipboardData.bytes != null) {
    //       Uint8List imageData = clipboardData.bytes!;

    //       setState(() {
    //         _sharedFiles.add(SharedMediaFile(
    //           bytes: imageData,
    //           mimeType: 'image/*',
    //           type: SharedMediaType.image,
    //         ));
    //       });
    //     } else {
    //       print('No image data found in clipboard.');
    //     }
    //   }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
            setState(() {
              ReceiveSharingIntent.reset();
            });
          },
          icon: Icon(
            Icons.arrow_back_ios,
            color: AppTheme.nearlyBlack,
          ),
        ),
        actions: _sharedFiles.isNotEmpty
            ? [
                IconButton(
                  onPressed: () {
                    setState(() {
                      _sharedFiles.clear();
                      _intentSub.cancel();
                      ReceiveSharingIntent.reset();
                    });
                  },
                  icon: Icon(
                    Icons.delete,
                    color: AppTheme.vinho,
                  ),
                ),
              ]
            : [],
      ),
      body: (_sharedFiles.isNotEmpty)
          ? Column(
              children: [
                Gap(50.h),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Row(
                    children: [
                      SizedBox(
                        height: 100.h,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.file(File(_sharedFiles[0].path)),
                        ),
                      ),
                      Spacer(), // Adicionando espaço para os botões ficarem na extremidade direita
                      IconButton(
                        onPressed: () {},
                        icon: Icon(
                          Icons.chat_bubble_outline,
                          color: AppTheme.nearlyBlack,
                        ),
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: Icon(Icons.arrow_upward,
                            color: AppTheme.nearlyBlack),
                      ),
                    ],
                  ),
                ),
                Gap(90.h),
                SingleChildScrollView(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GridView.count(
                          shrinkWrap: true,
                          crossAxisCount: 2,
                          padding: EdgeInsets.all(20.0),
                          crossAxisSpacing: 20.h,
                          mainAxisSpacing: 50.h,
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          HandleOutsideMedia()),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.vinho,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    CupertinoIcons.info_circle_fill,
                                    size: 40,
                                    color: AppTheme.nearlyWhite,
                                  ),
                                  Gap(10),
                                  Text(
                                    'Send to I.A.R.A',
                                    style: AppTheme.subheadlinewhite,
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                File imageFile = File(_sharedFiles[0].path);
                                Uint8List imageData =
                                    imageFile.readAsBytesSync();

                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => AddPostScreen(
                                      image: imageData,
                                    ),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.vinho,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.public,
                                    size: 40,
                                    color: AppTheme.nearlyWhite,
                                  ),
                                  Gap(10),
                                  Text(
                                    'Add as Post',
                                    style: AppTheme.subheadlinewhite,
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () {},
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.vinho,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  ImageIcon(
                                    AssetImage('assets/ELECTION.png'),
                                    color: AppTheme.nearlyWhite,
                                    size: 40,
                                  ),
                                  Gap(10),
                                  Text(
                                    'Add as Votation',
                                    style: AppTheme.subheadlinewhite,
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () {},
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.vinho,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    CupertinoIcons.bag_fill,
                                    size: 40,
                                    color: AppTheme.nearlyWhite,
                                  ),
                                  Gap(10),
                                  Text(
                                    'Add as cloth',
                                    style: AppTheme.subheadlinewhite,
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            )
          : GestureDetector(
              //onTap: _pasteImageFromClipboard,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: SizedBox(
                      width: double.infinity,
                      child: Card(
                        margin: EdgeInsets.all(16),
                        color: Colors.white,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.image,
                              color: AppTheme.nearlyBlack,
                            ),
                            SizedBox(height: 15),
                            Text(
                              "Cole sua Imagem aqui",
                              style: AppTheme.subheadline,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
