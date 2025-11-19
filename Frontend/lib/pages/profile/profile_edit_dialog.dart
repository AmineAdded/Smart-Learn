import 'package:flutter/material.dart';
import '../../models/profile_model.dart';
import '../../services/profile_service.dart';
import '../../../l10n/app_localizations.dart';

class ProfileEditDialog extends StatefulWidget {
  final ProfileModel profile;

  const ProfileEditDialog({super.key, required this.profile});

  @override
  State<ProfileEditDialog> createState() => _ProfileEditDialogState();
}

class _ProfileEditDialogState extends State<ProfileEditDialog> {
  final _formKey = GlobalKey<FormState>();
  final _profileService = ProfileService();

  late TextEditingController _nomController;
  late TextEditingController _prenomController;
  late TextEditingController _emailController;

  String? _selectedNiveau;
  bool _isLoading = false;

  final List<String> _niveaux = [
    'Collège', 'Lycée', 'Université', 'Formation continue', 'Autodidacte',
  ];

  @override
  void initState() {
    super.initState();
    _nomController = TextEditingController(text: widget.profile.nom);
    _prenomController = TextEditingController(text: widget.profile.prenom);
    _emailController = TextEditingController(text: widget.profile.email);
    _selectedNiveau = widget.profile.niveau;
  }

  @override
  void dispose() {
    _nomController.dispose();
    _prenomController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final result = await _profileService.updateProfile(
      nom: _nomController.text.trim(),
      prenom: _prenomController.text.trim(),
      email: _emailController.text.trim(),
      niveau: _selectedNiveau!,
    );

    setState(() => _isLoading = false);

    if (!mounted) return;

    if (result['success']) {
      Navigator.of(context).pop(result['profile'] as ProfileModel);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.profileUpdatedSuccess), backgroundColor: Colors.green),
      );
    } else {
      _showErrorSnackBar(result['message']);
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red, behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.edit, color: Color(0xFF5B9FD8), size: 28),
                      const SizedBox(width: 12),
                      Text(l10n.editProfile, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF2D3436))),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Nom
                  TextFormField(
                    controller: _nomController,
                    enabled: !_isLoading,
                    decoration: InputDecoration(
                      labelText: l10n.lastName,
                      prefixIcon: const Icon(Icons.person_outline),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    validator: (value) => value?.isEmpty ?? true ? l10n.emailRequired : null,
                  ),
                  const SizedBox(height: 16),

                  // Prénom
                  TextFormField(
                    controller: _prenomController,
                    enabled: !_isLoading,
                    decoration: InputDecoration(
                      labelText: l10n.firstName,
                      prefixIcon: const Icon(Icons.person_outline),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    validator: (value) => value?.isEmpty ?? true ? l10n.emailRequired : null,
                  ),
                  const SizedBox(height: 16),

                  // Email
                  TextFormField(
                    controller: _emailController,
                    enabled: !_isLoading,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: l10n.email,
                      prefixIcon: const Icon(Icons.email_outlined),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) return l10n.emailRequired;
                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                        return l10n.invalidEmail;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Niveau d'études
                  DropdownButtonFormField<String>(
                    value: _selectedNiveau,
                    decoration: InputDecoration(
                      labelText: l10n.educationLevel,
                      prefixIcon: const Icon(Icons.school_outlined),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    items: _niveaux.map((n) => DropdownMenuItem(value: n, child: Text(n))).toList(),
                    onChanged: _isLoading ? null : (v) => setState(() => _selectedNiveau = v),
                    validator: (v) => v == null ? 'Sélectionnez un niveau' : null,
                  ),
                  const SizedBox(height: 24),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(onPressed: _isLoading ? null : () => Navigator.pop(context), child: Text(l10n.cancel)),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: _isLoading ? null : _saveChanges,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF5B9FD8),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: _isLoading
                            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : Text(l10n.save),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}