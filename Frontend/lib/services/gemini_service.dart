import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Service pour générer des explications avec Google Gemini (GRATUIT)
class GeminiService {
  static final String apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';
  static const String baseUrl = 'https://generativelanguage.googleapis.com/v1beta';

  /// Générer une explication pour une réponse de quiz avec Gemini
  Future<Map<String, dynamic>> generateQuizExplanation({
    required String questionText,
    required String userAnswer,
    required String correctAnswer,
    List<String>? options,
    required bool isCorrect,
  }) async {
    try {
      print("API KEY: ${GeminiService.apiKey}");
      print('🤖 Génération d\'explication avec Gemini...');
      print('Question: $questionText');
      print('Réponse utilisateur: $userAnswer');
      print('Réponse correcte: $correctAnswer');
      print('Est correct: $isCorrect');

      // Construire le prompt
      final prompt = _buildPrompt(
        questionText: questionText,
        userAnswer: userAnswer,
        correctAnswer: correctAnswer,
        options: options,
        isCorrect: isCorrect,
      );

      // Appel à l'API Gemini
      final response = await http.post(
        Uri.parse(
            '$baseUrl/models/gemini-2.5-flash-lite:generateContent?key=$apiKey'
        ),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {'text': prompt}
              ]
            }
          ],
          'generationConfig': {
            'temperature': 0.7,
            'maxOutputTokens': 300,
          }
        }),
      )
          .timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('Timeout: L\'API Gemini ne répond pas');
        },
      );

      print('🤖 Status Code: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Extraire l'explication générée
        final explanation = data['candidates'][0]['content']['parts'][0]['text'] as String;

        print('✅ Explication générée avec succès');
        print('Explication: ${explanation.substring(0, explanation.length > 100 ? 100 : explanation.length)}...');

        return {
          'success': true,
          'explanation': explanation.trim(),
        };
      } else {
        print('❌ Erreur API Gemini: ${response.statusCode}');
        print('Response: ${response.body}');

        return {
          'success': false,
          'explanation': _getFallbackExplanation(isCorrect, correctAnswer),
          'error': 'Erreur API: ${response.statusCode}',
        };
      }
    } catch (e, stackTrace) {
      print('❌ Exception lors de la génération: $e');
      print('Stack trace: $stackTrace');

      return {
        'success': false,
        'explanation': _getFallbackExplanation(isCorrect, correctAnswer),
        'error': e.toString(),
      };
    }
  }

  /// Construire le prompt pour Gemini
  String _buildPrompt({
    required String questionText,
    required String userAnswer,
    required String correctAnswer,
    List<String>? options,
    required bool isCorrect,
  }) {
    final buffer = StringBuffer();

    buffer.writeln('Tu es un assistant pédagogique expert qui aide les étudiants à comprendre leurs erreurs et à apprendre. Tu donnes des explications claires, concises et encourageantes en français.');
    buffer.writeln();
    buffer.writeln('Question: $questionText');
    buffer.writeln();

    if (options != null && options.isNotEmpty) {
      buffer.writeln('Options disponibles:');
      for (int i = 0; i < options.length; i++) {
        buffer.writeln('${String.fromCharCode(65 + i)}. ${options[i]}');
      }
      buffer.writeln();
    }

    buffer.writeln('Réponse de l\'étudiant: $userAnswer');
    buffer.writeln('Réponse correcte: $correctAnswer');
    buffer.writeln();

    if (isCorrect) {
      buffer.writeln('La réponse de l\'étudiant est CORRECTE.');
      buffer.writeln();
      buffer.writeln('Tâche: Félicite brièvement l\'étudiant et explique en 2-3 phrases pourquoi cette réponse est correcte. Sois encourageant et pédagogique.');
    } else {
      buffer.writeln('La réponse de l\'étudiant est INCORRECTE.');
      buffer.writeln();
      buffer.writeln('Tâche: Explique en 2-3 phrases pourquoi la réponse de l\'étudiant est incorrecte et pourquoi la bonne réponse est "$correctAnswer". Sois bienveillant et aide l\'étudiant à comprendre son erreur.');
    }

    return buffer.toString();
  }

  /// Explication de secours en cas d'échec de l'API
  String _getFallbackExplanation(bool isCorrect, String correctAnswer) {
    if (isCorrect) {
      return 'Excellent ! Votre réponse est correcte. Vous avez bien compris le concept. Continuez comme ça ! 🎉';
    } else {
      return 'Ce n\'est pas la bonne réponse. La réponse correcte est : "$correctAnswer". Prenez le temps de réviser ce concept pour mieux le comprendre. 📚';
    }
  }

  /// Générer une explication courte (pour les notifications)
  String generateShortFeedback(bool isCorrect) {
    if (isCorrect) {
      return 'Bravo ! Réponse correcte ! 🎉';
    } else {
      return 'Pas tout à fait. Voyons pourquoi...';
    }
  }
}