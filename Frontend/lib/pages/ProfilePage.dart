import 'package:flutter/material.dart';
import '../models/profile_model.dart';
import '../services/profile_service.dart';
import 'profile/profile_header.dart';
import 'profile/profile_info_section.dart';
import 'profile/profile_edit_dialog.dart';
import 'profile/profile_password_dialog.dart';
import 'profile/profile_stats_tab.dart';

/// Page principale du profil avec système d'onglets
/// Onglet 1 : Informations personnelles
/// Onglet 2 : Statistiques et progression
class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> with SingleTickerProviderStateMixin {
  final _profileService = ProfileService();

  ProfileModel? _profile;
  bool _isLoading = true;

  // Controller pour les onglets
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadProfile();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  /// Charger le profil utilisateur
  Future<void> _loadProfile() async {
    setState(() => _isLoading = true);

    final result = await _profileService.getProfile();

    if (!mounted) return;

    if (result['success']) {
      setState(() {
        _profile = result['profile'] as ProfileModel;
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
      _showErrorSnackBar(result['message']);
    }
  }

  /// Ouvrir le dialogue de modification
  Future<void> _openEditDialog() async {
    if (_profile == null) return;

    final result = await showDialog<ProfileModel>(
      context: context,
      builder: (context) => ProfileEditDialog(profile: _profile!),
    );

    if (result != null) {
      setState(() => _profile = result);
      _showSuccessSnackBar('Profil mis à jour avec succès');
    }
  }

  /// Ouvrir le dialogue de changement de mot de passe
  Future<void> _openPasswordDialog() async {
    final success = await showDialog<bool>(
      context: context,
      builder: (context) => const ProfilePasswordDialog(),
    );

    if (success == true) {
      _showSuccessSnackBar('Mot de passe modifié avec succès');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

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
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Colors.grey[50],
        body: const Center(
          child: CircularProgressIndicator(color: Color(0xFF5B9FD8)),
        ),
      );
    }

    if (_profile == null) {
      return Scaffold(
        backgroundColor: Colors.grey[50],
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              const Text('Impossible de charger le profil'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadProfile,
                child: const Text('Réessayer'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            // AppBar avec onglets
            SliverAppBar(
              expandedHeight: 200,
              floating: false,
              pinned: true,
              backgroundColor: const Color(0xFF5B9FD8),
              flexibleSpace: FlexibleSpaceBar(
                background: ProfileHeader(profile: _profile!),
              ),
              bottom: TabBar(
                controller: _tabController,
                indicatorColor: Colors.white,
                indicatorWeight: 3,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white70,
                labelStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
                tabs: const [
                  Tab(
                    icon: Icon(Icons.person),
                    text: 'Informations',
                  ),
                  Tab(
                    icon: Icon(Icons.bar_chart),
                    text: 'Statistiques',
                  ),
                ],
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            // Onglet 1 : Informations personnelles
            _buildInfoTab(),

            // Onglet 2 : Statistiques
            ProfileStatsTab(),
          ],
        ),
      ),
    );
  }

  /// Onglet des informations personnelles (votre code actuel)
  Widget _buildInfoTab() {
    return RefreshIndicator(
      onRefresh: _loadProfile,
      color: const Color(0xFF5B9FD8),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
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
    );
  }

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
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
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
          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
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