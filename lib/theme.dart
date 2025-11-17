import 'package:flutter/material.dart';

class OtsuColor {
  static const Color background = Color(0xFFFAFBFD); 
  static const Color primaryYellow = Color(0xFFFDEB93); 
  static const Color accentBlue = Color(0xFFA9E4F7);   
  static const Color darkBlue = Color(0xFF3D405B);     
  static const Color grey = Color(0xFF8D99AE);
}

ThemeData buildTheme() {
  return ThemeData(
    primaryColor: OtsuColor.primaryYellow,
    scaffoldBackgroundColor: OtsuColor.background,
    
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: const BorderSide(color: OtsuColor.darkBlue, width: 2.0),
      ),
      labelStyle: const TextStyle(color: OtsuColor.grey),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: OtsuColor.darkBlue,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    ),
    
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: OtsuColor.darkBlue,
        textStyle: const TextStyle(fontWeight: FontWeight.bold),
      ),
    ),
  );
}