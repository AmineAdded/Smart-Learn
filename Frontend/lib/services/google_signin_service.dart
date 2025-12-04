import 'dart:convert';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class GoogleSignInService {
  static final String baseUrl = '${dotenv.env['URL8080']}/api/auth';

  // ✅ IMPORTANT : Remplacez par votre Client ID Web depuis Google Cloud Console
  // Format : XXXXXXXXXX-XXXXXXXXXXXXXXXXXXXXXXXX.apps.googleusercontent.com
  static const String webClientId = '14608898390-f7s3uvqnoqn5nqdhjr29imla26erq8ot.apps.googleusercontent.com';

  late final GoogleSignIn _googleSignIn;

  GoogleSignInService() {
    _googleSignIn = GoogleSignIn(
      scopes: [
        'email',
        'profile',
      ],
      // ✅ serverClientId est OBLIGATOIRE pour obtenir l'idToken
      serverClientId: webClientId,
    );
  }

  /// Se connecter avec Google
  Future<Map<String, dynamic>> signInWithGoogle() async {
    try {
      print('🔵 Démarrage de la connexion Google...');

      // Vérifier si déjà connecté
      if (await _googleSignIn.isSignedIn()) {
        print('⚠️ Utilisateur déjà connecté, déconnexion...');
        await _googleSignIn.signOut();
      }

      // Se connecter avec Google
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        print('⚠️ Connexion Google annulée par l\'utilisateur');
        return {
          'success': false,
          'message': 'Connexion annulée'
        };
      }

      print('✅ Utilisateur Google connecté: ${googleUser.email}');
      print('Nom: ${googleUser.displayName}');

      // Récupérer les tokens d'authentification
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final String? idToken = googleAuth.idToken;
      final String? accessToken = googleAuth.accessToken;

      print('ID Token présent: ${idToken != null}');
      print('Access Token présent: ${accessToken != null}');

      if (idToken == null) {
        print('❌ Impossible de récupérer l\'ID token');
        print('Vérifiez que serverClientId est bien configuré dans GoogleSignIn');
        return {
          'success': false,
          'message': 'Erreur: ID token manquant. Vérifiez la configuration Google Sign-In.'
        };
      }

      print('✅ ID Token récupéré (longueur: ${idToken.length})');

      // Envoyer le token au backend
      return await _authenticateWithBackend(idToken);

    } catch (e, stackTrace) {
      print('❌ Erreur lors de la connexion Google: $e');
      print('Stack trace: $stackTrace');

      String errorMessage = 'Erreur lors de la connexion avec Google';

      if (e.toString().contains('network')) {
        errorMessage = 'Erreur de connexion. Vérifiez votre connexion Internet.';
      } else if (e.toString().contains('DEVELOPER_ERROR')) {
        errorMessage = 'Erreur de configuration. Vérifiez le Client ID et le SHA-1.';
      }

      return {
        'success': false,
        'message': errorMessage
      };
    }
  }

  /// Envoyer le token Google au backend
  Future<Map<String, dynamic>> _authenticateWithBackend(String idToken) async {
    try {
      print('🔵 Envoi du token au backend...');
      print('URL: $baseUrl/google');
      print('Token (premiers 50 caractères): ${idToken.substring(0, 50)}...');

      final response = await http.post(
        Uri.parse('$baseUrl/google'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'idToken': idToken,
        }),
      ).timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          throw Exception('Timeout: Le serveur ne répond pas');
        },
      );

      print('🔵 Status Code: ${response.statusCode}');
      print('🔵 Response Body: ${response.body}');

      if (response.body.isEmpty) {
        return {
          'success': false,
          'message': 'Le serveur a retourné une réponse vide'
        };
      }

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        if (data['token'] == null) {
          return {
            'success': false,
            'message': 'Erreur serveur: token manquant dans la réponse'
          };
        }

        // Sauvegarder les données utilisateur
        await _saveUserData(data);
        print('✅ Authentification Google réussie !');

        return {'success': true, 'data': data};
      } else {
        print('❌ Erreur backend: ${data['message']}');
        return {
          'success': false,
          'message': data['message'] ?? 'Erreur lors de l\'authentification avec le serveur'
        };
      }
    } catch (e) {
      print('❌ Erreur lors de l\'authentification backend: $e');

      String errorMessage = 'Erreur de connexion au serveur';
      if (e.toString().contains('Timeout')) {
        errorMessage = 'Le serveur ne répond pas. Vérifiez qu\'il est démarré.';
      } else if (e.toString().contains('SocketException')) {
        errorMessage = 'Impossible de contacter le serveur. Vérifiez l\'URL.';
      }

      return {
        'success': false,
        'message': errorMessage
      };
    }
  }

  /// Sauvegarder les données utilisateur
  Future<void> _saveUserData(Map<String, dynamic> data) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      print('💾 Sauvegarde des données utilisateur...');

      if (data['token'] != null) {
        await prefs.setString('auth_token', data['token']);
        print('✅ Token sauvegardé');
      }

      if (data['id'] != null) {
        if (data['id'] is int) {
          await prefs.setInt('user_id', data['id']);
        } else if (data['id'] is String) {
          await prefs.setInt('user_id', int.parse(data['id']));
        }
        print('✅ ID sauvegardé: ${data['id']}');
      }

      if (data['email'] != null) {
        await prefs.setString('user_email', data['email']);
        print('✅ Email sauvegardé');
      }

      if (data['nom'] != null) {
        await prefs.setString('user_nom', data['nom']);
        print('✅ Nom sauvegardé');
      }

      if (data['prenom'] != null) {
        await prefs.setString('user_prenom', data['prenom']);
        print('✅ Prénom sauvegardé');
      }

      if (data['niveau'] != null) {
        await prefs.setString('user_niveau', data['niveau']);
        print('✅ Niveau sauvegardé');
      }

      if (data['role'] != null) {
        await prefs.setString('user_role', data['role']);
        print('✅ Role sauvegardé');
      }

      print('✅ Toutes les données ont été sauvegardées');
    } catch (e) {
      print('❌ Erreur lors de la sauvegarde: $e');
      rethrow;
    }
  }

  /// Se déconnecter de Google
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      print('✅ Déconnexion Google réussie');
    } catch (e) {
      print('❌ Erreur lors de la déconnexion Google: $e');
    }
  }

  /// Vérifier si l'utilisateur est connecté avec Google
  Future<bool> isSignedIn() async {
    return await _googleSignIn.isSignedIn();
  }

  /// Obtenir l'utilisateur actuellement connecté
  Future<GoogleSignInAccount?> getCurrentUser() async {
    return _googleSignIn.currentUser;
  }

  /// Se déconnecter complètement (Google + app)
  Future<void> disconnect() async {
    try {
      await _googleSignIn.disconnect();
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      print('✅ Déconnexion complète réussie');
    } catch (e) {
      print('❌ Erreur lors de la déconnexion: $e');
    }
  }
}