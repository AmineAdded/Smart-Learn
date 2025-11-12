import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'home/home_stat_cards.dart';
import 'home/home_content_widgets.dart';
import 'home/home_bottom_nav.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _authService = AuthService();
  int _currentNavIndex = 0;

  Map<String, dynamic>? _userData;
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

  void _onNavBarTap(int index) {
    setState(() {
      _currentNavIndex = index;
    });

    // Navigation vers les autres pages
    switch (index) {
      case 1: // Quiz
      // Navigator.pushNamed(context, '/quiz');
        break;
      case 2: // Vidéos
      // Navigator.pushNamed(context, '/videos');
        break;
      case 3: // Progression
      // Navigator.pushNamed(context, '/progress');
        break;
      case 4: // Profil
      // Navigator.pushNamed(context, '/profile');
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
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            color: Color(0xFF5B9FD8),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // En-tête avec salutation et niveau
            WelcomeHeader(
              userName: _userData?['prenom'] ?? 'Utilisateur',
              currentLevel: 'Intermédiaire',
              progressPercentage: 65,
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
                        children: const [
                          Text(
                            'Votre niveau a été évalué à : Intermédiaire',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF2D3436),
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Continuez avec le quiz de Mathématiques recommandé !',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF636E72),
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

            // Statistiques
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: StatsGrid(
                xp: 1240,
                quizCompleted: 23,
                studyTime: '12h',
              ),
            ),

            const SizedBox(height: 32),

            // Section Quiz recommandés
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: SectionHeader(
                title: 'Quiz recommandés',
                onSeeAllTap: () {
                  // Navigation vers la page des quiz
                },
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
                title: 'Vidéos récentes',
                onSeeAllTap: () {
                  // Navigation vers la page des vidéos
                },
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

            const SizedBox(height: 100), // Espace pour la bottom nav
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: _currentNavIndex,
        onTap: _onNavBarTap,
      ),
    );
  }
}