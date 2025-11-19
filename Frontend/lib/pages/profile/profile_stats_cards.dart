import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';

class ProfileStatsCards extends StatelessWidget {
  final int totalXp;
  final int quizCompleted;
  final double successRate;
  final String studyTime;
  final int currentStreak;
  final int videosWatched;

  const ProfileStatsCards({
    super.key,
    required this.totalXp,
    required this.quizCompleted,
    required this.successRate,
    required this.studyTime,
    required this.currentStreak,
    required this.videosWatched,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.statistics,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF2D3436)),
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
            _StatCard(icon: Icons.emoji_events, value: totalXp.toString(), label: l10n.totalXPLabel, color: const Color(0xFFFDB33F)),
            _StatCard(icon: Icons.quiz, value: quizCompleted.toString(), label: l10n.quizzesCompleted, color: const Color(0xFF5B9FD8)),
            _StatCard(icon: Icons.trending_up, value: '${successRate.toStringAsFixed(0)}%', label: l10n.successRateLabel, color: const Color(0xFF00B894)),
            _StatCard(icon: Icons.access_time, value: studyTime, label: l10n.studyTimeLabel, color: const Color(0xFF6C5CE7)),
            _StatCard(icon: Icons.local_fire_department, value: currentStreak.toString(), label: l10n.consecutiveDays, color: const Color(0xFFE17055)),
            _StatCard(icon: Icons.video_library, value: videosWatched.toString(), label: l10n.videosWatchedLabel, color: const Color(0xFFE84393)),
          ],
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _StatCard({required this.icon, required this.value, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2D3436)),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 11, color: Colors.grey[600], fontWeight: FontWeight.w500),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}