import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class PasswordResetService {
  static final String baseUrl = '${dotenv.env['URL8080']}/api/auth/password';

  /// Demander un code OTP
  Future<Map<String, dynamic>> forgotPassword({
    required String email,
  }) async {
    try {
      print('🔵 Demande de code OTP pour: $email');

      final response = await http.post(
        Uri.parse('$baseUrl/forgot'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );

      print('🔵 Status: ${response.statusCode}');
      print('🔵 Response: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'message': data['message'] ?? 'Code envoyé avec succès'
        };
      } else {
        final error = jsonDecode(response.body);
        return {
          'success': false,
          'message': error['message'] ?? 'Erreur lors de l\'envoi'
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

  /// ✅ NOUVEAU : Vérifier un code OTP
  Future<Map<String, dynamic>> verifyCode({
    required String code,
  }) async {
    try {
      print('🔵 Vérification du code OTP: $code');

      final response = await http.post(
        Uri.parse('$baseUrl/verify-code'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'code': code}),
      );

      print('🔵 Status: ${response.statusCode}');
      print('🔵 Response: ${response.body}');

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['valid'] == true) {
        return {
          'success': true,
          'email': data['email'],
          'token': data['token'], // ✅ Token UUID pour l'étape suivante
          'message': data['message']
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Code invalide'
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

  /// Vérifier un token UUID
  Future<Map<String, dynamic>> verifyToken({
    required String token,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/verify?token=$token'),
        headers: {'Content-Type': 'application/json'},
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['valid'] == true) {
        return {
          'success': true,
          'email': data['email'],
          'message': data['message']
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Token invalide'
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Erreur de connexion au serveur'
      };
    }
  }

  /// Réinitialiser le mot de passe
  Future<Map<String, dynamic>> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    try {
      print('🔵 Réinitialisation du mot de passe...');

      final response = await http.post(
        Uri.parse('$baseUrl/reset'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'token': token,
          'newPassword': newPassword,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': data['message'] ?? 'Mot de passe réinitialisé avec succès'
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Erreur lors de la réinitialisation'
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Erreur de connexion au serveur'
      };
    }
  }
}