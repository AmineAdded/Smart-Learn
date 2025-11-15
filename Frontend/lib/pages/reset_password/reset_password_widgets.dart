  import 'package:flutter/material.dart';
  
  /// En-tête de la page de réinitialisation
  class ResetPasswordHeader extends StatelessWidget {
    const ResetPasswordHeader({Key? key}) : super(key: key);
  
    @override
    Widget build(BuildContext context) {
      return Column(
        children: [
          // Icône
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFF6C5CE7).withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.lock_open,
              size: 40,
              color: Color(0xFF6C5CE7),
            ),
          ),
  
          const SizedBox(height: 24),
  
          // Titre
          const Text(
            'Nouveau mot de passe',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D3436),
            ),
          ),
  
          const SizedBox(height: 8),
  
          // Description
          Text(
            'Créez un nouveau mot de passe sécurisé pour votre compte',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey[600],
              height: 1.4,
            ),
          ),
        ],
      );
    }
  }
  
  /// Champ nouveau mot de passe
  class NewPasswordField extends StatefulWidget {
    final TextEditingController controller;
    final bool isLoading;
  
    const NewPasswordField({
      Key? key,
      required this.controller,
      required this.isLoading,
    }) : super(key: key);
  
    @override
    State<NewPasswordField> createState() => _NewPasswordFieldState();
  }
  
  class _NewPasswordFieldState extends State<NewPasswordField> {
    bool _isPasswordVisible = false;
  
    @override
    Widget build(BuildContext context) {
      return TextFormField(
        controller: widget.controller,
        obscureText: !_isPasswordVisible,
        enabled: !widget.isLoading,
        decoration: InputDecoration(
          labelText: 'Nouveau mot de passe',
          hintText: 'Min. 8 caractères',
          prefixIcon: const Icon(Icons.lock_outline),
          suffixIcon: IconButton(
            icon: Icon(
              _isPasswordVisible ? Icons.visibility_off : Icons.visibility,
            ),
            onPressed: () {
              setState(() => _isPasswordVisible = !_isPasswordVisible);
            },
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF6C5CE7), width: 2),
          ),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Le mot de passe est obligatoire';
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
          return null;
        },
      );
    }
  }
  
  /// Champ confirmer mot de passe
  class ConfirmPasswordField extends StatefulWidget {
    final TextEditingController controller;
    final TextEditingController passwordController;
    final bool isLoading;
  
    const ConfirmPasswordField({
      Key? key,
      required this.controller,
      required this.passwordController,
      required this.isLoading,
    }) : super(key: key);
  
    @override
    State<ConfirmPasswordField> createState() => _ConfirmPasswordFieldState();
  }
  
  class _ConfirmPasswordFieldState extends State<ConfirmPasswordField> {
    bool _isPasswordVisible = false;
  
    @override
    Widget build(BuildContext context) {
      return TextFormField(
        controller: widget.controller,
        obscureText: !_isPasswordVisible,
        enabled: !widget.isLoading,
        decoration: InputDecoration(
          labelText: 'Confirmer le mot de passe',
          hintText: 'Répétez le mot de passe',
          prefixIcon: const Icon(Icons.lock_outline),
          suffixIcon: IconButton(
            icon: Icon(
              _isPasswordVisible ? Icons.visibility_off : Icons.visibility,
            ),
            onPressed: () {
              setState(() => _isPasswordVisible = !_isPasswordVisible);
            },
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF6C5CE7), width: 2),
          ),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Veuillez confirmer le mot de passe';
          }
          if (value != widget.passwordController.text) {
            return 'Les mots de passe ne correspondent pas';
          }
          return null;
        },
      );
    }
  }
  
  /// Bouton de réinitialisation
  class ResetPasswordButton extends StatelessWidget {
    final bool isLoading;
    final VoidCallback onPressed;
  
    const ResetPasswordButton({
      Key? key,
      required this.isLoading,
      required this.onPressed,
    }) : super(key: key);
  
    @override
    Widget build(BuildContext context) {
      return SizedBox(
        height: 56,
        child: ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF6C5CE7),
            foregroundColor: Colors.white,
            elevation: 0,
            disabledBackgroundColor: Colors.grey[300],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: isLoading
              ? const SizedBox(
            height: 24,
            width: 24,
            child: CircularProgressIndicator(
              color: Colors.white,
              strokeWidth: 2,
            ),
          )
              : const Text(
            'Réinitialiser le mot de passe',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
    }
  }
  
  /// Critères de mot de passe
  class PasswordCriteriaBox extends StatelessWidget {
    const PasswordCriteriaBox({Key? key}) : super(key: key);
  
    @override
    Widget build(BuildContext context) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF6C5CE7).withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFF6C5CE7).withOpacity(0.3),
          ),
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
            const SizedBox(height: 12),
            _buildCriteriaItem('Au moins 8 caractères'),
            _buildCriteriaItem('Une majuscule (A-Z)'),
            _buildCriteriaItem('Un chiffre (0-9)'),
          ],
        ),
      );
    }
  
    Widget _buildCriteriaItem(String text) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
          children: [
            const Icon(
              Icons.check_circle_outline,
              size: 18,
              color: Color(0xFF6C5CE7),
            ),
            const SizedBox(width: 10),
            Text(
              text,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
      );
    }
  }
  
  /// Widget de chargement pour la vérification du token
  class TokenVerificationLoader extends StatelessWidget {
    const TokenVerificationLoader({Key? key}) : super(key: key);
  
    @override
    Widget build(BuildContext context) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(
              color: Color(0xFF6C5CE7),
            ),
            const SizedBox(height: 24),
            Text(
              'Vérification du lien...',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }
  }
  
  /// Widget d'erreur de token
  class TokenErrorWidget extends StatelessWidget {
    final String message;
    final VoidCallback onRetry;
  
    const TokenErrorWidget({
      Key? key,
      required this.message,
      required this.onRetry,
    }) : super(key: key);
  
    @override
    Widget build(BuildContext context) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.error_outline,
                  size: 40,
                  color: Colors.red,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Lien invalide',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 12),
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey[600],
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: onRetry,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5B9FD8),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Faire une nouvelle demande'),
              ),
            ],
          ),
        ),
      );
    }
  }