import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/user_settings.dart';
import 'auth_service.dart';

class SettingsService {
  static final String baseUrl = '${dotenv.env['URL8080']}/api/settings';
  final _authService = AuthService();

  /// Récupérer les paramètres utilisateur
  Future<Map<String, dynamic>> getSettings() async {
    try {
      print('🔵 Récupération des paramètres...');

      final token = await _authService.getToken();
      if (token == null) {
        return {
          'success': false,
          'message': 'Non authentifié'
        };
      }

      final response = await http.get(
        Uri.parse(baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('🔵 Status Code: ${response.statusCode}');
      print('🔵 Response: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final settings = UserSettings.fromJson(data);

        print('✅ Paramètres récupérés avec succès');
        return {
          'success': true,
          'settings': settings,
        };
      } else {
        final error = json.decode(response.body);
        return {
          'success': false,
          'message': error['message'] ?? 'Erreur lors de la récupération'
        };
      }
    } catch (e) {
      print('❌ Exception: $e');
      return {
        'success': false,
        'message': 'Erreur de connexion au serveur'
      };
    }
  }

  /// Mettre à jour les paramètres
  Future<Map<String, dynamic>> updateSettings(Map<String, dynamic> updates) async {
    try {
      print('🔵 Mise à jour des paramètres...');
      print('Updates: $updates');

      final token = await _authService.getToken();
      if (token == null) {
        return {
          'success': false,
          'message': 'Non authentifié'
        };
      }

      final response = await http.put(
        Uri.parse(baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(updates),
      );

      print('🔵 Status Code: ${response.statusCode}');
      print('🔵 Response: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final settings = UserSettings.fromJson(data);

        print('✅ Paramètres mis à jour avec succès');
        return {
          'success': true,
          'settings': settings,
        };
      } else {
        final error = json.decode(response.body);
        return {
          'success': false,
          'message': error['message'] ?? 'Erreur lors de la mise à jour'
        };
      }
    } catch (e) {
      print('❌ Exception: $e');
      return {
        'success': false,
        'message': 'Erreur de connexion au serveur'
      };
    }
  }

  /// Réinitialiser aux paramètres par défaut
  Future<Map<String, dynamic>> resetSettings() async {
    try {
      print('🔵 Réinitialisation des paramètres...');

      final token = await _authService.getToken();
      if (token == null) {
        return {
          'success': false,
          'message': 'Non authentifié'
        };
      }

      final response = await http.post(
        Uri.parse('$baseUrl/reset'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('🔵 Status Code: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final settings = UserSettings.fromJson(data);

        print('✅ Paramètres réinitialisés');
        return {
          'success': true,
          'settings': settings,
        };
      } else {
        final error = json.decode(response.body);
        return {
          'success': false,
          'message': error['message'] ?? 'Erreur lors de la réinitialisation'
        };
      }
    } catch (e) {
      print('❌ Exception: $e');
      return {
        'success': false,
        'message': 'Erreur de connexion au serveur'
      };
    }
  }
}