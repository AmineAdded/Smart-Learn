import 'package:flutter/material.dart';
import '../models/profile_model.dart';
import '../services/profile_service.dart';
import '../l10n/app_localizations.dart';
import 'interests_selection_screen.dart';
import 'profile/profile_header.dart';
import 'profile/profile_info_section.dart';
import 'profile/profile_edit_dialog.dart';
import 'profile/profile_password_dialog.dart';

/// Page du profil utilisateur - Informations personnelles uniquement
/// Les statistiques ont été déplacées vers ProgressionPage
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _profileService = ProfileService();

  ProfileModel? _profile;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
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
      final l10n = AppLocalizations.of(context)!;
      setState(() => _profile = result);
      _showSuccessSnackBar(l10n.profileUpdatedSuccess);
    }
  }

  /// Ouvrir le dialogue de changement de mot de passe
  Future<void> _openPasswordDialog() async {
    final success = await showDialog<bool>(
      context: context,
      builder: (context) => const ProfilePasswordDialog(),
    );

    if (success == true) {
      final l10n = AppLocalizations.of(context)!;
      _showSuccessSnackBar(l10n.passwordChangedSuccess);
    }
  }

  Future<void> _openInterestsManagement() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const InterestsSelectionScreen(),
      ),
    );
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
    final l10n = AppLocalizations.of(context)!;

    if (_isLoading) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: const Center(
          child: CircularProgressIndicator(color: Color(0xFF5B9FD8)),
        ),
      );
    }

    if (_profile == null) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(l10n.unableToLoadProfile),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadProfile,
                child: Text(l10n.retryButton),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        title: Text(
          l10n.myProfileTitle,
          style: Theme.of(context).appBarTheme.titleTextStyle?.copyWith(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Theme.of(context).appBarTheme.iconTheme?.color,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.settings,
              color: Theme.of(context).appBarTheme.iconTheme?.color,
            ),
            onPressed: () {
              Navigator.pushNamed(context, '/settings');
            },
            tooltip: l10n.settings,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadProfile,
        color: Theme.of(context).colorScheme.primary,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              // En-tête avec avatar
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(32),
                    bottomRight: Radius.circular(32),
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
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
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _profile!.fullName,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _profile!.email,
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.9),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.tertiary,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.school,
                            size: 16,
                            color: Theme.of(context).colorScheme.onTertiary,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            _profile!.niveau,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).colorScheme.onTertiary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

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
            const SizedBox(height: 16),

            // NOUVELLE SECTION : Gérer mes intérêts
            _buildInterestsSection(),

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

  /// Obtenir les initiales du prénom et du nom
  String _getInitials() {
    String initials = '';
    if (_profile!.prenom.isNotEmpty) {
      initials += _profile!.prenom[0].toUpperCase();
    }
    if (_profile!.nom.isNotEmpty) {
      initials += _profile!.nom[0].toUpperCase();
    }
    return initials;
  }

  Widget _buildPasswordSection() {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
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
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 12,
        ),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.secondary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.lock_outline,
            color: Theme.of(context).colorScheme.secondary,
          ),
        ),
        title: Text(
          l10n.changePasswordTitle,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          l10n.secureYourAccount,
          style: const TextStyle(fontSize: 13),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: _openPasswordDialog,
      ),
    );
  }

  Widget _buildInterestsSection() {
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
            color: const Color(0xFF00B894).withOpacity(0.1), // Vert sympa pour les intérêts
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.favorite_border,
            color: Color(0xFF00B894),
          ),
        ),
        title: const Text(
          'Gérer mes intérêts',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        subtitle: const Text(
          'Choisissez les sujets qui vous passionnent',
          style: TextStyle(fontSize: 13),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: _openInterestsManagement,
      ),
    );
  }

  Widget _buildAccountInfoSection() {
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
          Text(
            l10n.accountInformation,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
          const SizedBox(height: 16),
          _buildInfoRow(
            icon: Icons.badge_outlined,
            label: l10n.role,
            value: _profile!.role,
          ),
          const Divider(height: 24),
          _buildInfoRow(
            icon: Icons.calendar_today,
            label: l10n.memberSince,
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
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
      ],
    );
  }
}