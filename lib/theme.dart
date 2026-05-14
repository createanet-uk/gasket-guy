// import 'package:flutter/material.dart';
//
// class AppTheme {
//   // Brand Colors from FlutterFlow Theme
//   static const Color primary = Color(0xFF308ED6);
//   static const Color secondary = Color(0xFF636363);
//   static const Color tertiary = Color(0xFFF59E0B);
//   static const Color alternate = Color(0xFFE5E7EB);
//
//   // Utility Colors
//   static const Color primaryBackground = Color(0xFFF8FAFC);
//   static const Color secondaryBackground = Color(0xFFFFFFFF);
//   static const Color primaryText = Color(0xFF111827);
//   static const Color secondaryText = Color(0xFF6B7280);
//
//   // Accent Colors
//   static const Color accent1 = Color(0xFF4C4B39);
//   static const Color success = Color(0xFF10B981);
//   static const Color error = Color(0xFFEF4444);
//
//   static ThemeData lightTheme = ThemeData(
//     useMaterial3: true,
//     colorScheme: ColorScheme.fromSeed(
//       seedColor: primary,
//       primary: primary,
//       secondary: secondary,
//       surface: primaryBackground,
//       error: error,
//       onPrimary: Colors.white,
//       onSurface: primaryText,
//     ),
//     scaffoldBackgroundColor: primaryBackground,
//     appBarTheme: const AppBarTheme(
//       backgroundColor: secondaryBackground,
//       elevation: 0,
//       centerTitle: true,
//       titleTextStyle: TextStyle(
//         color: primaryText,
//         fontSize: 18,
//         fontWeight: FontWeight.bold,
//       ),
//       iconTheme: IconThemeData(color: primary),
//     ),
//     elevatedButtonTheme: ElevatedButtonThemeData(
//       style: ElevatedButton.styleFrom(
//         backgroundColor: primary,
//         foregroundColor: Colors.white,
//         minimumSize: const Size(double.infinity, 50),
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//         textStyle: const TextStyle(fontWeight: FontWeight.bold),
//       ),
//     ),
//     inputDecorationTheme: InputDecorationTheme(
//       filled: true,
//       fillColor: secondaryBackground,
//       border: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(12),
//         borderSide: const BorderSide(color: alternate),
//       ),
//       enabledBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(12),
//         borderSide: const BorderSide(color: alternate),
//       ),
//     ),
//   );
// }


import 'package:flutter/material.dart';

class AppTheme {
  // Brand Colors from FlutterFlow Theme
  static const Color primary = Color(0xFF308ED6);
  static const Color secondary = Color(0xFF636363);
  static const Color tertiary = Color(0xFFF59E0B);
  static const Color alternate = Color(0xFFE5E7EB);

  // Utility Colors
  static const Color primaryBackground = Color(0xFFF8FAFC);
  static const Color secondaryBackground = Color(0xFFFFFFFF);
  static const Color primaryText = Color(0xFF111827);
  static const Color secondaryText = Color(0xFF6B7280);

  // Accent Colors
  static const Color accent1 = Color(0xFF4C4B39);
  static const Color success = Color(0xFF10B981);
  static const Color error = Color(0xFFEF4444);

  // --- NEW ADDITIONS FOR CYBER DARK MODE METRICS ---
  static const Color darkBackground = Color(0xFF070913);     // Core deep background
  static const Color cardBg = Color(0xFF111625);             // Card base background
  static const Color innerContainerBg = Color(0xFF090D1A);   // Inner content sections
  static const Color cyberCyan = Color(0xFF00E5FF);          // Neon glow element tracker
  static const Color darkBorder = Color(0xFF1F293D);         // Structural borders
  static const Color darkSecondaryText = Color(0xFF94A3B8);  // Slate gray text override

  // --- EXISTING LIGHT MODE ---
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primary,
      primary: primary,
      secondary: secondary,
      surface: primaryBackground,
      error: error,
      onPrimary: Colors.white,
      onSurface: primaryText,
    ),
    scaffoldBackgroundColor: primaryBackground,
    appBarTheme: const AppBarTheme(
      backgroundColor: secondaryBackground,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        color: primaryText,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
      iconTheme: IconThemeData(color: primary),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(fontWeight: FontWeight.bold),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: secondaryBackground,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: alternate),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: alternate),
      ),
    ),
  );

  // --- NEW CUSTOM ENHANCED DARK MODE ---
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: const ColorScheme.dark(
      primary: primary,
      secondary: cyberCyan,
      surface: darkBackground,
      error: error,
      onPrimary: Colors.white,
      onSurface: Colors.white,
    ),
    scaffoldBackgroundColor: darkBackground,
    appBarTheme: const AppBarTheme(
      backgroundColor: cardBg,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
      iconTheme: IconThemeData(color: cyberCyan),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(fontWeight: FontWeight.bold),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: innerContainerBg,
      labelStyle: const TextStyle(color: darkSecondaryText),
      hintStyle: TextStyle(color: darkSecondaryText.withOpacity(0.5)),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: darkBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: darkBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: cyberCyan, width: 1.5),
      ),
    ),
  );
}