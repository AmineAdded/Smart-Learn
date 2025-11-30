import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/quiz_model.dart';
import '../models/quiz_detail_model.dart';
import 'auth_service.dart';

class QuizService {
  static final String baseUrl = '${dotenv.env['URL8080']}/api/quizzes';
  final _authService = AuthService();

  /// Récupérer le token d'authentification
  Future<String?> _getToken() async {
    return await _authService.getToken();
  }

  /// Headers avec authentification
  Future<Map<String, String>> _getHeaders() async {
    final token = await _getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  /// GET /api/quizzes - Récupérer tous les quiz avec filtres
  Future<Map<String, dynamic>> getQuizzes({
    String? category,
    String? difficulty,
    bool? hasAI,
  }) async {
    try {
      print('🔵 Récupération des quiz...');

      String url = baseUrl;
      List<String> params = [];

      if (category != null && category.isNotEmpty) {
        params.add('category=$category');
      }
      if (difficulty != null && difficulty.isNotEmpty) {
        params.add('difficulty=$difficulty');
      }
      if (hasAI != null) {
        params.add('hasAI=$hasAI');
      }

      if (params.isNotEmpty) {
        url += '?${params.join('&')}';
      }

      print('URL: $url');

      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      );

      print('🔵 Status Code: ${response.statusCode}');

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final quizzes = data.map((json) => QuizModel.fromJson(json)).toList();

        print('✅ ${quizzes.length} quiz récupérés');
        return {
          'success': true,
          'data': quizzes,
        };
      } else {
        final error = jsonDecode(response.body);
        return {
          'success': false,
          'message': error['message'] ?? 'Erreur lors de la récupération des quiz',
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

  /// GET /api/quizzes/{id} - Récupérer un quiz par son ID (version simple)
  Future<Map<String, dynamic>> getQuizById(int id) async {
    try {
      print('🔵 Récupération du quiz #$id...');

      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/$id'),
        headers: headers,
      );

      print('🔵 Status Code: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final quiz = QuizModel.fromJson(data);

        print('✅ Quiz récupéré: ${quiz.title}');
        return {
          'success': true,
          'data': quiz,
        };
      } else {
        final error = jsonDecode(response.body);
        return {
          'success': false,
          'message': error['message'] ?? 'Quiz non trouvé',
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

  /// GET /api/quizzes/{id}/detail - Récupérer les détails complets d'un quiz
  Future<Map<String, dynamic>> getQuizDetail(int id) async {
    try {
      print('🔵 Récupération des détails du quiz #$id...');

      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/$id/detail'),
        headers: headers,
      );

      print('🔵 Status Code: ${response.statusCode}');
      print('🔵 Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final quizDetail = QuizDetailModel.fromJson(data);

        print('✅ Détails du quiz récupérés: ${quizDetail.title}');
        return {
          'success': true,
          'data': quizDetail,
        };
      } else {
        final error = jsonDecode(response.body);
        return {
          'success': false,
          'message': error['message'] ?? 'Quiz non trouvé',
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

  /// GET /api/quizzes/categories - Récupérer les catégories
  Future<Map<String, dynamic>> getCategories() async {
    try {
      print('🔵 Récupération des catégories...');

      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/categories'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final categories = data.map((e) => e.toString()).toList();

        print('✅ ${categories.length} catégories récupérées');
        return {
          'success': true,
          'data': categories,
        };
      } else {
        return {
          'success': false,
          'message': 'Erreur lors de la récupération des catégories',
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

  /// GET /api/quizzes/recommended - Quiz recommandés
  Future<Map<String, dynamic>> getRecommendedQuizzes() async {
    try {
      print('🔵 Récupération des quiz recommandés...');

      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/recommended'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final quizzes = data.map((json) => QuizModel.fromJson(json)).toList();

        print('✅ ${quizzes.length} quiz recommandés récupérés');
        return {
          'success': true,
          'data': quizzes,
        };
      } else {
        return {
          'success': false,
          'message': 'Erreur lors de la récupération des quiz recommandés',
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
}