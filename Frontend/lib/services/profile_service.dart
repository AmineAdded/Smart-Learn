import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/profile_model.dart';
import 'auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service pour gérer toutes les opérations liées au profil utilisateur
/// Utilise async/await pour les appels réseau
class ProfileService {
  // URL de base de l'API
  static final String baseUrl = '${dotenv.env['URL8080']}/api/profile';

  // Instance du service d'authentification pour récupérer le token
  final _authService = AuthService();

  /// Récupérer le profil de l'utilisateur connecté
  /// Future : représente une valeur qui sera disponible dans le futur
  /// async : permet d'utiliser await dans la fonction
  /// await : attend que l'opération asynchrone se termine
  Future<Map<String, dynamic>> getProfile() async {
    try {
      print('🔵 Récupération du profil...');

      // Récupérer le token d'authentification
      final token = await _authService.getToken();

      if (token == null) {
        return {
          'success': false,
          'message': 'Non authentifié. Veuillez vous reconnecter.'
        };
      }

      // Faire la requête GET vers le serveur
      final response = await http.get(
        Uri.parse(baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token', // Envoyer le token
        },
      );

      print('🔵 Status Code: ${response.statusCode}');
      print('🔵 Response Body: ${response.body}');

      if (response.statusCode == 200) {
        // json.decode : convertit le JSON en Map
        final data = json.decode(response.body);

        // Créer un ProfileModel à partir du JSON
        final profile = ProfileModel.fromJson(data);

        print('✅ Profil récupéré avec succès');
        return {
          'success': true,
          'profile': profile, // Retourner le ProfileModel
        };
      } else {
        final error = json.decode(response.body);
        return {
          'success': false,
          'message': error['message'] ?? 'Erreur lors de la récupération du profil'
        };
      }
    } catch (e, stackTrace) {
      print('❌ Exception: $e');
      print('Stack trace: $stackTrace');
      return {
        'success': false,
        'message': 'Erreur de connexion au serveur'
      };
    }
  }

  /// Mettre à jour le profil de l'utilisateur
  Future<Map<String, dynamic>> updateProfile({
    required String nom,
    required String prenom,
    required String email,
    required String niveau,
  }) async {
    try {
      print('🔵 Mise à jour du profil...');

      final token = await _authService.getToken();

      if (token == null) {
        return {
          'success': false,
          'message': 'Non authentifié. Veuillez vous reconnecter.'
        };
      }

      // Faire la requête PUT vers le serveur
      final response = await http.put(
        Uri.parse(baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        // json.encode : convertit le Map en JSON
        body: json.encode({
          'nom': nom,
          'prenom': prenom,
          'email': email,
          'niveau': niveau,
        }),
      );

      print('🔵 Status Code: ${response.statusCode}');
      print('🔵 Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final profile = ProfileModel.fromJson(data);

        // Mettre à jour les données locales (SharedPreferences)
        await _updateLocalUserData(profile);

        print('✅ Profil mis à jour avec succès');
        return {
          'success': true,
          'profile': profile,
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

  /// Changer le mot de passe
  Future<Map<String, dynamic>> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    try {
      print('🔵 Changement de mot de passe...');

      final token = await _authService.getToken();

      if (token == null) {
        return {
          'success': false,
          'message': 'Non authentifié. Veuillez vous reconnecter.'
        };
      }

      final response = await http.put(
        Uri.parse('$baseUrl/password'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'oldPassword': oldPassword,
          'newPassword': newPassword,
        }),
      );

      print('🔵 Status Code: ${response.statusCode}');

      if (response.statusCode == 200) {
        print('✅ Mot de passe changé avec succès');
        return {
          'success': true,
          'message': 'Mot de passe modifié avec succès'
        };
      } else {
        final error = json.decode(response.body);
        return {
          'success': false,
          'message': error['message'] ?? 'Erreur lors du changement de mot de passe'
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

  /// Mettre à jour les données utilisateur localement (SharedPreferences)
  Future<void> _updateLocalUserData(ProfileModel profile) async {
    // Cette méthode utilise le service d'authentification
    // qui gère déjà le SharedPreferences
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(AuthService.userNomKey, profile.nom);
    await prefs.setString(AuthService.userPrenomKey, profile.prenom);
    await prefs.setString(AuthService.userEmailKey, profile.email);
    await prefs.setString(AuthService.userNiveauKey, profile.niveau);

    print('✅ Données locales mises à jour');
  }
}