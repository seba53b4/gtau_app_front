import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

Color baseColor = const Color.fromRGBO(200, 217, 184, 0.25);
Color softGrey = const Color.fromRGBO(88, 87, 89, 0.15);
Color scheduledNotInspectionedElement = const Color.fromRGBO(203, 35, 30, 1);
Color scheduledInspectionedElement = const Color.fromRGBO(19, 250, 105, 1);
Color arrowColor = const Color.fromRGBO(247, 247, 247, 1);
Color baseBorderColor = const Color.fromRGBO(200, 217, 184, 1);
Color navColor = const Color.fromRGBO(200, 217, 184, 1);
Color lightBackground = const Color.fromRGBO(253, 255, 252, 1);
Color redColor = const Color.fromRGBO(219, 49, 13, 1);
Color titleColor = const Color.fromRGBO(14, 45, 9, 1);
Color overlayColor = const Color.fromRGBO(161, 180, 156, 0.3568627450980392);
Color sectionDefaultColor = Colors.blueAccent;
Color registerDefaultColor = Colors.deepPurpleAccent;
Color lotDefaultColor = Colors.black38;
Color lotDefaultColorChip = Colors.black45;
Color catchmentDefaultColor = Colors.pink;
Color baseContainerG1 = const Color.fromRGBO(174, 213, 129, 0.25);
Color baseContainerG2 = const Color.fromRGBO(174, 213, 129, 0.30);

MaterialColor primarySwatch = const MaterialColor(
  0xFF60A61B,
  <int, Color>{
    50: Color(0xFFAED581), // Tono 50
    100: Color(0xFF9CCC65), // Tono 100
    200: Color(0xFF8BC34A), // Tono 200
    300: Color(0xFF7CB342), // Tono 300
    400: Color(0xFF689F38), // Tono 400
    500: Color(0xFF60A61B), // Tono 500 (valor principal)
    600: Color(0xFF558B0D), // Tono 600
    700: Color(0xFF4E8C0F), // Tono 700
    800: Color(0xFF447716), // Tono 800
    900: Color(0xFF3C821A), // Tono 900
  },
);

ThemeData defaultTheme = ThemeData(
  primaryColor: baseColor,
  primarySwatch: primarySwatch,
  textTheme: TextTheme(
    titleLarge: GoogleFonts.sora(
      fontSize: 30,
    ),
    titleSmall: GoogleFonts.sora(
      fontSize: 5,
    ),
    bodyMedium: GoogleFonts.sora(
      fontSize: 20,
    ),
    titleMedium: GoogleFonts.sora(
      fontSize: 15,
    ),
    displaySmall: GoogleFonts.sora(
      fontSize: 14,
    ),
    displayMedium: GoogleFonts.sora(
      fontSize: 20,
    ),
    displayLarge: GoogleFonts.sora(
      fontSize: 30,
    ),
    headlineMedium: GoogleFonts.sora(
      fontSize: 16,
    ),
    headlineSmall: GoogleFonts.sora(
      fontSize: 14,
    ),
    bodyLarge: GoogleFonts.sora(
      fontSize: 16,
    ),
    bodySmall: GoogleFonts.sora(
      fontSize: 14,
    ),
  ),
);
