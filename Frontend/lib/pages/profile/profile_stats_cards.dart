import 'package:flutter/material.dart';

/// Grille de cartes de statistiques
class ProfileStatsCards extends StatelessWidget {
  final int totalXp;
  final int quizCompleted;
  final double successRate;
  final String studyTime;
  final int currentStreak;
  final int videosWatched;

  const ProfileStatsCards({
    Key? key,
    required this.totalXp,
    required this.quizCompleted,
    required this.successRate,
    required this.studyTime,
    required this.currentStreak,
    required this.videosWatched,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Statistiques',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2D3436),
          ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 1.3,
          children: [
            _StatCard(
              icon: Icons.emoji_events,
              value: totalXp.toString(),
              label: 'XP Total',
              color: const Color(0xFFFDB33F),
            ),
            _StatCard(
              icon: Icons.quiz,
              value: quizCompleted.toString(),
              label: 'Quiz complétés',
              color: const Color(0xFF5B9FD8),
            ),
            _StatCard(
              icon: Icons.trending_up,
              value: '${successRate.toStringAsFixed(0)}%',
              label: 'Taux de réussite',
              color: const Color(0xFF00B894),
            ),
            _StatCard(
              icon: Icons.access_time,
              value: studyTime,
              label: 'Temps d\'étude',
              color: const Color(0xFF6C5CE7),
            ),
            _StatCard(
              icon: Icons.local_fire_department,
              value: currentStreak.toString(),
              label: 'Jours consécutifs',
              color: const Color(0xFFE17055),
            ),
            _StatCard(
              icon: Icons.video_library,
              value: videosWatched.toString(),
              label: 'Vidéos vues',
              color: const Color(0xFFE84393),
            ),
          ],
        ),
      ],
    );
  }
}

/// Carte de statistique individuelle
class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10), // 🔧 FIX: Réduit de 16 à 10
      decoration: BoxDecoration(
        color: Colors.white,
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
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min, // 🔧 FIX: Important !
        children: [
          Container(
            padding: const EdgeInsets.all(8), // 🔧 FIX: Réduit de 12 à 8
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24), // 🔧 FIX: Réduit de 28 à 24
          ),
          const SizedBox(height: 8), // 🔧 FIX: Réduit de 12 à 8
          Text(
            value,
            style: const TextStyle(
              fontSize: 18, // 🔧 FIX: Réduit de 22 à 18
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D3436),
            ),
            maxLines: 1, // 🔧 FIX: Limite à une ligne
            overflow: TextOverflow.ellipsis, // 🔧 FIX: Ellipsis si trop long
          ),
          const SizedBox(height: 2), // 🔧 FIX: Réduit de 4 à 2
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11, // 🔧 FIX: Réduit de 12 à 11
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
            maxLines: 2, // 🔧 FIX: Limite à 2 lignes
            overflow: TextOverflow.ellipsis, // 🔧 FIX: Ellipsis si trop long
          ),
        ],
      ),
    );
  }
}