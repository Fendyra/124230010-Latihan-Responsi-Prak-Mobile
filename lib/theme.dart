import 'package:flutter/material.dart';

class OtsuColor {
  static const Color background = Color(0xFFFBF3E6);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color primary = Color(0xFF3D405B);
  static const Color secondary = Color(0xFFA9E4F7);
  static const Color accent = Color(0xFFFDEB93);
  static const Color text = Color(0xFF3D405B);
  static const Color grey = Color(0xFF8D99AE);
}

ThemeData buildTheme() {
  final baseTheme = ThemeData.light(useMaterial3: true);
  
  return baseTheme.copyWith(
    primaryColor: OtsuColor.primary,
    scaffoldBackgroundColor: OtsuColor.background,

    appBarTheme: const AppBarTheme(
      backgroundColor: OtsuColor.background,
      elevation: 0,
      scrolledUnderElevation: 0,
      iconTheme: IconThemeData(color: OtsuColor.primary),
      titleTextStyle: TextStyle(
        color: OtsuColor.primary,
        fontSize: 20,
        fontWeight: FontWeight.bold,
        fontFamily: 'Poppins',
      ),
    ),

    // cardTheme: CardTheme(
    //   color: OtsuColor.surface,
    //   elevation: 2,
    //   shadowColor: OtsuColor.grey.withOpacity(0.1),
    //   shape: RoundedRectangleBorder(
    //     borderRadius: BorderRadius.circular(16.0),
    //   ),
    //   margin: const EdgeInsets.symmetric(horizontal: 16.0),
    // ),
    
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: OtsuColor.background.withOpacity(0.5),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide(color: OtsuColor.grey.withOpacity(0.3)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: const BorderSide(color: OtsuColor.primary, width: 2.0),
      ),
      labelStyle: const TextStyle(color: OtsuColor.grey),
      hintStyle: const TextStyle(color: OtsuColor.grey),
      prefixIconColor: WidgetStateColor.resolveWith(
        (states) => states.contains(WidgetState.focused) ? OtsuColor.primary : OtsuColor.grey,
      ),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: OtsuColor.primary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        padding: const EdgeInsets.symmetric(vertical: 18.0),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
    
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: OtsuColor.primary,
        textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
    ),

    textTheme: baseTheme.textTheme.apply(
      bodyColor: OtsuColor.text,
      displayColor: OtsuColor.primary,
    ).copyWith(
      displaySmall: baseTheme.textTheme.displaySmall?.copyWith(
        color: OtsuColor.primary,
        fontWeight: FontWeight.bold,
        fontSize: 28,
      ),
      titleMedium: baseTheme.textTheme.titleMedium?.copyWith(
        color: OtsuColor.grey,
        fontSize: 16,
      ),
      bodyMedium: baseTheme.textTheme.bodyMedium?.copyWith(
        color: OtsuColor.grey,
        fontSize: 16,
      ),
    ),
  );
}
