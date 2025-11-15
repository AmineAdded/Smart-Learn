import 'package:flutter/material.dart';

/// Carte affichant le niveau actuel et la progression
class ProfileLevelCard extends StatelessWidget {
  final int currentLevel;
  final String levelTitle;
  final int currentXp;
  final int xpForNextLevel;
  final double progressPercentage;

  const ProfileLevelCard({
    Key? key,
    required this.currentLevel,
    required this.levelTitle,
    required this.currentXp,
    required this.xpForNextLevel,
    required this.progressPercentage,
  }) : super(key: key);

  String _getLevelIcon() {
    if (currentLevel >= 20) return '👑';
    if (currentLevel >= 15) return '🏆';
    if (currentLevel >= 10) return '⭐';
    if (currentLevel >= 5) return '📚';
    return '📖';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF6C5CE7),
            Color(0xFF5F4BC3),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6C5CE7).withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Niveau actuel',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        _getLevelIcon(),
                        style: const TextStyle(fontSize: 32),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Niveau $currentLevel',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            levelTitle,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.white70,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Progression vers niveau ${currentLevel + 1}',
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.white70,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    '${progressPercentage.toStringAsFixed(0)}%',
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: progressPercentage / 100,
                  backgroundColor: Colors.white.withOpacity(0.2),
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    Color(0xFFFDB33F),
                  ),
                  minHeight: 10,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '$currentXp / $xpForNextLevel XP',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.white60,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}