import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

Color baseColor = const Color.fromRGBO(200, 217, 184, 0.25);
Color baseBorderColor = const Color.fromRGBO(200, 217, 184, 1);

ThemeData defaultTheme = ThemeData(
  primaryColor: baseColor,
  primarySwatch: Colors.green,
  textTheme: TextTheme(
    displayLarge: const TextStyle(
      fontSize: 68,
      fontWeight: FontWeight.bold,
    ),
    titleLarge: GoogleFonts.sora(
      fontSize: 30,
      fontStyle: FontStyle.italic,
    ),
    titleSmall: GoogleFonts.sora(
      fontSize: 5,
    ),

    bodyMedium: GoogleFonts.merriweather(
      //Ej: Tamaño del titulo PipeTracker en login
      fontSize: 20,
    ),
    //Ej: Tamaño del placeholder 'Nombre de usuario'
    titleMedium: GoogleFonts.sora(
      fontSize: 15,
    ),
    displaySmall: GoogleFonts.sora(),
  ),
);
