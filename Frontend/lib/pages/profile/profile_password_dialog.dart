import 'package:flutter/material.dart';
import '../../services/profile_service.dart';

/// Dialogue pour changer le mot de passe
class ProfilePasswordDialog extends StatefulWidget {
  const ProfilePasswordDialog({Key? key}) : super(key: key);

  @override
  State<ProfilePasswordDialog> createState() => _ProfilePasswordDialogState();
}

class _ProfilePasswordDialogState extends State<ProfilePasswordDialog> {
  final _formKey = GlobalKey<FormState>();
  final _profileService = ProfileService();

  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isOldPasswordVisible = false;
  bool _isNewPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  /// Méthode asynchrone pour changer le mot de passe
  Future<void> _changePassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    // Appel au service pour changer le mot de passe
    final result = await _profileService.changePassword(
      oldPassword: _oldPasswordController.text,
      newPassword: _newPasswordController.text,
    );

    setState(() => _isLoading = false);

    if (!mounted) return;

    if (result['success']) {
      // Fermer le dialogue et retourner true pour indiquer le succès
      Navigator.of(context).pop(true);
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
                        Icons.lock_outline,
                        color: Color(0xFF6C5CE7),
                        size: 28,
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Changer le mot de passe',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2D3436),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Champ Ancien mot de passe
                  TextFormField(
                    controller: _oldPasswordController,
                    enabled: !_isLoading,
                    obscureText: !_isOldPasswordVisible,
                    decoration: InputDecoration(
                      labelText: 'Ancien mot de passe',
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isOldPasswordVisible
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: () {
                          setState(() {
                            _isOldPasswordVisible = !_isOldPasswordVisible;
                          });
                        },
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'L\'ancien mot de passe est obligatoire';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  // Champ Nouveau mot de passe
                  TextFormField(
                    controller: _newPasswordController,
                    enabled: !_isLoading,
                    obscureText: !_isNewPasswordVisible,
                    decoration: InputDecoration(
                      labelText: 'Nouveau mot de passe',
                      hintText: 'Min. 8 caractères',
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isNewPasswordVisible
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: () {
                          setState(() {
                            _isNewPasswordVisible = !_isNewPasswordVisible;
                          });
                        },
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Le nouveau mot de passe est obligatoire';
                      }
                      if (value.length < 8) {
                        return 'Minimum 8 caractères';
                      }
                      if (!RegExp(r'[A-Z]').hasMatch(value)) {
                        return 'Doit contenir une majuscule';
                      }
                      if (!RegExp(r'[0-9]').hasMatch(value)) {
                        return 'Doit contenir un chiffre';
                      }
                      if (value == _oldPasswordController.text) {
                        return 'Le nouveau mot de passe doit être différent';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  // Champ Confirmer le mot de passe
                  TextFormField(
                    controller: _confirmPasswordController,
                    enabled: !_isLoading,
                    obscureText: !_isConfirmPasswordVisible,
                    decoration: InputDecoration(
                      labelText: 'Confirmer le mot de passe',
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isConfirmPasswordVisible
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: () {
                          setState(() {
                            _isConfirmPasswordVisible =
                            !_isConfirmPasswordVisible;
                          });
                        },
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez confirmer le mot de passe';
                      }
                      if (value != _newPasswordController.text) {
                        return 'Les mots de passe ne correspondent pas';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 24),

                  // Indication des critères
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF6C5CE7).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Critères du mot de passe:',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[700],
                          ),
                        ),
                        const SizedBox(height: 8),
                        _buildCriteriaItem('Au moins 8 caractères'),
                        _buildCriteriaItem('Une majuscule (A-Z)'),
                        _buildCriteriaItem('Un chiffre (0-9)'),
                      ],
                    ),
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
                            : () => Navigator.of(context).pop(false),
                        child: const Text('Annuler'),
                      ),

                      const SizedBox(width: 12),

                      // Bouton Confirmer
                      ElevatedButton(
                        onPressed: _isLoading ? null : _changePassword,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6C5CE7),
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
                            : const Text('Confirmer'),
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

  Widget _buildCriteriaItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        children: [
          Icon(
            Icons.check_circle,
            size: 16,
            color: Colors.grey[600],
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}