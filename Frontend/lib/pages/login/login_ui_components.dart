import 'package:flutter/material.dart';

/// Widget pour l'en-tête de la page de connexion (logo + titre)
class LoginHeader extends StatelessWidget {
  const LoginHeader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Logo
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: const Color(0xFF5B9FD8).withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Icon(
            Icons.menu_book_rounded,
            size: 40,
            color: Color(0xFF5B9FD8),
          ),
        ),

        const SizedBox(height: 24),

        // Titre
        const Text(
          'Bienvenue !',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2D3436),
          ),
        ),

        const SizedBox(height: 8),

        // Sous-titre
        Text(
          'Connectez-vous pour continuer',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}

/// Widget pour le lien "Mot de passe oublié"
class ForgotPasswordLink extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onPressed;

  const ForgotPasswordLink({
    Key? key,
    required this.isLoading,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: isLoading ? null : onPressed,
        child: const Text(
          'Mot de passe oublié ?',
          style: TextStyle(
            color: Color(0xFF5B9FD8),
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

/// Widget pour le bouton de connexion
class LoginButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onPressed;

  const LoginButton({
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
          backgroundColor: const Color(0xFF5B9FD8),
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
          'Se connecter',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

/// Widget pour le séparateur "OU"
class LoginDivider extends StatelessWidget {
  const LoginDivider({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Divider(color: Colors.grey[300])),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'OU',
            style: TextStyle(
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(child: Divider(color: Colors.grey[300])),
      ],
    );
  }
}

/// Widget pour les boutons de connexion sociale (Google, Apple)
class SocialLoginButtons extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onGooglePressed;
  final VoidCallback onApplePressed;

  const SocialLoginButtons({
    Key? key,
    required this.isLoading,
    required this.onGooglePressed,
    required this.onApplePressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Bouton Google
        SizedBox(
          height: 56,
          child: OutlinedButton.icon(
            onPressed: isLoading ? null : onGooglePressed,
            icon: Image.asset(
              'assets/google_logo.png',
              height: 24,
              width: 24,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(Icons.g_mobiledata, size: 24);
              },
            ),
            label: const Text(
              'Continuer avec Google',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Color(0xFF2D3436),
              ),
            ),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: Colors.grey[300]!),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),

        const SizedBox(height: 12),

        // Bouton Apple
        SizedBox(
          height: 56,
          child: OutlinedButton.icon(
            onPressed: isLoading ? null : onApplePressed,
            icon: const Icon(Icons.apple, size: 24, color: Colors.black),
            label: const Text(
              'Continuer avec Apple',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Color(0xFF2D3436),
              ),
            ),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: Colors.grey[300]!),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Widget pour le lien vers la page d'inscription
class SignUpLink extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onTap;

  const SignUpLink({
    Key? key,
    required this.isLoading,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Pas encore de compte ? ',
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 15,
          ),
        ),
        GestureDetector(
          onTap: isLoading ? null : onTap,
          child: Text(
            'S\'inscrire',
            style: TextStyle(
              color: isLoading ? Colors.grey : const Color(0xFF5B9FD8),
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}