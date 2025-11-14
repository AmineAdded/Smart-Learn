import 'package:flutter/material.dart';
import '../models/profile_model.dart';
import '../services/profile_service.dart';
import 'profile/profile_header.dart';
import 'profile/profile_info_section.dart';
import 'profile/profile_edit_dialog.dart';
import 'profile/profile_password_dialog.dart';

/// Page principale du profil utilisateur
/// Affiche les informations et permet la modification
class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // Service pour gérer les opérations du profil
  final _profileService = ProfileService();

  // Modèle du profil (nullable car pas encore chargé au départ)
  ProfileModel? _profile;

  // État de chargement
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // Charger le profil dès le démarrage de la page
    _loadProfile();
  }

  /// Méthode asynchrone pour charger le profil depuis le serveur
  Future<void> _loadProfile() async {
    setState(() => _isLoading = true);

    // await : attend que la requête se termine
    final result = await _profileService.getProfile();

    if (!mounted) return; // Vérifier que le widget est toujours affiché

    if (result['success']) {
      setState(() {
        // Récupérer le ProfileModel depuis le résultat
        _profile = result['profile'] as ProfileModel;
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
      _showErrorSnackBar(result['message']);
    }
  }

  /// Ouvrir le dialogue de modification du profil
  Future<void> _openEditDialog() async {
    if (_profile == null) return;

    // Afficher le dialogue et attendre le résultat
    final result = await showDialog<ProfileModel>(
      context: context,
      builder: (context) => ProfileEditDialog(profile: _profile!),
    );

    // Si l'utilisateur a validé les modifications
    if (result != null) {
      setState(() {
        _profile = result; // Mettre à jour le profil affiché
      });
      _showSuccessSnackBar('Profil mis à jour avec succès');
    }
  }

  /// Ouvrir le dialogue de changement de mot de passe
  Future<void> _openPasswordDialog() async {
    // Afficher le dialogue et attendre le résultat
    final success = await showDialog<bool>(
      context: context,
      builder: (context) => const ProfilePasswordDialog(),
    );

    if (success == true) {
      _showSuccessSnackBar('Mot de passe modifié avec succès');
    }
  }

  /// Afficher un message d'erreur
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Afficher un message de succès
  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Mon Profil'),
        backgroundColor: const Color(0xFF5B9FD8),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(
        child: CircularProgressIndicator(
          color: Color(0xFF5B9FD8),
        ),
      )
          : _profile == null
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            const Text('Impossible de charger le profil'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadProfile,
              child: const Text('Réessayer'),
            ),
          ],
        ),
      )
          : RefreshIndicator(
        onRefresh: _loadProfile,
        color: const Color(0xFF5B9FD8),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              // En-tête avec avatar et nom
              ProfileHeader(profile: _profile!),

              const SizedBox(height: 24),

              // Section : Informations personnelles
              ProfileInfoSection(
                profile: _profile!,
                onEditPressed: _openEditDialog,
              ),

              const SizedBox(height: 16),

              // Section : Changer le mot de passe
              _buildPasswordSection(),

              const SizedBox(height: 16),

              // Section : Informations du compte
              _buildAccountInfoSection(),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  /// Widget pour la section de changement de mot de passe
  Widget _buildPasswordSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
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
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 12,
        ),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFF6C5CE7).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.lock_outline,
            color: Color(0xFF6C5CE7),
          ),
        ),
        title: const Text(
          'Changer le mot de passe',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: const Text(
          'Sécurisez votre compte',
          style: TextStyle(fontSize: 13),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: _openPasswordDialog,
      ),
    );
  }

  /// Widget pour les informations du compte
  Widget _buildAccountInfoSection() {
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
          const Text(
            'Informations du compte',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D3436),
            ),
          ),
          const SizedBox(height: 16),
          _buildInfoRow(
            icon: Icons.badge_outlined,
            label: 'Rôle',
            value: _profile!.role,
          ),
          const Divider(height: 24),
          _buildInfoRow(
            icon: Icons.calendar_today,
            label: 'Membre depuis',
            value: _profile!.createdAt,
          ),
        ],
      ),
    );
  }

  /// Widget pour une ligne d'information
  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 12),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2D3436),
          ),
        ),
      ],
    );
  }
}