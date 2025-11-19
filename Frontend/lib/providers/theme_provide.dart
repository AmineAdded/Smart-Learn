import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvide with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  /// Convenience method to set theme from string
  Future<void> setTheme(String themeString) async {
    final themeMode = _stringToThemeMode(themeString);
    setThemeMode(themeMode);
  }

  /// Thème clair avec couleurs cohérentes
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,

    // Couleurs principales
    colorScheme: ColorScheme.light(
      primary: const Color(0xFF5B9FD8),
      secondary: const Color(0xFF6C5CE7),
      tertiary: const Color(0xFFFDB33F),
      error: const Color(0xFFE74C3C),
      surface: Colors.white,
      background: const Color(0xFFF5F6FA),
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: const Color(0xFF2D3436),
      onBackground: const Color(0xFF2D3436),
    ),

    // Scaffold
    scaffoldBackgroundColor: const Color(0xFFF5F6FA),

    // AppBar
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF5B9FD8),
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: Colors.white),
    ),

    // Card
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.05),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),

    // Input
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF5B9FD8), width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE74C3C)),
      ),
    ),

    // Boutons
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF5B9FD8),
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
    ),

    // Text
    textTheme: const TextTheme(
      displayLarge: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF2D3436)),
      displayMedium: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF2D3436)),
      displaySmall: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF2D3436)),
      headlineMedium: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF2D3436)),
      bodyLarge: TextStyle(fontSize: 16, color: Color(0xFF2D3436)),
      bodyMedium: TextStyle(fontSize: 14, color: Color(0xFF636E72)),
      bodySmall: TextStyle(fontSize: 12, color: Color(0xFF636E72)),
    ),
  );

  /// Thème sombre avec couleurs cohérentes
  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,

    // Couleurs principales
    colorScheme: ColorScheme.dark(
      primary: const Color(0xFF5B9FD8),
      secondary: const Color(0xFF6C5CE7),
      tertiary: const Color(0xFFFDB33F),
      error: const Color(0xFFE74C3C),
      surface: const Color(0xFF1E272E),
      background: const Color(0xFF121212),
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: const Color(0xFFE4E6EB),
      onBackground: const Color(0xFFE4E6EB),
    ),

    // Scaffold
    scaffoldBackgroundColor: const Color(0xFF121212),

    // AppBar
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF1E272E),
      foregroundColor: Color(0xFFE4E6EB),
      elevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: Color(0xFFE4E6EB)),
    ),

    // Card
    cardTheme: CardThemeData(
      color: const Color(0xFF1E272E),
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),

    // Input
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF1E272E),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF2F3640)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF2F3640)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF5B9FD8), width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE74C3C)),
      ),
    ),

    // Boutons
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF5B9FD8),
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
    ),

    // Text
    textTheme: const TextTheme(
      displayLarge: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFFE4E6EB)),
      displayMedium: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFFE4E6EB)),
      displaySmall: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFFE4E6EB)),
      headlineMedium: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFFE4E6EB)),
      bodyLarge: TextStyle(fontSize: 16, color: Color(0xFFE4E6EB)),
      bodyMedium: TextStyle(fontSize: 14, color: Color(0xFFB2BEC3)),
      bodySmall: TextStyle(fontSize: 12, color: Color(0xFFB2BEC3)),
    ),
  );

  /// Changer le mode de thème
  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    notifyListeners();
    _saveToBackend();
  }

  /// Charger le thème depuis le backend
  Future<void> loadFromBackend() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        print('⚠️ Pas de token, utilisation du thème par défaut');
        return;
      }

      final response = await http.get(
        Uri.parse('http://localhost:5000/api/settings'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final themeString = data['theme'] ?? 'system';

        _themeMode = _stringToThemeMode(themeString);
        notifyListeners();
        print('✅ Thème chargé: $themeString');
      }
    } catch (e) {
      print('⚠️ Erreur chargement thème: $e');
    }
  }

  /// Sauvegarder le thème vers le backend
  Future<void> _saveToBackend() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) return;

      await http.put(
        Uri.parse('http://localhost:5000/api/settings/theme'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'theme': _themeModeToString(_themeMode),
        }),
      );
    } catch (e) {
      print('⚠️ Erreur sauvegarde thème: $e');
    }
  }

  /// Conversion ThemeMode → String
  String _themeModeToString(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.system:
        return 'system';
    }
  }

  /// Conversion String → ThemeMode
  ThemeMode _stringToThemeMode(String mode) {
    switch (mode) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
      default:
        return ThemeMode.system;
    }
  }
}