import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';

class ProfileAchievements extends StatelessWidget {
  final List<Map<String, dynamic>> goals;
  final int globalRank;
  final int totalUsers;

  const ProfileAchievements({
    super.key,
    required this.goals,
    required this.globalRank,
    required this.totalUsers,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.goalsAndRanking,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2D3436),
          ),
        ),
        const SizedBox(height: 16),

        // Carte classement global
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFFDB33F), Color(0xFFE9A72F)],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFDB33F).withOpacity(0.3),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                child: const Icon(Icons.emoji_events, color: Color(0xFFFDB33F), size: 32),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.globalRankLabel,
                      style: const TextStyle(fontSize: 14, color: Colors.white70, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '#$globalRank',
                      style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    Text(
                      '${l10n.outOf} $totalUsers ${l10n.questions}', // "sur X utilisateurs"
                      style: const TextStyle(fontSize: 12, color: Colors.white70),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Objectifs
        ...goals.map((goal) => _GoalCard(
          title: goal['title'] ?? '',
          description: goal['description'] ?? '',
          current: goal['current'] ?? 0,
          target: goal['target'] ?? 100,
          progress: (goal['progress'] ?? 0).toDouble(),
          completed: goal['completed'] ?? false,
        )),
      ],
    );
  }
}

class _GoalCard extends StatelessWidget {
  final String title;
  final String description;
  final int current;
  final int target;
  final double progress;
  final bool completed;

  const _GoalCard({
    required this.title,
    required this.description,
    required this.current,
    required this.target,
    required this.progress,
    required this.completed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: completed ? const Color(0xFF00B894) : Colors.grey[200]!,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                completed ? Icons.check_circle : Icons.radio_button_unchecked,
                color: completed ? const Color(0xFF00B894) : Colors.grey[400],
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: completed ? const Color(0xFF00B894) : const Color(0xFF2D3436),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(description, style: TextStyle(fontSize: 13, color: Colors.grey[600])),
                  ],
                ),
              ),
              Text(
                '$current/$target',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey[700]),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: (progress / 100).clamp(0.0, 1.0),
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(
                completed ? const Color(0xFF00B894) : const Color(0xFF5B9FD8),
              ),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }
}