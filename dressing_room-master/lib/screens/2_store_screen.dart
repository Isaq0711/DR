import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'dart:ui' as ui;
import 'package:dressing_room/utils/utils.dart';
import 'dart:typed_data';
import 'package:flutter/rendering.dart';
import 'package:dressing_room/utils/colors.dart';

import 'package:gap/gap.dart';

class WebViewPage extends StatefulWidget {
  final Function(Uint8List) onImageCaptured;

  WebViewPage({required this.onImageCaptured});

  @override
  _WebViewPageState createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebViewPage> {
  late WebViewController _webViewController;
  final GlobalKey _repaintKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.transparent)
      ..loadRequest(Uri.parse('https://www.google.com'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
        title: Text(
          "Imagem da web",
          style: AppTheme.barapp.copyWith(
            shadows: [
              Shadow(
                blurRadius: 2.0,
                color: Colors.black,
              ),
            ],
          ),
        ),
        centerTitle: true,
      ),
      body: RepaintBoundary(
        key: _repaintKey,
        child: WebViewWidget(controller: _webViewController),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        color: Colors.transparent,
        shape: CircularNotchedRectangle(),
        notchMargin: 6.0,
        child: InkWell(
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(
                Icons.camera_alt,
                color: AppTheme.nearlyBlack,
                shadows: [
                  Shadow(
                    blurRadius: 1.5,
                    color: Colors.black,
                  )
                ],
              ),
              Gap(10),
              Text(
                "Capturar Tela",
                style: AppTheme.barapp.copyWith(
                  shadows: [
                    Shadow(
                      blurRadius: 2.0,
                      color: Colors.black,
                    ),
                  ],
                ),
              ),
            ],
          ),
          onTap: _takeScreenshot,
        ),
      ),
    );
  }

  void _takeScreenshot() async {
    try {
      RenderRepaintBoundary boundary = _repaintKey.currentContext!
          .findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 1.0);
      ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      Uint8List pngBytes = byteData!.buffer.asUint8List();

      Uint8List? croppedImage = await pickImage1por1(imageData: pngBytes);

      if (croppedImage != null) {
        widget.onImageCaptured(croppedImage);
      }
    } catch (e) {
      print(e);
    }
  }
}
