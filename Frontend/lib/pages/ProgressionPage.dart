import 'package:flutter/material.dart';
import '../services/progress_service.dart';
import '../models/user_progress.dart';
import '../models/statistics.dart';
import '../l10n/app_localizations.dart';
import 'profile/profile_level_card.dart';
import 'profile/profile_stats_cards.dart';
import 'profile/profile_chart.dart';
import 'profile/profile_achievements.dart';

/// Page dédiée à la progression et aux statistiques de l'utilisateur
class ProgressionPage extends StatefulWidget {
  const ProgressionPage({super.key});

  @override
  State<ProgressionPage> createState() => _ProgressionPageState();
}

class _ProgressionPageState extends State<ProgressionPage> {
  final _progressService = ProgressService();

  UserProgress? _userProgress;
  Statistics? _statistics;
  Map<String, dynamic>? _weeklyProgress;

  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  /// Charger toutes les données statistiques
  Future<void> _loadAllData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Charger le progrès utilisateur
      final progressResult = await _progressService.getUserProgress();
      if (progressResult['success']) {
        _userProgress = progressResult['data'];
      }

      // Charger les statistiques détaillées
      final statsResult = await _progressService.getStatistics();
      if (statsResult['success']) {
        _statistics = statsResult['data'];
      }

      // Charger la progression hebdomadaire
      final weeklyResult = await _progressService.getWeeklyProgress();
      if (weeklyResult['success']) {
        _weeklyProgress = weeklyResult['data'];
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      final l10n = AppLocalizations.of(context)!;
      setState(() {
        _isLoading = false;
        _errorMessage = l10n.errorLoadingData;
      });
      print('Erreur: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: const Color(0xFF5B9FD8),
        elevation: 0,
        title: Text(
          l10n.myProgress,
          style: Theme.of(context).appBarTheme.titleTextStyle?.copyWith(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
              Icons.arrow_back,
              color: Colors.white
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    final l10n = AppLocalizations.of(context)!;

    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(color: Color(0xFF5B9FD8)),
            const SizedBox(height: 16),
            Text(
              l10n.loadingStats,
              style: const TextStyle(fontSize: 16, color: Color(0xFF636E72)),
            ),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              style: const TextStyle(fontSize: 16, color: Color(0xFF636E72)),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadAllData,
              icon: const Icon(Icons.refresh),
              label: Text(l10n.retryButton),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF5B9FD8),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadAllData,
      color: const Color(0xFF5B9FD8),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),

            // Carte de niveau avec progression
            if (_userProgress != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: ProfileLevelCard(
                  currentLevel: _userProgress!.currentLevel,
                  levelTitle: _userProgress!.levelTitle,
                  currentXp: _userProgress!.xpProgressInCurrentLevel,
                  xpForNextLevel: 1000,
                  progressPercentage: _userProgress!.progressPercentage,
                ),
              ),

            const SizedBox(height: 24),

            // Statistiques principales
            if (_userProgress != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: ProfileStatsCards(
                  totalXp: _userProgress!.totalXp,
                  quizCompleted: _userProgress!.quizCompleted,
                  successRate: _userProgress!.averageSuccessRate,
                  studyTime: _userProgress!.studyTimeFormatted,
                  currentStreak: _userProgress!.currentStreak,
                  videosWatched: _userProgress!.videosWatched,
                ),
              ),

            const SizedBox(height: 32),

            // Graphique hebdomadaire
            if (_weeklyProgress != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: ProfileWeeklyChart(weeklyData: _weeklyProgress!),
              ),

            const SizedBox(height: 32),

            // Réalisations et badges
            if (_statistics != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: ProfileAchievements(
                  goals: _statistics!.goals.map((goal) => {
                    'title': goal.title,
                    'description': goal.description,
                    'current': goal.current,
                    'target': goal.target,
                    'progress': goal.progress,
                    'completed': goal.completed,
                  }).toList(),
                  globalRank: _statistics!.globalRank,
                  totalUsers: _statistics!.totalUsers,
                ),
              ),

            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }
}