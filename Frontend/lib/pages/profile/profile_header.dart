import 'package:flutter/material.dart';
import '../../models/profile_model.dart';

/// Widget pour afficher l'en-tête du profil avec l'avatar et le nom
class ProfileHeader extends StatelessWidget {
  final ProfileModel profile;

  const ProfileHeader({
    Key? key,
    required this.profile,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16), // 🔧 FIX: Réduit de 24 à 16
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF5B9FD8),
            Color(0xFF4A8BC2),
          ],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min, // 🔧 FIX: Important!
        children: [
          // Avatar circulaire avec initiales
          Container(
            width: 90, // 🔧 FIX: Réduit de 100 à 90
            height: 90, // 🔧 FIX: Réduit de 100 à 90
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Text(
                _getInitials(),
                style: const TextStyle(
                  fontSize: 32, // 🔧 FIX: Réduit de 36 à 32
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF5B9FD8),
                ),
              ),
            ),
          ),

          const SizedBox(height: 12), // 🔧 FIX: Réduit de 16 à 12

          // Nom complet
          Text(
            profile.fullName,
            style: const TextStyle(
              fontSize: 22, // 🔧 FIX: Réduit de 24 à 22
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            maxLines: 1, // 🔧 FIX: Limite à une ligne
            overflow: TextOverflow.ellipsis, // 🔧 FIX: Ellipsis si trop long
          ),

          const SizedBox(height: 4),

          // Email
          Text(
            profile.email,
            style: TextStyle(
              fontSize: 13, // 🔧 FIX: Réduit de 14 à 13
              color: Colors.white.withOpacity(0.9),
            ),
            maxLines: 1, // 🔧 FIX: Limite à une ligne
            overflow: TextOverflow.ellipsis, // 🔧 FIX: Ellipsis si trop long
          ),

          const SizedBox(height: 10), // 🔧 FIX: Réduit de 12 à 10

          // Badge du niveau
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 14, // 🔧 FIX: Réduit de 16 à 14
              vertical: 7, // 🔧 FIX: Réduit de 8 à 7
            ),
            decoration: BoxDecoration(
              color: const Color(0xFFFDB33F),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.school,
                  size: 15, // 🔧 FIX: Réduit de 16 à 15
                  color: Colors.white,
                ),
                const SizedBox(width: 6),
                Text(
                  profile.niveau,
                  style: const TextStyle(
                    fontSize: 13, // 🔧 FIX: Réduit de 14 à 13
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Obtenir les initiales du prénom et du nom
  String _getInitials() {
    String initials = '';
    if (profile.prenom.isNotEmpty) {
      initials += profile.prenom[0].toUpperCase();
    }
    if (profile.nom.isNotEmpty) {
      initials += profile.nom[0].toUpperCase();
    }
    return initials;
  }
}