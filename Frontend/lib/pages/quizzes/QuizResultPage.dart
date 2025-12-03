import 'package:flutter/material.dart';
import '../../services/SocialShareService.dart';


class QuizResultPage extends StatefulWidget {
  final Map<String, dynamic> result;

  const QuizResultPage({
    super.key,
    required this.result,
  });

  @override
  State<QuizResultPage> createState() => _QuizResultPageState();
}

class _QuizResultPageState extends State<QuizResultPage> {
  bool _isSharing = false;

  @override
  void initState() {
    super.initState();
    print('🎯 QuizResultPage initialisée');
    print('📊 Données reçues: ${widget.result}');
  }

  int _getScore() => widget.result['score'] as int? ?? 0;
  int _getCorrectAnswers() => widget.result['correctAnswers'] as int? ?? 0;
  int _getTotalQuestions() => widget.result['totalQuestions'] as int? ?? 0;
  int _getXpEarned() => widget.result['xpEarned'] as int? ?? 0;
  bool _isPassed() => widget.result['passed'] as bool? ?? false;
  String _getQuizTitle() => widget.result['quiz']?['title'] ?? 'Quiz';
  String _getDifficulty() => widget.result['quiz']?['difficulty'] ?? 'Moyen';

  Future<void> _shareOnLinkedIn() async {
    setState(() => _isSharing = true);

    try {
      print('🔵 Partage sur LinkedIn...');
      await SocialShareService.shareOnLinkedIn(
        quizTitle: _getQuizTitle(),
        score: _getScore(),
        totalQuestions: _getTotalQuestions(),
        correctAnswers: _getCorrectAnswers(),
        difficulty: _getDifficulty(),
      );
      print('✅ Partage LinkedIn lancé');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Partage LinkedIn ouvert !'),
            backgroundColor: Color(0xFF0077B5),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      print('❌ Erreur partage: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isSharing = false);
    }
  }

  Future<void> _shareGeneric() async {
    try {
      await SocialShareService.shareGeneric(
        quizTitle: _getQuizTitle(),
        score: _getScore(),
        totalQuestions: _getTotalQuestions(),
        correctAnswers: _getCorrectAnswers(),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    print('🖼️ Build de QuizResultPage');

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF5B9FD8),
        title: const Text('Résultats du Quiz'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              // Score
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: const Color(0xFF5B9FD8),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.emoji_events, size: 80, color: Colors.white),
                    const SizedBox(height: 16),
                    Text(
                      '${_getScore()}%',
                      style: const TextStyle(
                        fontSize: 72,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      '${_getCorrectAnswers()}/${_getTotalQuestions()} questions correctes',
                      style: const TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Stats
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    _buildStatRow('XP gagnés', '+${_getXpEarned()}', Icons.star),
                    const Divider(height: 24),
                    _buildStatRow('Statut', _isPassed() ? 'Réussi ✅' : 'Non réussi ❌', Icons.check_circle),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // ⭐ SECTION PARTAGE LINKEDIN
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF0077B5).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF0077B5)),
                ),
                child: Column(
                  children: [
                    const Text(
                      '📱 Partager mes résultats',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _isSharing ? null : _shareOnLinkedIn,
                        icon: _isSharing
                            ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                            : const Icon(Icons.business),
                        label: const Text('Partager sur LinkedIn'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0077B5),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _shareGeneric,
                        icon: const Icon(Icons.share),
                        label: const Text('Autre partage'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF5B9FD8),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: const BorderSide(color: Color(0xFF5B9FD8)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Boutons retour
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/home',
                          (route) => false,
                    );
                  },
                  icon: const Icon(Icons.home),
                  label: const Text('Retour à l\'accueil'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5B9FD8),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF5B9FD8)),
        const SizedBox(width: 12),
        Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}