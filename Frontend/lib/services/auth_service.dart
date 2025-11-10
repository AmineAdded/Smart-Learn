import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';


class AuthService {
  // Changez cette URL selon votre configuration
  static final String baseUrl = '${dotenv.env['URL8080']}/api/auth'; // Pour émulateur Android
  // static const String baseUrl = 'http://localhost:8080/api/auth'; // Pour iOS Simulator
  // static const String baseUrl = 'http://YOUR_IP:8080/api/auth'; // Pour appareil physique

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

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        // Sauvegarder le token et les informations utilisateur
        await _saveUserData(data);
        return {'success': true, 'data': data};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Erreur lors de l\'inscription'
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Erreur de connexion au serveur: $e'
      };
    }
  }

  /// Connexion d'un utilisateur
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        // Sauvegarder le token et les informations utilisateur
        await _saveUserData(data);
        return {'success': true, 'data': data};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Email ou mot de passe incorrect'
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Erreur de connexion au serveur: $e'
      };
    }
  }

  /// Sauvegarder les données utilisateur localement
  Future<void> _saveUserData(Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(tokenKey, data['token']);
    await prefs.setInt(userIdKey, data['id']);
    await prefs.setString(userEmailKey, data['email']);
    await prefs.setString(userNomKey, data['nom']);
    await prefs.setString(userPrenomKey, data['prenom']);
    await prefs.setString(userNiveauKey, data['niveau']);
    await prefs.setString(userRoleKey, data['role']);
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
  }
}