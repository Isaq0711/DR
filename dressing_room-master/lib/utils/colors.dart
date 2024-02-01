import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  AppTheme._();

  static Color nearlyWhite = Color(0xFFDBDBDA);
  static Color white = Color(0xFFFFFFFF);
  static Color nearlyBlack = Color(0xFF213333);
  static Color cinza = Color(0xFFF1F1F1);
  static Color vinho = Color(0xFF6D123F);

  static Color vinhoescuro = Color(0xFF53191F);
  static Color darkText = Color(0xFF253840);
  static Color darkerText = Color(0xFF17262A);
  static Color lightText = Color(0xFF4A6572);
  static Color deactivatedText = Color(0xFF767676);
  static Color dismissibleBackground = Color(0xFF364A54);
  static Color chipBackground = Color(0xFFEEF1F3);
  static Color spacer = Color(0xFFF2F2F2);
  static String fontName = 'Quicksand';
  static String fontName2 = 'Arimo';
  static String fontName3 = 'Bebas Neue';

  static TextStyle barapp = GoogleFonts.getFont(
    fontName3,
    fontWeight: FontWeight.bold,
    fontSize: 20.sp,
    letterSpacing: 0.4,
    color: nearlyBlack,
  );

  static TextStyle barappwhite = GoogleFonts.getFont(
    fontName2,
    fontWeight: FontWeight.w600,
    fontSize: 28,
    letterSpacing: 0.4,
    color: nearlyWhite,
  );

  static TextStyle headline = GoogleFonts.getFont(
    fontName,
    fontWeight: FontWeight.bold,
    fontSize: 24,
    letterSpacing: 0.27,
    color: nearlyBlack,
  );

  static TextStyle headlinevinho = GoogleFonts.getFont(
    fontName2,
    fontWeight: FontWeight.bold,
    fontSize: 23.sp,
    letterSpacing: 0.27,
    color: vinho,
  );

  static TextStyle headlinewhite = GoogleFonts.getFont(
    fontName,
    fontWeight: FontWeight.bold,
    fontSize: 24,
    letterSpacing: 0.27,
    color: nearlyWhite,
  );

  static TextStyle subheadline = GoogleFonts.getFont(
    fontName,
    fontWeight: FontWeight.bold,
    fontSize: 15.sp,
    letterSpacing: 0.18,
    color: nearlyBlack,
  );

  static TextStyle subheadlinevinho = GoogleFonts.getFont(
    fontName,
    fontWeight: FontWeight.bold,
    fontSize: 19,
    letterSpacing: 0.18,
    color: vinho,
  );

  static TextStyle barappvinho = GoogleFonts.getFont(
    fontName2,
    fontWeight: FontWeight.bold,
    fontSize: 25,
    letterSpacing: 0.18,
    color: vinho,
  );

  static TextStyle subheadlinewhite = GoogleFonts.getFont(
    fontName,
    fontWeight: FontWeight.bold,
    fontSize: 19,
    letterSpacing: 0.18,
    color: nearlyWhite,
  );

  static TextStyle title = GoogleFonts.getFont(
    fontName,
    fontWeight: FontWeight.bold,
    fontSize: 10.sp,
    letterSpacing: 0.18,
    color: nearlyBlack,
  );

  static TextStyle titlewhite = GoogleFonts.getFont(
    fontName,
    fontWeight: FontWeight.bold,
    fontSize: 10.sp,
    letterSpacing: 0.18,
    color: nearlyWhite,
  );

  static TextStyle subtitle = GoogleFonts.getFont(
    fontName,
    fontWeight: FontWeight.bold,
    fontSize: 14,
    letterSpacing: -0.04,
    color: nearlyBlack,
  );

  static TextStyle subtitlewhite = GoogleFonts.getFont(
    fontName,
    fontWeight: FontWeight.bold,
    fontSize: 14,
    letterSpacing: -0.04,
    color: nearlyWhite,
  );

  static TextStyle body2 = GoogleFonts.getFont(
    fontName,
    fontWeight: FontWeight.bold,
    fontSize: 14,
    letterSpacing: 0.2,
    color: nearlyBlack,
  );

  static TextStyle body1white = GoogleFonts.getFont(
    fontName,
    fontWeight: FontWeight.bold,
    fontSize: 16,
    letterSpacing: -0.05,
    color: nearlyWhite,
  );

  static TextStyle caption = GoogleFonts.getFont(
    fontName,
    fontWeight: FontWeight.bold,
    fontSize: 12,
    letterSpacing: 0.2,
    color: nearlyBlack,
  );

  static TextStyle dividerfont = GoogleFonts.getFont(
    fontName2,
    fontWeight: FontWeight.w600,
    fontSize: 13,
    letterSpacing: -0.04,
    color: lightText,
  );
}
