import 'package:flutter/material.dart';

final ThemeData appTheme = ThemeData(
  colorScheme: const ColorScheme(
    primary: Color(0xFF0D1B2A), // Dark Navy
    secondary: Color(0xFF1B263B), // Deep Blue
    background: Color(0xFFE0E1DD), // Soft Gray
    surface: Color(0xFF415A77), // Steel Blue (Used for cards, app bar, etc.)
    onPrimary: Color(0xFFF5F5F5), // Near White text on primary
    onSecondary: Color(0xFFF5F5F5), // Near White text on secondary
    onBackground: Color(0xFF0D1B2A), // Dark Navy text for contrast
    onSurface: Color(0xFFF5F5F5), // Near White text on surface
    error: Color(0xFFB00020), // Standard Material error color (can be changed)
    onError: Color(0xFFFFFFFF), // White text on error
    brightness: Brightness.dark, // Dark mode look
  ),
  useMaterial3: true,
);
