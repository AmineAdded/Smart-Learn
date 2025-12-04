import 'package:flutter/material.dart';
import 'package:smart_learn/pages/quizzes/QuizzesPage.dart';
import '../services/auth_service.dart';
import 'home/home_stat_cards.dart';
import 'home/home_content_widgets.dart';
import 'home/home_bottom_nav.dart';
import 'ProfilePage.dart';
import 'ProgressionPage.dart';
import '../services/progress_service.dart';
import '../models/user_progress.dart';
import '../l10n/app_localizations.dart';
import 'videos/VideosPage.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _authService = AuthService();
  final _progressService = ProgressService();
  int _currentNavIndex = 0;

  Map<String, dynamic>? _userData;
  UserProgress? _userProgress;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAllData(); // On charge tout dès le début
  }

  Future<void> _loadAllData() async {
    setState(() => _isLoading = true);

    try {
      final userData = await _authService.getCurrentUser();
      final progressResult = await _progressService.getUserProgress();

      setState(() {
        _userData = userData;
        if (progressResult['success']) {
          _userProgress = progressResult['data'];
        }
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _onNavBarTap(int index) {
    final l10n = AppLocalizations.of(context)!;

    setState(() => _currentNavIndex = index);

    switch (index) {
      case 0:
        break;
      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const QuizzesPage()),
        ).then((_) {
          setState(() => _currentNavIndex = 0);
          _loadAllData();
        });
        break;
      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const VideosPage()),
        ).then((_) {
          setState(() => _currentNavIndex = 0);
          _loadAllData();
        });
        break;

      case 3:
        Navigator.push(context, MaterialPageRoute(builder: (_) => const ProgressionPage()))
            .then((_) => setState(() => _currentNavIndex = 0));
        _loadAllData();
        break;
      case 4:
        Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfilePage()))
            .then((_) => setState(() => _currentNavIndex = 0));
        break;
    }
  }

  void _handleNotificationTap() {
    final l10n = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.notificationsInDevelopment)),
    );
  }

  void _handleQuizTap(String quizTitle) {
    final l10n = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.openingQuiz(quizTitle))),
    );
  }

  void _handleVideoTap(String videoTitle) {
    final l10n = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.playingVideo(videoTitle))),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (_isLoading) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: Theme.of(context).colorScheme.primary),
              const SizedBox(height: 16),
              Text(l10n.loading),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: RefreshIndicator(
        onRefresh: _loadAllData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // === En-tête (inchangé) ===
              WelcomeHeader(
                userName: _userData?['prenom'] ?? l10n.guestUser,
                currentLevel: _userProgress?.levelTitle ?? l10n.beginnerLevel,
                progressPercentage: _userProgress?.progressPercentage.toDouble() ?? 0.0,
                onNotificationTap: _handleNotificationTap,
              ),

              const SizedBox(height: 24),

              // === Message IA (texte traduit seulement) ===
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6C5CE7).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF6C5CE7).withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(color: Color(0xFF6C5CE7), shape: BoxShape.circle),
                        child: const Icon(Icons.auto_awesome, color: Colors.white, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.aiLevelMessage(_userProgress?.levelTitle ?? l10n.beginnerLevel),
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              l10n.continueWithRecommendedQuiz,
                              style: TextStyle(
                                fontSize: 12,
                                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // === Stats (inchangées) ===
              if (_userProgress != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: StatsGrid(
                    xp: _userProgress!.totalXp,
                    quizCompleted: _userProgress!.quizCompleted,
                    studyTime: _userProgress!.studyTimeFormatted,
                  ),
                )
              else
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  child: StatsGrid(xp: 0, quizCompleted: 0, studyTime: '0h'),
                ),

              const SizedBox(height: 32),

              // === Quiz recommandés ===
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: SectionHeader(title: l10n.recommendedQuizzes, onSeeAllTap: () {}),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    QuizCard(
                      title: l10n.advancedAlgebra,
                      icon: 'Ruler',
                      questionCount: 15,
                      difficulty: l10n.medium,
                      completionPercentage: '85%',
                      hasAI: true,
                      onTap: () => _handleQuizTap(l10n.advancedAlgebra),
                    ),
                    const SizedBox(height: 12),
                    QuizCard(
                      title: l10n.physicsMechanics,
                      icon: 'Lightning',
                      questionCount: 20,
                      difficulty: l10n.hard,
                      hasAI: true,
                      onTap: () => _handleQuizTap(l10n.physicsMechanics),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // === Vidéos récentes ===
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: SectionHeader(title: l10n.recentVideos, onSeeAllTap: () {}),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 220,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  children: [
                    VideoCard(
                      title: l10n.mathFunctions,
                      thumbnail: 'https://via.placeholder.com/280x160',
                      duration: '12:45',
                      onTap: () => _handleVideoTap(l10n.mathFunctions),
                    ),
                    VideoCard(
                      title: l10n.chemistryIntro,
                      thumbnail: 'https://via.placeholder.com/280x160',
                      duration: '8:30',
                      isNew: true,
                      onTap: () => _handleVideoTap(l10n.chemistryIntro),
                    ),
                    VideoCard(
                      title: l10n.modernHistory,
                      thumbnail: 'https://via.placeholder.com/280x160',
                      duration: '15:20',
                      onTap: () => _handleVideoTap(l10n.modernHistory),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: _currentNavIndex,
        onTap: _onNavBarTap,
      ),
    );
  }
}