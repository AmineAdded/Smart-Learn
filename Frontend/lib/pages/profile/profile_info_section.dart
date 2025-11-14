import 'package:flutter/material.dart';
import '../../models/profile_model.dart';

/// Widget pour afficher les informations personnelles du profil
class ProfileInfoSection extends StatelessWidget {
  final ProfileModel profile;
  final VoidCallback onEditPressed;

  const ProfileInfoSection({
    Key? key,
    required this.profile,
    required this.onEditPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Titre avec bouton modifier
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Informations personnelles',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D3436),
                ),
              ),
              IconButton(
                onPressed: onEditPressed,
                icon: const Icon(
                  Icons.edit,
                  color: Color(0xFF5B9FD8),
                ),
                tooltip: 'Modifier',
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Nom
          _buildInfoItem(
            icon: Icons.person_outline,
            label: 'Nom',
            value: profile.nom,
          ),

          const SizedBox(height: 16),

          // Prénom
          _buildInfoItem(
            icon: Icons.person_outline,
            label: 'Prénom',
            value: profile.prenom,
          ),

          const SizedBox(height: 16),

          // Email
          _buildInfoItem(
            icon: Icons.email_outlined,
            label: 'Email',
            value: profile.email,
          ),

          const SizedBox(height: 16),

          // Niveau
          _buildInfoItem(
            icon: Icons.school_outlined,
            label: 'Niveau d\'études',
            value: profile.niveau,
          ),
        ],
      ),
    );
  }

  /// Widget pour un élément d'information
  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 20,
          color: Colors.grey[600],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF2D3436),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}