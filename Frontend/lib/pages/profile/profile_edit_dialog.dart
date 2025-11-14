import 'package:flutter/material.dart';
import '../../models/profile_model.dart';
import '../../services/profile_service.dart';

/// Dialogue pour modifier les informations du profil
class ProfileEditDialog extends StatefulWidget {
  final ProfileModel profile;

  const ProfileEditDialog({
    Key? key,
    required this.profile,
  }) : super(key: key);

  @override
  State<ProfileEditDialog> createState() => _ProfileEditDialogState();
}

class _ProfileEditDialogState extends State<ProfileEditDialog> {
  final _formKey = GlobalKey<FormState>();
  final _profileService = ProfileService();

  // Contrôleurs pour les champs de texte
  late TextEditingController _nomController;
  late TextEditingController _prenomController;
  late TextEditingController _emailController;

  String? _selectedNiveau;
  bool _isLoading = false;

  final List<String> _niveaux = [
    'Collège',
    'Lycée',
    'Université',
    'Formation continue',
    'Autodidacte',
  ];

  @override
  void initState() {
    super.initState();
    // Initialiser les contrôleurs avec les valeurs actuelles
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

  /// Méthode asynchrone pour sauvegarder les modifications
  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    // Appel au service pour mettre à jour le profil
    final result = await _profileService.updateProfile(
      nom: _nomController.text.trim(),
      prenom: _prenomController.text.trim(),
      email: _emailController.text.trim(),
      niveau: _selectedNiveau!,
    );

    setState(() => _isLoading = false);

    if (!mounted) return;

    if (result['success']) {
      // Récupérer le nouveau profil
      final updatedProfile = result['profile'] as ProfileModel;

      // Fermer le dialogue et retourner le nouveau profil
      Navigator.of(context).pop(updatedProfile);
    } else {
      // Afficher l'erreur
      _showErrorSnackBar(result['message']);
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

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
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
                  // Titre
                  Row(
                    children: [
                      const Icon(
                        Icons.edit,
                        color: Color(0xFF5B9FD8),
                        size: 28,
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Modifier le profil',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2D3436),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Champ Nom
                  TextFormField(
                    controller: _nomController,
                    enabled: !_isLoading,
                    decoration: InputDecoration(
                      labelText: 'Nom',
                      prefixIcon: const Icon(Icons.person_outline),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Le nom est obligatoire';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  // Champ Prénom
                  TextFormField(
                    controller: _prenomController,
                    enabled: !_isLoading,
                    decoration: InputDecoration(
                      labelText: 'Prénom',
                      prefixIcon: const Icon(Icons.person_outline),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Le prénom est obligatoire';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  // Champ Email
                  TextFormField(
                    controller: _emailController,
                    enabled: !_isLoading,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      prefixIcon: const Icon(Icons.email_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'L\'email est obligatoire';
                      }
                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                          .hasMatch(value)) {
                        return 'Email invalide';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  // Dropdown Niveau
                  DropdownButtonFormField<String>(
                    value: _selectedNiveau,
                    decoration: InputDecoration(
                      labelText: 'Niveau d\'études',
                      prefixIcon: const Icon(Icons.school_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    items: _niveaux.map((niveau) {
                      return DropdownMenuItem(
                        value: niveau,
                        child: Text(niveau),
                      );
                    }).toList(),
                    onChanged: _isLoading
                        ? null
                        : (value) {
                      setState(() => _selectedNiveau = value);
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Sélectionnez un niveau';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 24),

                  // Boutons d'action
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // Bouton Annuler
                      TextButton(
                        onPressed: _isLoading
                            ? null
                            : () => Navigator.of(context).pop(),
                        child: const Text('Annuler'),
                      ),

                      const SizedBox(width: 12),

                      // Bouton Enregistrer
                      ElevatedButton(
                        onPressed: _isLoading ? null : _saveChanges,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF5B9FD8),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                            : const Text('Enregistrer'),
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