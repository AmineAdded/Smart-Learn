import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/settings_service.dart';

/// Provider pour gérer la langue de l'application
class LocaleProvider with ChangeNotifier {
  Locale _locale = const Locale('fr');
  final _settingsService = SettingsService();

  Locale get locale => _locale;

  LocaleProvider() {
    _loadLocale();
  }

  /// Charger la langue depuis les préférences locales
  Future<void> _loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final languageCode = prefs.getString('language') ?? 'fr';

    _locale = Locale(languageCode);
    notifyListeners();
  }

  /// Changer la langue ET synchroniser avec le backend
  Future<void> setLocale(String languageCode) async {
    try {
      print('🔵 Changement de langue: $languageCode');

      // 1️⃣ Mettre à jour localement (SharedPreferences)
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('language', languageCode);

      // 2️⃣ Mettre à jour l'état local
      _locale = Locale(languageCode);
      notifyListeners();

      // 3️⃣ Synchroniser avec le backend
      final result = await _settingsService.updateSettings({
        'language': languageCode,
      });

      if (result['success']) {
        print('✅ Langue changée et synchronisée: $languageCode');
      } else {
        print('⚠️ Langue changée localement, mais erreur backend: ${result['message']}');
      }
    } catch (e) {
      print('❌ Erreur changement langue: $e');
      // En cas d'erreur, la langue reste changée localement
    }
  }

  /// Charger la langue depuis le backend (au démarrage)
  Future<void> loadFromBackend() async {
    try {
      final result = await _settingsService.getSettings();

      if (result['success']) {
        final settings = result['settings'];
        final backendLanguage = settings.language;

        if (backendLanguage != _locale.languageCode) {
          print('🔄 Synchronisation langue depuis backend: $backendLanguage');

          // Mettre à jour localement
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('language', backendLanguage);

          _locale = Locale(backendLanguage);
          notifyListeners();
        }
      }
    } catch (e) {
      print('⚠️ Impossible de charger la langue depuis le backend: $e');
    }
  }

  /// Langues supportées
  static const List<Locale> supportedLocales = [
    Locale('fr'), // Français
    Locale('en'), // English
    Locale('ar'), // العربية
  ];
}