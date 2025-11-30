import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/quiz_service.dart';
import '../../models/quiz_detail_model.dart';
import 'QuizPlayPage.dart';


class QuizDetailPage extends StatefulWidget {
  final int quizId;

  const QuizDetailPage({
    super.key,
    required this.quizId,
  });

  @override
  State<QuizDetailPage> createState() => _QuizDetailPageState();
}

class _QuizDetailPageState extends State<QuizDetailPage> {
  final _quizService = QuizService();

  QuizDetailModel? _quizDetail;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadQuizDetail();
  }

  Future<void> _loadQuizDetail() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final result = await _quizService.getQuizDetail(widget.quizId);

    setState(() {
      _isLoading = false;
      if (result['success']) {
        _quizDetail = result['data'];
      } else {
        _errorMessage = result['message'];
      }
    });
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'facile':
      case 'easy':
        return const Color(0xFF00B894);
      case 'moyen':
      case 'medium':
        return const Color(0xFFFDB33F);
      case 'difficile':
      case 'hard':
        return const Color(0xFFE74C3C);
      default:
        return Colors.grey;
    }
  }

  void _startQuiz() async {
    // Vérifier si une session est en cours
    if (_quizDetail!.userProgress.progressStatus == 'in_progress') {
      final shouldResume = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Reprendre le quiz ?'),
          content: const Text(
            'Vous avez une session en cours. Voulez-vous la reprendre ou recommencer ?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Recommencer'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF5B9FD8),
              ),
              child: const Text('Reprendre'),
            ),
          ],
        ),
      );

      if (shouldResume == null) return;

      if (!shouldResume) {
        // Supprimer l'ancienne session (appeler l'API de suppression)
        // Pour l'instant, on crée juste une nouvelle session
      }
    }

    // Navigation vers la page de quiz en cours
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QuizPlayPage(quizId: widget.quizId),
      ),
    ).then((_) {
      // Recharger les détails après le quiz
      _loadQuizDetail();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: const Color(0xFF5B9FD8),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Détails du Quiz',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: _buildBody(),
      bottomNavigationBar: _quizDetail != null ? _buildBottomBar() : null,
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF5B9FD8)),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(_errorMessage!, textAlign: TextAlign.center),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadQuizDetail,
              child: const Text('Réessayer'),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          _buildQuickInfo(),
          _buildDescription(),
          _buildQuestionTypes(),
          if (_quizDetail!.userProgress.hasAttempted) _buildUserProgress(),
          _buildStatistics(),
          if (_quizDetail!.topScores.isNotEmpty) _buildLeaderboard(),
          const SizedBox(height: 100), // Espace pour le bouton fixe
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final quiz = _quizDetail!;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF5B9FD8), Color(0xFF4A8BC2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  quiz.title,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              if (quiz.hasAI)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: const [
                      Icon(Icons.auto_awesome, size: 16, color: Colors.white),
                      SizedBox(width: 4),
                      Text(
                        'IA',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildBadge(
                quiz.category,
                Colors.white.withOpacity(0.9),
                const Color(0xFF5B9FD8),
              ),
              _buildBadge(
                quiz.difficulty,
                _getDifficultyColor(quiz.difficulty),
                Colors.white,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(String text, Color bgColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }

  Widget _buildQuickInfo() {
    final quiz = _quizDetail!;

    // ⭐ Calculer le nombre réel de questions depuis la distribution
    int totalQuestionsFromDistribution =
        quiz.questionDistribution.multipleChoice +
            quiz.questionDistribution.trueFalse +
            quiz.questionDistribution.shortAnswer +
            quiz.questionDistribution.matching;

    // ⭐ Utiliser le nombre réel si différent
    int displayedQuestionCount = quiz.questionCount;
    if (totalQuestionsFromDistribution > 0 &&
        totalQuestionsFromDistribution != quiz.questionCount) {
      print('⚠️ Incohérence détectée:');
      print('   Quiz indique: ${quiz.questionCount}');
      print('   Réel: $totalQuestionsFromDistribution');
      displayedQuestionCount = totalQuestionsFromDistribution;
    }

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildInfoItem(
            Icons.quiz,
            '$displayedQuestionCount', // ⭐ Utiliser le nombre corrigé
            'Questions',
          ),
          _buildInfoItem(
            Icons.timer,
            '${quiz.durationMinutes}',
            'Minutes',
          ),
          _buildInfoItem(
            Icons.emoji_events,
            '+${quiz.xpReward}',
            'XP',
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, size: 32, color: const Color(0xFF5B9FD8)),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildDescription() {
    if (_quizDetail!.description.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Description',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            _quizDetail!.description,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionTypes() {
    final dist = _quizDetail!.questionDistribution;
    final types = <Map<String, dynamic>>[
      if (dist.multipleChoice > 0)
        {
          'icon': Icons.radio_button_checked,
          'label': 'QCM',
          'count': dist.multipleChoice
        },
      if (dist.trueFalse > 0)
        {
          'icon': Icons.check_circle_outline,
          'label': 'Vrai/Faux',
          'count': dist.trueFalse
        },
      if (dist.shortAnswer > 0)
        {
          'icon': Icons.edit_note,
          'label': 'Réponse courte',
          'count': dist.shortAnswer
        },
      if (dist.matching > 0)
        {
          'icon': Icons.compare_arrows,
          'label': 'Association',
          'count': dist.matching
        },
      if (dist.withImages > 0)
        {
          'icon': Icons.image,
          'label': 'Avec images',
          'count': dist.withImages
        },
    ];

    if (types.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Types de questions',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...types.map((type) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                Icon(
                  type['icon'] as IconData,
                  size: 24,
                  color: const Color(0xFF5B9FD8),
                ),
                const SizedBox(width: 12),
                Text(
                  type['label'] as String,
                  style: const TextStyle(fontSize: 14),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF5B9FD8).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${type['count']}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF5B9FD8),
                    ),
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildUserProgress() {
    final progress = _quizDetail!.userProgress;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF00B894).withOpacity(0.1),
            const Color(0xFF00B894).withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF00B894).withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.history,
                color: Color(0xFF00B894),
                size: 24,
              ),
              const SizedBox(width: 8),
              const Text(
                'Votre progression',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildProgressItem(
                'Tentatives',
                '${progress.attemptsCount}',
                Icons.repeat,
              ),
              _buildProgressItem(
                'Meilleur score',
                '${progress.bestScore ?? 0}%',
                Icons.star,
              ),
              _buildProgressItem(
                'Dernier score',
                '${progress.lastScore ?? 0}%',
                Icons.trending_up,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgressItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: const Color(0xFF00B894)),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF00B894),
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildStatistics() {
    final stats = _quizDetail!.statistics;
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Statistiques globales',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildStatItem(
            'Tentatives totales',
            '${stats.totalAttempts}',
            Icons.people,
          ),
          const SizedBox(height: 12),
          _buildStatItem(
            'Score moyen',
            '${stats.averageScore.toStringAsFixed(1)}%',
            Icons.analytics,
          ),
          const SizedBox(height: 12),
          _buildStatItem(
            'Taux de complétion',
            '${stats.completionRate}%',
            Icons.task_alt,
          ),
          const SizedBox(height: 12),
          _buildStatItem(
            'Temps moyen',
            '${stats.averageTimeMinutes.toStringAsFixed(1)} min',
            Icons.access_time,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 12),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[700],
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildLeaderboard() {
    final topScores = _quizDetail!.topScores;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.emoji_events,
                color: Color(0xFFFDB33F),
                size: 24,
              ),
              const SizedBox(width: 8),
              const Text(
                'Classement (Top 5)',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...topScores.asMap().entries.map((entry) {
            final index = entry.key;
            final score = entry.value;
            return _buildLeaderboardItem(score, index);
          }),
        ],
      ),
    );
  }

  Widget _buildLeaderboardItem(LeaderboardEntry entry, int index) {
    Color rankColor;
    IconData rankIcon;

    switch (index) {
      case 0:
        rankColor = const Color(0xFFFDB33F); // Or
        rankIcon = Icons.emoji_events;
        break;
      case 1:
        rankColor = const Color(0xFFC0C0C0); // Argent
        rankIcon = Icons.workspace_premium;
        break;
      case 2:
        rankColor = const Color(0xFFCD7F32); // Bronze
        rankIcon = Icons.military_tech;
        break;
      default:
        rankColor = Colors.grey;
        rankIcon = Icons.label;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: rankColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: rankColor.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(rankIcon, color: rankColor, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.username,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  DateFormat('dd/MM/yyyy').format(entry.completedAt),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: rankColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${entry.score}%',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: _startQuiz,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF5B9FD8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.play_arrow, size: 28),
                const SizedBox(width: 8),
                Text(
                  _quizDetail!.userProgress.hasAttempted
                      ? 'Reprendre le quiz'
                      : 'Commencer le quiz',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}