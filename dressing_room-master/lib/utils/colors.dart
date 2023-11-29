import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  static const Color notWhite = Color(0xFFEDF0F2);
  static const Color nearlyWhite = Color(0xFFDBDBDA);
  static const Color white = Color(0xFFFFFFFF);
  static const Color nearlyBlack = Color(0xFF213333);
  static const Color cinza = Color(0xFFB1B2B3);
  static const Color vinho = Color(0xFF6D123F);
  static const Color vinhoescuro = Color(0xFF53191F);
  static const Color darkText = Color(0xFF253840);
  static const Color darkerText = Color(0xFF17262A);
  static const Color lightText = Color(0xFF4A6572);
  static const Color deactivatedText = Color(0xFF767676);
  static const Color dismissibleBackground = Color(0xFF364A54);
  static const Color chipBackground = Color(0xFFEEF1F3);
  static const Color spacer = Color(0xFFF2F2F2);
  static const String fontName = 'Quicksand';
  static const String fontName2 = 'Arimo';

  static const TextTheme textTheme = TextTheme(
    headline4: display1,
    headline5: headline,
    headline6: title,
    subtitle2: subtitle,
    bodyText2: body2,
    bodyText1: body1,
    caption: caption,
  );

  static const TextStyle display1 = TextStyle(
    // h4 -> display1
    fontFamily: fontName,
    fontWeight: FontWeight.bold,
    fontSize: 36,
    letterSpacing: 0.4,
    height: 0.9,
    color: nearlyBlack,
  );
  static const TextStyle barapp = TextStyle(
    fontFamily: fontName2,
    fontWeight: FontWeight.w600,
    fontSize: 26,
    letterSpacing: 0.4,
    color: vinho,
  );
  static const TextStyle barappwhite = TextStyle(
    fontFamily: fontName2,
    fontWeight: FontWeight.w600,
    fontSize: 28,
    letterSpacing: 0.4,
    color: nearlyWhite,
  );

  static const TextStyle headline = TextStyle(
    // h5 -> headline
    fontFamily: fontName,
    fontWeight: FontWeight.bold,
    fontSize: 24,
    letterSpacing: 0.27,
    color: nearlyBlack,
  );
  static const TextStyle headlinewhite = TextStyle(
    // h5 -> headline
    fontFamily: fontName,
    fontWeight: FontWeight.bold,
    fontSize: 24,
    letterSpacing: 0.27,
    color: nearlyWhite,
  );

  static const TextStyle subheadline = TextStyle(
    fontFamily: fontName,
    fontWeight: FontWeight.bold,
    fontSize: 19,
    letterSpacing: 0.18,
    color: nearlyBlack,
  );
  static const TextStyle subheadlinevinho = TextStyle(
    fontFamily: fontName2,
    fontWeight: FontWeight.bold,
    fontSize: 19,
    letterSpacing: 0.18,
    color: vinho,
  );

  static const TextStyle barappvinho = TextStyle(
    fontFamily: fontName2,
    fontWeight: FontWeight.bold,
    fontSize: 25,
    letterSpacing: 0.18,
    color: vinho,
  );
  static const TextStyle subheadlinewhite = TextStyle(
    fontFamily: fontName,
    fontWeight: FontWeight.bold,
    fontSize: 19,
    letterSpacing: 0.18,
    color: nearlyWhite,
  );
  static const TextStyle title = TextStyle(
    // h6 -> title
    fontFamily: fontName,
    fontWeight: FontWeight.bold,
    fontSize: 16,
    letterSpacing: 0.18,
    color: nearlyBlack,
  );
  static const TextStyle titlewhite = TextStyle(
    // h6 -> title
    fontFamily: fontName,
    fontWeight: FontWeight.bold,
    fontSize: 16,
    letterSpacing: 0.18,
    color: nearlyWhite,
  );

  static const TextStyle subtitle = TextStyle(
    // subtitle2 -> subtitle
    fontFamily: fontName,
    fontWeight: FontWeight.bold,
    fontSize: 14,
    letterSpacing: -0.04,
    color: nearlyBlack,
  );

  static const TextStyle subtitlewhite = TextStyle(
    // subtitle2 -> subtitle
    fontFamily: fontName,
    fontWeight: FontWeight.bold,
    fontSize: 14,
    letterSpacing: -0.04,
    color: nearlyWhite,
  );

  static const TextStyle body2 = TextStyle(
    // body1 -> body2
    fontFamily: fontName,
    fontWeight: FontWeight.bold,
    fontSize: 14,
    letterSpacing: 0.2,
    color: nearlyBlack,
  );

  static const TextStyle body1 = TextStyle(
    // body2 -> body1
    fontFamily: fontName,
    fontWeight: FontWeight.bold,
    fontSize: 16,
    letterSpacing: -0.05,
    color: nearlyBlack,
  );
  static const TextStyle body1white = TextStyle(
    // body2 -> body1
    fontFamily: fontName,
    fontWeight: FontWeight.bold,
    fontSize: 16,
    letterSpacing: -0.05,
    color: nearlyWhite,
  );

  static const TextStyle caption = TextStyle(
    // Caption -> caption
    fontFamily: fontName,
    fontWeight: FontWeight.bold,
    fontSize: 12,
    letterSpacing: 0.2,
    color: nearlyBlack,
  );
}
