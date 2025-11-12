import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AuthService {
  // Changez cette URL selon votre configuration
  static final String baseUrl = '${dotenv.env['URL8080']}/api/auth';

  // Clés pour SharedPreferences
  static const String tokenKey = 'auth_token';
  static const String userIdKey = 'user_id';
  static const String userEmailKey = 'user_email';
  static const String userNomKey = 'user_nom';
  static const String userPrenomKey = 'user_prenom';
  static const String userNiveauKey = 'user_niveau';
  static const String userRoleKey = 'user_role';

  /// Inscription d'un nouvel utilisateur
  Future<Map<String, dynamic>> signUp({
    required String nom,
    required String prenom,
    required String email,
    required String password,
    required String niveau,
  }) async {
    try {
      print('🔵 Tentative d\'inscription...');
      print('URL: $baseUrl/signup');

      final response = await http.post(
        Uri.parse('$baseUrl/signup'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'nom': nom,
          'prenom': prenom,
          'email': email,
          'password': password,
          'niveau': niveau,
        }),
      );

      print('🔵 Status Code: ${response.statusCode}');
      print('🔵 Response Body: ${response.body}');

      // Vérifier si la réponse est vide
      if (response.body.isEmpty) {
        print('⚠️ Réponse vide du serveur');
        return {
          'success': false,
          'message': 'Le serveur a retourné une réponse vide'
        };
      }

      final data = jsonDecode(response.body);
      print('🔵 Data décodée: $data');

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Vérifier si le token existe dans la réponse
        if (data['token'] == null) {
          print('⚠️ Token manquant dans la réponse');
          return {
            'success': false,
            'message': 'Erreur serveur: token manquant'
          };
        }

        // Sauvegarder le token et les informations utilisateur
        await _saveUserData(data);
        print('✅ Inscription réussie !');

        return {'success': true, 'data': data};
      } else {
        print('❌ Erreur: ${data['message']}');
        return {
          'success': false,
          'message': data['message'] ?? 'Erreur lors de l\'inscription'
        };
      }
    } catch (e, stackTrace) {
      print('❌ Exception lors de l\'inscription: $e');
      print('Stack trace: $stackTrace');

      return {
        'success': false,
        'message': 'Erreur de connexion au serveur. Vérifiez votre connexion Internet.'
      };
    }
  }

  /// Connexion d'un utilisateur
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      print('🔵 Tentative de connexion...');
      print('URL: $baseUrl/login');

      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      print('🔵 Status Code: ${response.statusCode}');
      print('🔵 Response Body: ${response.body}');

      // Vérifier si la réponse est vide
      if (response.body.isEmpty) {
        print('⚠️ Réponse vide du serveur');
        return {
          'success': false,
          'message': 'Le serveur a retourné une réponse vide'
        };
      }

      final data = jsonDecode(response.body);
      print('🔵 Data décodée: $data');

      if (response.statusCode == 200) {
        // Vérifier si le token existe dans la réponse
        if (data['token'] == null) {
          print('⚠️ Token manquant dans la réponse');
          return {
            'success': false,
            'message': 'Erreur serveur: token manquant'
          };
        }

        // Sauvegarder le token et les informations utilisateur
        await _saveUserData(data);
        print('✅ Connexion réussie !');

        return {'success': true, 'data': data};
      } else {
        print('❌ Erreur: ${data['message']}');
        return {
          'success': false,
          'message': data['message'] ?? 'Email ou mot de passe incorrect'
        };
      }
    } catch (e, stackTrace) {
      print('❌ Exception lors de la connexion: $e');
      print('Stack trace: $stackTrace');

      return {
        'success': false,
        'message': 'Erreur de connexion au serveur. Vérifiez votre connexion Internet.'
      };
    }
  }

  /// Sauvegarder les données utilisateur localement
  Future<void> _saveUserData(Map<String, dynamic> data) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      print('💾 Sauvegarde des données utilisateur...');

      // Sauvegarder le token (obligatoire)
      if (data['token'] != null) {
        await prefs.setString(tokenKey, data['token']);
        print('✅ Token sauvegardé');
      }

      // Sauvegarder l'ID (avec gestion du type)
      if (data['id'] != null) {
        if (data['id'] is int) {
          await prefs.setInt(userIdKey, data['id']);
        } else if (data['id'] is String) {
          await prefs.setInt(userIdKey, int.parse(data['id']));
        }
        print('✅ ID sauvegardé: ${data['id']}');
      }

      // Sauvegarder les autres informations
      if (data['email'] != null) {
        await prefs.setString(userEmailKey, data['email']);
        print('✅ Email sauvegardé: ${data['email']}');
      }

      if (data['nom'] != null) {
        await prefs.setString(userNomKey, data['nom']);
        print('✅ Nom sauvegardé: ${data['nom']}');
      }

      if (data['prenom'] != null) {
        await prefs.setString(userPrenomKey, data['prenom']);
        print('✅ Prénom sauvegardé: ${data['prenom']}');
      }

      if (data['niveau'] != null) {
        await prefs.setString(userNiveauKey, data['niveau']);
        print('✅ Niveau sauvegardé: ${data['niveau']}');
      }

      if (data['role'] != null) {
        await prefs.setString(userRoleKey, data['role']);
        print('✅ Role sauvegardé: ${data['role']}');
      }

      print('✅ Toutes les données ont été sauvegardées');
    } catch (e) {
      print('❌ Erreur lors de la sauvegarde: $e');
      rethrow;
    }
  }

  /// Récupérer le token stocké
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(tokenKey);
  }

  /// Vérifier si l'utilisateur est connecté
  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  /// Récupérer les informations de l'utilisateur courant
  Future<Map<String, dynamic>?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(tokenKey);

    if (token == null) return null;

    return {
      'id': prefs.getInt(userIdKey),
      'email': prefs.getString(userEmailKey),
      'nom': prefs.getString(userNomKey),
      'prenom': prefs.getString(userPrenomKey),
      'niveau': prefs.getString(userNiveauKey),
      'role': prefs.getString(userRoleKey),
    };
  }

  /// Récupérer le profil depuis le serveur
  Future<Map<String, dynamic>> getProfile() async {
    try {
      final token = await getToken();

      if (token == null) {
        return {'success': false, 'message': 'Non authentifié'};
      }

      final response = await http.get(
        Uri.parse('$baseUrl/me'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {'success': true, 'data': data};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Erreur lors de la récupération du profil'
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Erreur de connexion au serveur: $e'
      };
    }
  }

  /// Déconnexion
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    print('✅ Utilisateur déconnecté');
  }
}