import 'dart:async';
import 'package:flutter/material.dart';
import '../../services/quiz_session_service.dart';
import '../../models/quiz_session_model.dart';

class QuizPlayPage extends StatefulWidget {
  final int quizId;
  final int? sessionId; // null si nouvelle session

  const QuizPlayPage({
    super.key,
    required this.quizId,
    this.sessionId,
  });

  @override
  State<QuizPlayPage> createState() => _QuizPlayPageState();
}

class _QuizPlayPageState extends State<QuizPlayPage> {
  final _sessionService = QuizSessionService();

  QuizSessionModel? _session;
  bool _isLoading = true;
  String? _errorMessage;

  int _currentQuestionIndex = 0;
  String? _selectedAnswer;
  bool _showFeedback = false;
  AnswerFeedbackModel? _currentFeedback;

  // Chronomètre
  Timer? _timer;
  int _elapsedSeconds = 0;
  int _questionStartTime = 0;

  @override
  void initState() {
    super.initState();
    _initializeQuiz();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _initializeQuiz() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final result = widget.sessionId != null
        ? await _sessionService.resumeQuiz(widget.sessionId!)
        : await _sessionService.startQuiz(widget.quizId);

    setState(() {
      _isLoading = false;
      if (result['success']) {
        _session = result['data'];
        _currentQuestionIndex = _session!.currentQuestionIndex;
        _elapsedSeconds = _session!.timeSpentSeconds;
        _startTimer();
      } else {
        _errorMessage = result['message'];
      }
    });
  }

  void _startTimer() {
    _questionStartTime = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _elapsedSeconds++;
      });

      // Vérifier l'expiration
      if (_session!.expiresAt != null &&
          DateTime.now().isAfter(_session!.expiresAt!)) {
        _handleTimeout();
      }
    });
  }

  void _handleTimeout() {
    _timer?.cancel();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Le temps est écoulé !'),
        backgroundColor: Colors.red,
      ),
    );
    _completeQuiz();
  }

  Future<void> _submitAnswer() async {
    if (_selectedAnswer == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez sélectionner une réponse')),
      );
      return;
    }

    final currentQuestion = _session!.questions[_currentQuestionIndex];
    final questionTime =
        (DateTime.now().millisecondsSinceEpoch ~/ 1000) - _questionStartTime;

    final result = await _sessionService.submitAnswer(
      sessionId: _session!.sessionId,
      questionId: currentQuestion.id,
      answer: _selectedAnswer!,
      timeSpentSeconds: questionTime,
    );

    if (result['success']) {
      setState(() {
        _currentFeedback = result['data'];
        _showFeedback = true;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'])),
      );
    }
  }

  void _nextQuestion() {
    setState(() {
      _showFeedback = false;
      _selectedAnswer = null;
      _currentFeedback = null;

      if (_currentQuestionIndex < _session!.questions.length - 1) {
        _currentQuestionIndex++;
        _questionStartTime = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      } else {
        _completeQuiz();
      }
    });
  }

  Future<void> _completeQuiz() async {
    _timer?.cancel();

    final result = await _sessionService.completeQuiz(_session!.sessionId);

    if (result['success']) {
      // Navigation vers la page de résultats
      if (mounted) {
        Navigator.pushReplacementNamed(
          context,
          '/quiz-results',
          arguments: result['data'],
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'])),
      );
    }
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        final shouldExit = await _showExitDialog();
        return shouldExit ?? false;
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: _buildAppBar(),
        body: _buildBody(),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFF5B9FD8),
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () async {
          final shouldExit = await _showExitDialog();
          if (shouldExit == true && mounted) {
            Navigator.pop(context);
          }
        },
      ),
      title: Text(
        _session?.quizTitle ?? 'Quiz',
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      actions: [
        // Chronomètre
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          margin: const EdgeInsets.only(right: 16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              const Icon(Icons.timer, size: 20, color: Colors.white),
              const SizedBox(width: 8),
              Text(
                _formatTime(_elapsedSeconds),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ],
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
              onPressed: _initializeQuiz,
              child: const Text('Réessayer'),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        _buildProgressBar(),
        Expanded(
          child: _showFeedback ? _buildFeedback() : _buildQuestion(),
        ),
        _buildBottomBar(),
      ],
    );
  }

  Widget _buildProgressBar() {
    final progress =
        (_currentQuestionIndex + 1) / _session!.questions.length;

    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Question ${_currentQuestionIndex + 1}/${_session!.questions.length}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (_currentFeedback != null)
                Text(
                  'Score: ${_currentFeedback!.currentScore} pts',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF5B9FD8),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: Colors.grey[200],
              valueColor:
              const AlwaysStoppedAnimation<Color>(Color(0xFF5B9FD8)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestion() {
    final question = _session!.questions[_currentQuestionIndex];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Question
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
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
                Text(
                  question.questionText,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    height: 1.4,
                  ),
                ),
                if (question.imageUrl != null) ...[
                  const SizedBox(height: 16),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      question.imageUrl!,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 200,
                          color: Colors.grey[200],
                          child: const Center(
                            child: Icon(Icons.broken_image, size: 48),
                          ),
                        );
                      },
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF5B9FD8).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${question.points} pt${question.points > 1 ? 's' : ''}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF5B9FD8),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Options de réponse
          if (question.type.toUpperCase() == 'QCM' ||
              question.type.toUpperCase() == 'MULTIPLE_CHOICE')
            ...question.options!.map((option) => _buildOption(option)),

          if (question.type.toUpperCase() == 'VRAI_FAUX' ||
              question.type.toUpperCase() == 'TRUE_FALSE')
            ...[
              _buildTrueFalseOption('Vrai', 'true'),
              _buildTrueFalseOption('Faux', 'false'),
            ],

          if (question.type.toUpperCase() == 'REPONSE_COURTE' ||
              question.type.toUpperCase() == 'SHORT_ANSWER')
            _buildShortAnswerField(),
        ],
      ),
    );
  }

  Widget _buildOption(AnswerOptionModel option) {
    final isSelected = _selectedAnswer == option.id.toString();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            setState(() {
              _selectedAnswer = option.id.toString();
            });
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isSelected
                  ? const Color(0xFF5B9FD8).withOpacity(0.1)
                  : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? const Color(0xFF5B9FD8)
                    : Colors.grey[300]!,
                width: 2,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFF5B9FD8)
                        : Colors.transparent,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFF5B9FD8)
                          : Colors.grey[400]!,
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      option.optionLetter ?? '',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isSelected ? Colors.white : Colors.grey[600],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    option.optionText,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ),
                if (isSelected)
                  const Icon(
                    Icons.check_circle,
                    color: Color(0xFF5B9FD8),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTrueFalseOption(String label, String value) {
    final isSelected = _selectedAnswer == value;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            setState(() {
              _selectedAnswer = value;
            });
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isSelected
                  ? const Color(0xFF5B9FD8).withOpacity(0.1)
                  : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? const Color(0xFF5B9FD8)
                    : Colors.grey[300]!,
                width: 2,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? const Color(0xFF5B9FD8) : Colors.black87,
                  ),
                ),
                if (isSelected) ...[
                  const SizedBox(width: 8),
                  const Icon(Icons.check_circle, color: Color(0xFF5B9FD8)),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildShortAnswerField() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: TextField(
        onChanged: (value) {
          setState(() {
            _selectedAnswer = value;
          });
        },
        decoration: const InputDecoration(
          hintText: 'Tapez votre réponse ici...',
          border: InputBorder.none,
        ),
        maxLines: 3,
      ),
    );
  }

  Widget _buildFeedback() {
    final feedback = _currentFeedback!;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icône de feedback
            Icon(
              feedback.isCorrect ? Icons.check_circle : Icons.cancel,
              size: 100,
              color: feedback.isCorrect
                  ? const Color(0xFF00B894)
                  : const Color(0xFFE74C3C),
            ),
            const SizedBox(height: 24),

            // Titre
            Text(
              feedback.isCorrect ? 'Bonne réponse !' : 'Incorrect',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: feedback.isCorrect
                    ? const Color(0xFF00B894)
                    : const Color(0xFFE74C3C),
              ),
            ),
            const SizedBox(height: 16),

            // Points gagnés
            Text(
              '+${feedback.pointsEarned} point${feedback.pointsEarned > 1 ? 's' : ''}',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 32),

            // Bonne réponse
            if (!feedback.isCorrect)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF00B894).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFF00B894).withOpacity(0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Bonne réponse :',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF00B894),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      feedback.correctAnswer,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

            // Explication
            if (feedback.explanation != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF5B9FD8).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(
                          Icons.lightbulb_outline,
                          color: Color(0xFF5B9FD8),
                          size: 20,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Explication',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF5B9FD8),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      feedback.explanation!,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 24),

            // Progression
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem(
                    'Questions',
                    '${feedback.questionsAnswered}/${feedback.totalQuestions}',
                    Icons.quiz,
                  ),
                  _buildStatItem(
                    'Score',
                    '${feedback.currentScore} pts',
                    Icons.star,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: const Color(0xFF5B9FD8)),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
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

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
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
            onPressed: _showFeedback ? _nextQuestion : _submitAnswer,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF5B9FD8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Text(
              _showFeedback
                  ? (_currentQuestionIndex < _session!.questions.length - 1
                  ? 'Question suivante'
                  : 'Terminer le quiz')
                  : 'Valider',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<bool?> _showExitDialog() {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Quitter le quiz ?'),
        content: const Text(
          'Votre progression sera sauvegardée et vous pourrez reprendre plus tard.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE74C3C),
            ),
            child: const Text('Quitter'),
          ),
        ],
      ),
    );
  }
}