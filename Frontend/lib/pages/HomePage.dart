import 'package:flutter/material.dart';
import 'package:smart_learn/pages/quizzes/QuizDetailPage.dart';
import 'package:smart_learn/pages/quizzes/QuizzesPage.dart';
import 'package:smart_learn/pages/videos/VideoPlayerPage.dart';
import '../models/quiz_model.dart';
import '../models/video.dart';
import '../services/auth_service.dart';
import '../services/quiz_service.dart';
import '../services/video_service.dart';
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
  final _quizService = QuizService();
  final _videoService = VideoService(); // ✅ NOUVEAU
  int _currentNavIndex = 0;

  Map<String, dynamic>? _userData;
  UserProgress? _userProgress;
  bool _isLoading = true;
  List<QuizModel> _recommendedQuizzes = []; // ✅ NOUVEAU
  List<Video> _recommendedVideos = []; // ✅ NOUVEAU

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
      final quizzesResult = await _quizService.getRecommendedQuizzes();
      final videosResult = await _videoService.getRecommendations();

      setState(() {
        _userData = userData;
        if (progressResult['success']) {
          _userProgress = progressResult['data'];
        }
        if (quizzesResult['success']) {
          _recommendedQuizzes = quizzesResult['data'];
        }
        if (videosResult['success']) {
          _recommendedVideos = videosResult['videos'];
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

  // ✅ NOUVEAU : Navigation vers détail du quiz
  void _handleQuizTap(QuizModel quiz) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => QuizDetailPage(quizId: quiz.id),
      ),
    ).then((_) => _loadAllData());
  }

  // ✅ NOUVEAU : Navigation vers la page complète des quiz
  void _handleSeeAllQuizzes() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const QuizzesPage()),
    ).then((_) => _loadAllData());
  }

  // ✅ NOUVEAU : Navigation vers le lecteur vidéo
  void _handleVideoTap(Video video) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => VideoPlayerPage(video: video),
      ),
    ).then((_) => _loadAllData());
  }

  // ✅ NOUVEAU : Navigation vers la page complète des vidéos
  void _handleSeeAllVideos() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const VideosPage()),
    ).then((_) => _loadAllData());
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

              // ✅ MODIFIÉ : Quiz recommandés dynamiques
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: SectionHeader(
                  title: l10n.recommendedQuizzes,
                  onSeeAllTap: _handleSeeAllQuizzes, // ✅ Navigation vers QuizzesPage
                ),
              ),
              const SizedBox(height: 16),
              // ✅ NOUVEAU : Affichage dynamique ou message si vide
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: _recommendedQuizzes.isEmpty
                    ? _buildEmptyQuizState(l10n)
                    : Column(
                  children: _recommendedQuizzes.map((quiz) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: QuizCard(
                        title: quiz.title,
                        icon: _getQuizIcon(quiz.category),
                        questionCount: quiz.questionCount,
                        difficulty: quiz.difficulty,
                        hasAI: quiz.hasAI,
                        onTap: () => _handleQuizTap(quiz),
                      ),
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 24),

              // ✅ MODIFIÉ : Vidéos récentes dynamiques
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: SectionHeader(
                  title: l10n.recentVideos,
                  onSeeAllTap: _handleSeeAllVideos, // ✅ Navigation vers VideosPage
                ),
              ),
              const SizedBox(height: 16),

              // ✅ NOUVEAU : Affichage dynamique des vidéos
              _recommendedVideos.isEmpty
                  ? Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: _buildEmptyVideosState(l10n),
              )
                  : SizedBox(
                height: 220,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  itemCount: _recommendedVideos.length,
                  itemBuilder: (context, index) {
                    final video = _recommendedVideos[index];
                    return VideoCard(
                      title: video.title,
                      thumbnail: video.thumbnailUrl,
                      duration: video.formattedDuration,
                      isNew: _isNewVideo(video),
                      onTap: () => _handleVideoTap(video),
                    );
                  },
                ),
              ),

              const SizedBox(height: 24),

              // === Nouvelle section : Images ===
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Contenu vedette',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Grille de 3 images
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: _buildImageCard(
                        context,
                        imagePath: 'assets/images/image1.png', // ← Changez le nom selon vos images
                        title: 'Mathématiques',
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Image 1 cliquée')),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildImageCard(
                        context,
                        imagePath: 'assets/images/image2.png',
                        title: 'Physiques',
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Image 2 cliquée')),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildImageCard(
                        context,
                        imagePath: 'assets/images/image3.png',
                        title: 'Francais',
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Image 3 cliquée')),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
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
  // ✅ NOUVEAU : Widget pour état vide
  Widget _buildEmptyQuizState(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        children: [
          Icon(Icons.quiz, size: 48, color: Colors.grey.shade400),
          const SizedBox(height: 12),
          Text(
            'Aucun quiz disponible',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Revenez plus tard pour découvrir de nouveaux quiz',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  // ✅ NOUVEAU : Widget pour état vide des vidéos
  Widget _buildEmptyVideosState(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        children: [
          Icon(Icons.video_library, size: 48, color: Colors.grey.shade400),
          const SizedBox(height: 12),
          Text(
            'Aucune vidéo disponible',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Revenez plus tard pour découvrir de nouvelles vidéos',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  // ✅ NOUVEAU : Vérifier si une vidéo est récente (moins de 7 jours)
  bool _isNewVideo(Video video) {
    if (video.createdAt == null) return false;
    final now = DateTime.now();
    final difference = now.difference(video.createdAt!);
    return difference.inDays < 7;
  }

  // ✅ NOUVEAU : Mapper les catégories aux icônes
  String _getQuizIcon(String category) {
    switch (category.toLowerCase()) {
      case 'mathématiques':
      case 'mathematics':
        return '📐';
      case 'sciences':
      case 'science':
        return '🔬';
      case 'histoire':
      case 'history':
        return '📚';
      case 'géographie':
      case 'geography':
        return '🌍';
      case 'langues':
      case 'languages':
        return '🗣️';
      case 'informatique':
      case 'computer science':
        return '💻';
      case 'physique':
      case 'physics':
        return '⚡';
      case 'chimie':
      case 'chemistry':
        return '⚗️';
      default:
        return '📝';
    }
  }

  Widget _buildImageCard(
      BuildContext context, {
        required String imagePath,
        required String title,
        required VoidCallback onTap,
      }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
              child: Image.asset(
                imagePath,
                height: 120,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  // En cas d'erreur (image non trouvée)
                  return Container(
                    height: 120,
                    color: Colors.grey[300],
                    child: const Icon(
                      Icons.image_not_supported,
                      size: 48,
                      color: Colors.grey,
                    ),
                  );
                },
              ),
            ),
            // Titre
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}