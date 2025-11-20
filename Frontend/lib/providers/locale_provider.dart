import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/settings_service.dart';

class LocaleProvider with ChangeNotifier {
  Locale _locale = const Locale('fr');
  final SettingsService _settingsService = SettingsService();

  Locale get locale => _locale;

  LocaleProvider() {
    initLocale();
  }

  /// Chargement au démarrage : priorité locale → backend
  Future<void> initLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLang = prefs.getString('app_language');

    if (savedLang != null && savedLang.isNotEmpty) {
      _locale = Locale(savedLang);
      notifyListeners();
    }
    // On ne charge pas encore le backend ici → fait dans SettingsPage après login
  }

  /// Changer la langue (utilisé dans les paramètres)
  Future<void> setLocale(String languageCode) async {
    if (_locale.languageCode == languageCode) return;

    print('Langue → $languageCode');

    // 1. Mise à jour immédiate de l'UI
    _locale = Locale(languageCode);
    notifyListeners();

    // 2. Sauvegarde locale instantanée (même hors ligne)
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('app_language', languageCode);

    // 3. Synchronisation backend (si connecté)
    try {
      final result = await _settingsService.updateSettings({'language': languageCode});
      if (!result['success']) {
        print('Backend non synchronisé: ${result['message']}');
        // On garde quand même la langue localement → l'utilisateur la verra
      }
    } catch (e) {
      print('Erreur synchronisation backend langue: $e');
    }
  }

  /// Appelée après login pour synchroniser avec le backend
  Future<void> syncWithBackend(String backendLanguage) async {
    if (backendLanguage == _locale.languageCode) return;

    print('Synchronisation locale avec backend: $backendLanguage');

    _locale = Locale(backendLanguage);
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('app_language', backendLanguage);
  }

  /// Langues supportées
  static const List<Locale> supportedLocales = [
    Locale('fr'),
    Locale('en'),
  ];
}