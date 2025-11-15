import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/user_progress.dart';
import '../models/statistics.dart';
import '../models/level_info.dart';
import '../models/add_xp_response.dart';

class ProgressService {
  static final String baseUrl = '${dotenv.env['URL8080']}/api/progress';

  /// Récupérer le token d'authentification
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  /// Headers avec authentification
  Future<Map<String, String>> _getHeaders() async {
    final token = await _getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  /// GET /api/progress - Récupérer le progrès utilisateur
  Future<Map<String, dynamic>> getUserProgress() async {
    try {
      print('🔵 Récupération du progrès utilisateur...');
      print('URL: $baseUrl');

      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse(baseUrl),
        headers: headers,
      );

      print('🔵 Status Code: ${response.statusCode}');
      print('🔵 Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final userProgress = UserProgress.fromJson(data);

        print('✅ Progrès récupéré avec succès');
        return {
          'success': true,
          'data': userProgress,
        };
      } else {
        final error = jsonDecode(response.body);
        print('❌ Erreur: ${error['message']}');
        return {
          'success': false,
          'message': error['message'] ?? 'Erreur lors de la récupération du progrès',
        };
      }
    } catch (e, stackTrace) {
      print('❌ Exception: $e');
      print('Stack trace: $stackTrace');
      return {
        'success': false,
        'message': 'Erreur de connexion au serveur: $e',
      };
    }
  }

  /// GET /api/progress/statistics - Récupérer les statistiques détaillées
  Future<Map<String, dynamic>> getStatistics() async {
    try {
      print('🔵 Récupération des statistiques...');

      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/statistics'),
        headers: headers,
      );

      print('🔵 Status Code: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final statistics = Statistics.fromJson(data);

        print('✅ Statistiques récupérées avec succès');
        return {
          'success': true,
          'data': statistics,
        };
      } else {
        final error = jsonDecode(response.body);
        return {
          'success': false,
          'message': error['message'] ?? 'Erreur lors de la récupération des statistiques',
        };
      }
    } catch (e) {
      print('❌ Exception: $e');
      return {
        'success': false,
        'message': 'Erreur de connexion au serveur: $e',
      };
    }
  }

  /// GET /api/progress/level - Récupérer les informations de niveau
  Future<Map<String, dynamic>> getLevelInfo() async {
    try {
      print('🔵 Récupération des infos de niveau...');

      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/level'),
        headers: headers,
      );

      print('🔵 Status Code: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final levelInfo = LevelInfo.fromJson(data);

        print('✅ Infos de niveau récupérées avec succès');
        return {
          'success': true,
          'data': levelInfo,
        };
      } else {
        final error = jsonDecode(response.body);
        return {
          'success': false,
          'message': error['message'] ?? 'Erreur lors de la récupération du niveau',
        };
      }
    } catch (e) {
      print('❌ Exception: $e');
      return {
        'success': false,
        'message': 'Erreur de connexion au serveur: $e',
      };
    }
  }

  /// GET /api/progress/summary - Récupérer un résumé simple
  Future<Map<String, dynamic>> getProgressSummary() async {
    try {
      print('🔵 Récupération du résumé...');

      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/summary'),
        headers: headers,
      );

      print('🔵 Status Code: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        print('✅ Résumé récupéré avec succès');
        return {
          'success': true,
          'data': data,
        };
      } else {
        final error = jsonDecode(response.body);
        return {
          'success': false,
          'message': error['message'] ?? 'Erreur lors de la récupération du résumé',
        };
      }
    } catch (e) {
      print('❌ Exception: $e');
      return {
        'success': false,
        'message': 'Erreur de connexion au serveur: $e',
      };
    }
  }

  /// GET /api/progress/weekly - Récupérer la progression hebdomadaire
  Future<Map<String, dynamic>> getWeeklyProgress() async {
    try {
      print('🔵 Récupération de la progression hebdomadaire...');

      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/weekly'),
        headers: headers,
      );

      print('🔵 Status Code: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        print('✅ Progression hebdomadaire récupérée');
        return {
          'success': true,
          'data': data,
        };
      } else {
        final error = jsonDecode(response.body);
        return {
          'success': false,
          'message': error['message'] ?? 'Erreur lors de la récupération de la progression',
        };
      }
    } catch (e) {
      print('❌ Exception: $e');
      return {
        'success': false,
        'message': 'Erreur de connexion au serveur: $e',
      };
    }
  }
  /// POST /api/progress/xp - Ajouter des XP à l'utilisateur
  Future<Map<String, dynamic>> addXp({
    required int xpAmount,
    String? reason,
    String? source,
  }) async {
    try {
      print('🔵 Ajout de $xpAmount XP...');

      final headers = await _getHeaders();

      // Construire le body de la requête
      final body = {
        'xpAmount': xpAmount,
        if (reason != null) 'reason': reason,
        if (source != null) 'source': source,
      };

      final response = await http.post(
        Uri.parse('$baseUrl/xp'),
        headers: headers,
        body: jsonEncode(body),
      );

      print('🔵 Status Code: ${response.statusCode}');
      print('🔵 Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final addXpResponse = AddXpResponse.fromJson(data);

        // Afficher un message de succès avec détails
        if (addXpResponse.leveledUp) {
          print('🎉 LEVEL UP ! Nouveau niveau: ${addXpResponse.newLevel}');
        }
        print('✅ XP ajouté avec succès: +${addXpResponse.xpAdded} XP');
        print('   Total XP: ${addXpResponse.totalXp}');
        print('   Niveau: ${addXpResponse.currentLevel} (${addXpResponse.levelTitle})');

        return {
          'success': true,
          'data': addXpResponse,
          'message': addXpResponse.message,
        };
      } else {
        final error = jsonDecode(response.body);
        print('❌ Erreur: ${error['message']}');
        return {
          'success': false,
          'message': error['message'] ?? 'Erreur lors de l\'ajout d\'XP',
        };
      }
    } catch (e, stackTrace) {
      print('❌ Exception: $e');
      print('Stack trace: $stackTrace');
      return {
        'success': false,
        'message': 'Erreur de connexion au serveur: $e',
      };
    }
  }

}