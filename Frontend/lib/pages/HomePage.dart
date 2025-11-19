import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'home/home_stat_cards.dart';
import 'home/home_content_widgets.dart';
import 'home/home_bottom_nav.dart';
import 'ProfilePage.dart';
import 'ProgressionPage.dart'; // ✅ Nouvelle import
import '../services/progress_service.dart';
import '../models/user_progress.dart'; // ✅ Import
import '../l10n/app_localizations.dart'; // ✅ AJOUTÉ

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
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final userData = await _authService.getCurrentUser();
    setState(() {
      _userData = userData;
      _isLoading = false;
    });
  }
  // ✅ Méthode unifiée pour charger toutes les données
  Future<void> _loadAllData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Charger les données utilisateur
      final userData = await _authService.getCurrentUser();

      // Charger les données de progression
      final progressResult = await _progressService.getUserProgress();

      setState(() {
        _userData = userData;
        if (progressResult['success']) {
          _userProgress = progressResult['data'];
          print('✅ Données chargées: XP=${_userProgress?.totalXp}, Quiz=${_userProgress?.quizCompleted}');
        } else {
          print('❌ Erreur progression: ${progressResult['message']}');
        }
        _isLoading = false;
      });
    } catch (e) {
      print('❌ Erreur chargement: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }
  void _onNavBarTap(int index) {
    final l10n = AppLocalizations.of(context)!;

    setState(() {
      _currentNavIndex = index;
    });

    switch (index) {
      case 0:
        break;
      case 1:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${l10n.quizzes} - ${l10n.loading}'), // ✅ Traduit
            behavior: SnackBarBehavior.floating,
          ),
        );
        break;
      case 2:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${l10n.videos} - ${l10n.loading}'), // ✅ Traduit
            behavior: SnackBarBehavior.floating,
          ),
        );
        break;
      case 3:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ProgressionPage()),
        ).then((_) {
          setState(() => _currentNavIndex = 0);
          _loadAllData();
        });
        break;
      case 4:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ProfilePage()),
        ).then((_) {
          setState(() => _currentNavIndex = 0);
          _loadAllData();
        });
        break;
    }
  }

  void _handleNotificationTap() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Page de notifications en cours de développement'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _handleQuizTap(String quizTitle) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Ouverture du quiz: $quizTitle'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _handleVideoTap(String videoTitle) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Lecture de: $videoTitle'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    // ✅ Récupérer les traductions
    final l10n = AppLocalizations.of(context)!;

    if (_isLoading) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 16),
              Text(l10n.loading), // ✅ Traduit
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: RefreshIndicator( // ✅ Ajout du pull-to-refresh
        onRefresh: _loadAllData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // En-tête avec salutation et niveau
              WelcomeHeader(
                userName: _userData?['prenom'] ?? l10n.welcome, // ✅ Traduit
                currentLevel: _userProgress?.levelTitle ?? l10n.level, // ✅ Traduit
                progressPercentage: _userProgress?.progressPercentage.toDouble() ?? 0.0,
                onNotificationTap: _handleNotificationTap,
              ),

              const SizedBox(height: 24),

              // Message d'évaluation IA
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6C5CE7).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFF6C5CE7).withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: Color(0xFF6C5CE7),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.auto_awesome,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Votre niveau a été évalué à : ${_userProgress?.levelTitle ?? 'Débutant'}',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Continuez avec le quiz de Mathématiques recommandé !',
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

              // ✅ Statistiques dynamiques
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
                  child: StatsGrid(
                    xp: 0,
                    quizCompleted: 0,
                    studyTime: '0h',
                  ),
                ),

              const SizedBox(height: 32),

              // Section Quiz recommandés
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: SectionHeader(
                  title: l10n.recommendedQuizzes, // ✅ Traduit
                  onSeeAllTap: () {},
                ),
              ),

              const SizedBox(height: 16),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    QuizCard(
                      title: 'Algèbre avancée',
                      icon: '📐',
                      questionCount: 15,
                      difficulty: 'Moyen',
                      completionPercentage: '85%',
                      hasAI: true,
                      onTap: () => _handleQuizTap('Algèbre avancée'),
                    ),
                    const SizedBox(height: 12),
                    QuizCard(
                      title: 'Physique : Mécanique',
                      icon: '⚡',
                      questionCount: 20,
                      difficulty: 'Difficile',
                      hasAI: true,
                      onTap: () => _handleQuizTap('Physique : Mécanique'),

                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Section Vidéos récentes
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: SectionHeader(
                  title: l10n.recentVideos, // ✅ Traduit
                  onSeeAllTap: () {},
                ),
              ),

              const SizedBox(height: 16),

              SizedBox(
                height: 220,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  children: [
                    VideoCard(
                      title: 'Fonctions mathématiques',
                      thumbnail: 'https://via.placeholder.com/280x160',
                      duration: '12:45',
                      onTap: () => _handleVideoTap('Fonctions mathématiques'),
                    ),
                    VideoCard(
                      title: 'Introduction à la chimie',
                      thumbnail: 'https://via.placeholder.com/280x160',
                      duration: '8:30',
                      isNew: true,
                      onTap: () => _handleVideoTap('Introduction à la chimie'),
                    ),
                    VideoCard(
                      title: 'Histoire moderne',
                      thumbnail: 'https://via.placeholder.com/280x160',
                      duration: '15:20',
                      onTap: () => _handleVideoTap('Histoire moderne'),
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