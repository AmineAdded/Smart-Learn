import 'package:flutter/material.dart';
import '../../services/quiz_service.dart';
import '../../models/quiz_model.dart';
import '../../l10n/app_localizations.dart';

class QuizzesPage extends StatefulWidget {
  const QuizzesPage({super.key});

  @override
  State<QuizzesPage> createState() => _QuizzesPageState();
}

class _QuizzesPageState extends State<QuizzesPage> {
  final _quizService = QuizService();

  List<QuizModel> _quizzes = [];
  List<String> _categories = [];
  bool _isLoading = true;
  String? _errorMessage;

  // Filtres
  String? _selectedCategory;
  String? _selectedDifficulty;
  bool _showOnlyAI = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Charger les catégories
      final categoriesResult = await _quizService.getCategories();
      if (categoriesResult['success']) {
        _categories = categoriesResult['data'];
      }

      // Charger les quiz
      await _loadQuizzes();
    } catch (e) {
      setState(() {
        _errorMessage = 'Erreur lors du chargement';
        _isLoading = false;
      });
    }
  }

  Future<void> _loadQuizzes() async {
    final result = await _quizService.getQuizzes(
      category: _selectedCategory,
      difficulty: _selectedDifficulty,
      hasAI: _showOnlyAI ? true : null,
    );

    setState(() {
      _isLoading = false;
      if (result['success']) {
        _quizzes = result['data'];
      } else {
        _errorMessage = result['message'];
      }
    });
  }

  void _applyFilters() {
    _loadQuizzes();
  }

  void _resetFilters() {
    setState(() {
      _selectedCategory = null;
      _selectedDifficulty = null;
      _showOnlyAI = false;
    });
    _loadQuizzes();
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: const Color(0xFF5B9FD8),
        elevation: 0,
        title: Text(
          'Quiz disponibles',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list, color: Colors.white),
            onPressed: _showFilterBottomSheet,
          ),
        ],
      ),
      body: _buildBody(),
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
              onPressed: _loadData,
              child: const Text('Réessayer'),
            ),
          ],
        ),
      );
    }

    if (_quizzes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.quiz, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text('Aucun quiz disponible'),
            const SizedBox(height: 8),
            TextButton(
              onPressed: _resetFilters,
              child: const Text('Réinitialiser les filtres'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadQuizzes,
      color: const Color(0xFF5B9FD8),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _quizzes.length,
        itemBuilder: (context, index) {
          final quiz = _quizzes[index];
          return _buildQuizCard(quiz);
        },
      ),
    );
  }

  Widget _buildQuizCard(QuizModel quiz) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            // TODO: Naviguer vers les détails du quiz
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Quiz: ${quiz.title}')),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // En-tête avec badges
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        quiz.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (quiz.hasAI)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF6C5CE7).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          children: const [
                            Icon(
                              Icons.auto_awesome,
                              size: 12,
                              color: Color(0xFF6C5CE7),
                            ),
                            SizedBox(width: 4),
                            Text(
                              'IA',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF6C5CE7),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 8),

                // Description
                if (quiz.description.isNotEmpty)
                  Text(
                    quiz.description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                const SizedBox(height: 12),

                // Informations
                Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  children: [
                    _buildInfoChip(
                      Icons.category,
                      quiz.category,
                      const Color(0xFF5B9FD8),
                    ),
                    _buildInfoChip(
                      Icons.quiz,
                      '${quiz.questionCount} questions',
                      Colors.grey,
                    ),
                    _buildInfoChip(
                      Icons.timer,
                      '${quiz.durationMinutes} min',
                      Colors.grey,
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: _getDifficultyColor(quiz.difficulty)
                            .withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        quiz.difficulty,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: _getDifficultyColor(quiz.difficulty),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // XP et statut
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.emoji_events,
                          size: 16,
                          color: Color(0xFFFDB33F),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '+${quiz.xpReward} XP',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFFFDB33F),
                          ),
                        ),
                      ],
                    ),
                    if (quiz.isCompleted == true)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF00B894).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.check_circle,
                              size: 14,
                              color: Color(0xFF00B894),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Complété ${quiz.userBestScore}%',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF00B894),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: color,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _buildFilterSheet(),
    );
  }

  Widget _buildFilterSheet() {
    return StatefulBuilder(
      builder: (context, setModalState) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Filtres',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      setModalState(() {
                        _selectedCategory = null;
                        _selectedDifficulty = null;
                        _showOnlyAI = false;
                      });
                    },
                    child: const Text('Réinitialiser'),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Catégorie
              const Text(
                'Catégorie',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                hint: const Text('Toutes les catégories'),
                items: _categories.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (value) {
                  setModalState(() => _selectedCategory = value);
                },
              ),

              const SizedBox(height: 16),

              // Difficulté
              const Text(
                'Difficulté',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedDifficulty,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                hint: const Text('Tous les niveaux'),
                items: ['Facile', 'Moyen', 'Difficile'].map((diff) {
                  return DropdownMenuItem(
                    value: diff,
                    child: Text(diff),
                  );
                }).toList(),
                onChanged: (value) {
                  setModalState(() => _selectedDifficulty = value);
                },
              ),

              const SizedBox(height: 16),

              // IA uniquement
              CheckboxListTile(
                value: _showOnlyAI,
                onChanged: (value) {
                  setModalState(() => _showOnlyAI = value ?? false);
                },
                title: const Text('Quiz avec IA uniquement'),
                activeColor: const Color(0xFF5B9FD8),
                contentPadding: EdgeInsets.zero,
              ),

              const SizedBox(height: 24),

              // Bouton appliquer
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _selectedCategory = _selectedCategory;
                      _selectedDifficulty = _selectedDifficulty;
                      _showOnlyAI = _showOnlyAI;
                    });
                    Navigator.pop(context);
                    _applyFilters();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5B9FD8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Appliquer les filtres',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}