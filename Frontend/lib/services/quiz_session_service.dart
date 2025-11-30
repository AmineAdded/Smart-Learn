import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/quiz_session_model.dart';
import 'auth_service.dart';

class QuizSessionService {
  static final String baseUrl = '${dotenv.env['URL8080']}/api/quiz-session';
  final _authService = AuthService();

  Future<String?> _getToken() async {
    return await _authService.getToken();
  }

  Future<Map<String, String>> _getHeaders() async {
    final token = await _getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  /// POST /api/quiz-session/start/{quizId}
  Future<Map<String, dynamic>> startQuiz(int quizId) async {
    try {
      print('🔵 Démarrage du quiz #$quizId...');

      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/start/$quizId'),
        headers: headers,
      );

      print('🔵 Status Code: ${response.statusCode}');
      print('🔵 Response: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final session = QuizSessionModel.fromJson(data);

        print('✅ Session créée: #${session.sessionId}');
        return {
          'success': true,
          'data': session,
        };
      } else {
        final error = jsonDecode(response.body);
        return {
          'success': false,
          'message': error['message'] ?? 'Erreur de démarrage',
        };
      }
    } catch (e, stackTrace) {
      print('❌ Exception: $e');
      print('Stack trace: $stackTrace');
      return {
        'success': false,
        'message': 'Erreur de connexion: $e',
      };
    }
  }

  /// GET /api/quiz-session/resume/{sessionId}
  Future<Map<String, dynamic>> resumeQuiz(int sessionId) async {
    try {
      print('🔵 Reprise de la session #$sessionId...');

      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/resume/$sessionId'),
        headers: headers,
      );

      print('🔵 Status Code: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final session = QuizSessionModel.fromJson(data);

        print('✅ Session reprise');
        return {
          'success': true,
          'data': session,
        };
      } else {
        final error = jsonDecode(response.body);
        return {
          'success': false,
          'message': error['message'] ?? 'Erreur de reprise',
        };
      }
    } catch (e) {
      print('❌ Exception: $e');
      return {
        'success': false,
        'message': 'Erreur de connexion: $e',
      };
    }
  }

  /// POST /api/quiz-session/submit-answer
  Future<Map<String, dynamic>> submitAnswer({
    required int sessionId,
    required int questionId,
    required String answer,
    required int timeSpentSeconds,
  }) async {
    try {
      print('🔵 Soumission de réponse...');

      final headers = await _getHeaders();
      final body = jsonEncode({
        'sessionId': sessionId,
        'questionId': questionId,
        'answer': answer,
        'timeSpentSeconds': timeSpentSeconds,
      });

      final response = await http.post(
        Uri.parse('$baseUrl/submit-answer'),
        headers: headers,
        body: body,
      );

      print('🔵 Status Code: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final feedback = AnswerFeedbackModel.fromJson(data);

        print('✅ Réponse soumise - Correcte: ${feedback.isCorrect}');
        return {
          'success': true,
          'data': feedback,
        };
      } else {
        final error = jsonDecode(response.body);
        return {
          'success': false,
          'message': error['message'] ?? 'Erreur de soumission',
        };
      }
    } catch (e) {
      print('❌ Exception: $e');
      return {
        'success': false,
        'message': 'Erreur de connexion: $e',
      };
    }
  }

  /// POST /api/quiz-session/complete/{sessionId}
  Future<Map<String, dynamic>> completeQuiz(int sessionId) async {
    try {
      print('🔵 Fin du quiz...');

      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/complete/$sessionId'),
        headers: headers,
      );

      print('🔵 Status Code: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        print('✅ Quiz terminé - Score: ${data['score']}%');
        return {
          'success': true,
          'data': data,
        };
      } else {
        final error = jsonDecode(response.body);
        return {
          'success': false,
          'message': error['message'] ?? 'Erreur de finalisation',
        };
      }
    } catch (e) {
      print('❌ Exception: $e');
      return {
        'success': false,
        'message': 'Erreur de connexion: $e',
      };
    }
  }
}