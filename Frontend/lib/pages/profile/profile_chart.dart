// lib/pages/profile/profile_chart.dart
import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';

class ProfileWeeklyChart extends StatelessWidget {
  final Map<String, dynamic> weeklyData;

  const ProfileWeeklyChart({
    super.key,
    required this.weeklyData,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    // Debug: Afficher toutes les données reçues
    print('=== CHART DEBUG - DONNÉES REÇUES ===');
    print('Weekly Data complet: $weeklyData');

    final currentWeekXp = weeklyData['currentWeekXp'] ?? 0;
    final lastWeekXp = weeklyData['lastWeekXp'] ?? 0;
    final changePercentage = (weeklyData['changePercentage'] ?? 0).toDouble();
    final dailyProgress = (weeklyData['dailyProgress'] as List? ?? [])
        .cast<Map<String, dynamic>>();

    print('currentWeekXp: $currentWeekXp');
    print('lastWeekXp: $lastWeekXp');
    print('changePercentage: $changePercentage');
    print('dailyProgress length: ${dailyProgress.length}');

    // Afficher chaque jour
    for (var i = 0; i < dailyProgress.length; i++) {
      final day = dailyProgress[i];
      print('Jour $i: ${day['day']} - ${day['xpEarned']} XP - hasActivity: ${day['hasActivity']}');
    }

    // Calculer le maxXp
    int maxXp = 0;
    if (dailyProgress.isNotEmpty) {
      final xpValues = dailyProgress.map((d) => (d['xpEarned'] ?? 0) as int).toList();
      maxXp = xpValues.reduce((a, b) => a > b ? a : b);
    }

    print('maxXp calculé: $maxXp');
    print('===================================');

    // Si dailyProgress est vide, afficher un message
    if (dailyProgress.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.weeklyProgressLabel,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D3436),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(20),
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
            child: Center(
              child: Column(
                children: [
                  Icon(Icons.info_outline, size: 48, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'Aucune donnée de progression pour cette semaine',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Text(
                l10n.weeklyProgressLabel,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D3436),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: changePercentage >= 0
                    ? const Color(0xFF00B894).withOpacity(0.1)
                    : const Color(0xFFE74C3C).withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    changePercentage >= 0 ? Icons.trending_up : Icons.trending_down,
                    size: 16,
                    color: changePercentage >= 0
                        ? const Color(0xFF00B894)
                        : const Color(0xFFE74C3C),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${changePercentage.abs().toStringAsFixed(0)}%',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: changePercentage >= 0
                          ? const Color(0xFF00B894)
                          : const Color(0xFFE74C3C),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        Container(
          padding: const EdgeInsets.all(20),
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
            children: [
              // En-tête avec les totaux
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      Text(
                        l10n.thisWeek,
                        style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$currentWeekXp XP',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF5B9FD8),
                        ),
                      ),
                    ],
                  ),
                  Container(width: 1, height: 40, color: Colors.grey[300]),
                  Column(
                    children: [
                      Text(
                        l10n.lastWeek,
                        style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$lastWeekXp XP',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[400]!,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Le graphique
              SizedBox(
                height: 150,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: dailyProgress.map((day) {
                    final xp = (day['xpEarned'] ?? 0) as int;
                    final dayLabel = (day['day'] ?? '') as String;
                    final hasActivity = (day['hasActivity'] ?? false) as bool;

                    // Calculer la hauteur de la barre
                    double barHeight;
                    if (maxXp == 0) {
                      // Si aucun XP cette semaine, toutes les barres à 0
                      barHeight = 0.0;
                    } else {
                      // Hauteur proportionnelle avec minimum de 20 si hasActivity
                      barHeight = (xp / maxXp) * 120;
                      if (hasActivity && barHeight < 20) {
                        barHeight = 20.0;
                      }
                    }

                    print('🎨 Rendu barre $dayLabel: xp=$xp, height=$barHeight, hasActivity=$hasActivity');

                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            // Afficher l'XP au-dessus de la barre si > 0
                            if (xp > 0) ...[
                              Text(
                                '$xp',
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF5B9FD8),
                                ),
                              ),
                              const SizedBox(height: 4),
                            ],
                            // La barre elle-même
                            Container(
                              height: barHeight.clamp(0.0, 120.0),
                              decoration: BoxDecoration(
                                gradient: hasActivity
                                    ? const LinearGradient(
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                  colors: [Color(0xFF5B9FD8), Color(0xFF4A8BC2)],
                                )
                                    : null,
                                color: hasActivity ? null : Colors.grey[200],
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(6),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            // Label du jour
                            Text(
                              dayLabel,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: hasActivity
                                    ? const Color(0xFF2D3436)
                                    : Colors.grey[400],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}