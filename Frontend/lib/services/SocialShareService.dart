import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';

class SocialShareService {

  /// Partager sur LinkedIn
  static Future<void> shareOnLinkedIn({
    required String quizTitle,
    required int score,
    required int totalQuestions,
    required int correctAnswers,
    required String difficulty,
  }) async {
    // Construire le message
    final message = _buildLinkedInMessage(
      quizTitle: quizTitle,
      score: score,
      totalQuestions: totalQuestions,
      correctAnswers: correctAnswers,
      difficulty: difficulty,
    );

    // URL LinkedIn pour partage
    final linkedInUrl = _buildLinkedInUrl(message);

    // Lancer le partage
    await _launchUrl(linkedInUrl);
  }

  /// Construire le message de partage
  static String _buildLinkedInMessage({
    required String quizTitle,
    required int score,
    required int totalQuestions,
    required int correctAnswers,
    required String difficulty,
  }) {
    String emoji = _getScoreEmoji(score);

    return '''
$emoji J'ai complété le quiz "$quizTitle" sur SmartLearn !

📊 Résultats :
• Score : $score%
• Questions réussies : $correctAnswers/$totalQuestions
• Niveau : $difficulty

${_getMotivationalMessage(score)}

#SmartLearn #Apprentissage #Formation #Quiz #DéveloppementPersonnel
''';
  }

  /// Obtenir l'emoji selon le score
  static String _getScoreEmoji(int score) {
    if (score >= 90) return '🏆';
    if (score >= 75) return '🎯';
    if (score >= 60) return '✅';
    if (score >= 50) return '💪';
    return '📚';
  }

  /// Message motivationnel selon le score
  static String _getMotivationalMessage(int score) {
    if (score == 100) {
      return '🌟 Score parfait ! Maîtrise totale du sujet.';
    } else if (score >= 90) {
      return '🚀 Excellente performance ! Presque parfait.';
    } else if (score >= 75) {
      return '👏 Très bon résultat ! Continue comme ça.';
    } else if (score >= 60) {
      return '💡 Bon travail ! Quelques points à améliorer.';
    } else if (score >= 50) {
      return '📈 C\'est un bon début ! Continue à t\'entraîner.';
    } else {
      return '🎓 Apprentissage en cours. Persévère !';
    }
  }

  /// Construire l'URL LinkedIn
  static String _buildLinkedInUrl(String message) {
    final encodedMessage = Uri.encodeComponent(message);

    // LinkedIn Share URL
    // Note: LinkedIn a des restrictions sur les partages directs
    // Cette URL ouvre LinkedIn avec le texte pré-rempli
    return 'https://www.linkedin.com/sharing/share-offsite/?url=https://smartlearn.app&summary=$encodedMessage';
  }

  /// Lancer l'URL
  static Future<void> _launchUrl(String urlString) async {
    final uri = Uri.parse(urlString);

    if (await canLaunchUrl(uri)) {
      await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
    } else {
      throw Exception('Impossible d\'ouvrir LinkedIn');
    }
  }

  /// Partage générique (fallback si LinkedIn ne fonctionne pas)
  static Future<void> shareGeneric({
    required String quizTitle,
    required int score,
    required int totalQuestions,
    required int correctAnswers,
  }) async {
    final message = '''
🎓 Quiz SmartLearn - "$quizTitle"

Score : $score%
Réussite : $correctAnswers/$totalQuestions questions

Apprends avec SmartLearn !
''';

    await Share.share(
      message,
      subject: 'Mon résultat SmartLearn',
    );
  }

  /// Partager avec image (optionnel - nécessite de générer une image)
  static Future<void> shareWithImage({
    required String quizTitle,
    required int score,
    required String imagePath,
  }) async {
    final message = '''
🎓 J'ai obtenu $score% au quiz "$quizTitle" sur SmartLearn !
''';

    await Share.shareXFiles(
      [XFile(imagePath)],
      text: message,
    );
  }
}