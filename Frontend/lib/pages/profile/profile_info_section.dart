import 'package:flutter/material.dart';
import '../../models/profile_model.dart';
import '../../l10n/app_localizations.dart';

/// Widget pour afficher les informations personnelles du profil
class ProfileInfoSection extends StatelessWidget {
  final ProfileModel profile;
  final VoidCallback onEditPressed;

  const ProfileInfoSection({
    super.key,
    required this.profile,
    required this.onEditPressed,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.personalInfo,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
              IconButton(
                onPressed: onEditPressed,
                icon: Icon(
                  Icons.edit,
                  color: Theme.of(context).colorScheme.primary,
                ),
                tooltip: l10n.editButton,
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoItem(
            context,
            icon: Icons.person_outline,
            label: l10n.lastName,
            value: profile.nom,
          ),
          const SizedBox(height: 16),
          _buildInfoItem(
            context,
            icon: Icons.person_outline,
            label: l10n.firstName,
            value: profile.prenom,
          ),
          const SizedBox(height: 16),
          _buildInfoItem(
            context,
            icon: Icons.email_outlined,
            label: l10n.email,
            value: profile.email,
          ),
          const SizedBox(height: 16),
          _buildInfoItem(
            context,
            icon: Icons.school_outlined,
            label: l10n.educationLevel,
            value: profile.niveau,
          ),
        ],
      ),
    );
  }

  /// Widget pour un élément d'information
  Widget _buildInfoItem(
      BuildContext context, {
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