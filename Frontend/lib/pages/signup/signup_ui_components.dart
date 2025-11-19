import 'package:flutter/material.dart';

/// Widget pour l'en-tête de la page d'inscription
class SignUpHeader extends StatelessWidget {
  const SignUpHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Créer un compte',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2D3436),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Rejoignez SmartLearn et commencez votre apprentissage',
          style: TextStyle(
            fontSize: 15,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}

/// Widget pour la checkbox des conditions d'utilisation
class TermsCheckbox extends StatelessWidget {
  final bool acceptTerms;
  final bool isLoading;
  final Function(bool) onChanged;

  const TermsCheckbox({
    super.key,
    required this.acceptTerms,
    required this.isLoading,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Checkbox(
          value: acceptTerms,
          onChanged: isLoading
              ? null
              : (value) {
            onChanged(value ?? false);
          },
          activeColor: const Color(0xFF5B9FD8),
        ),
        Expanded(
          child: GestureDetector(
            onTap: isLoading
                ? null
                : () {
              onChanged(!acceptTerms);
            },
            child: RichText(
              text: TextSpan(
                style: TextStyle(
                  color: Colors.grey[700],
                  fontSize: 14,
                ),
                children: const [
                  TextSpan(text: 'J\'accepte les '),
                  TextSpan(
                    text: 'Conditions d\'utilisation',
                    style: TextStyle(
                      color: Color(0xFF5B9FD8),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  TextSpan(text: ' et la '),
                  TextSpan(
                    text: 'Politique de confidentialité',
                    style: TextStyle(
                      color: Color(0xFF5B9FD8),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Widget pour le bouton d'inscription
class SignUpButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onPressed;

  const SignUpButton({
    super.key,
    required this.isLoading,
    required this.onPressed,
  });

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
          'S\'inscrire',
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
class OrDivider extends StatelessWidget {
  const OrDivider({super.key});

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

/// Widget pour le bouton de connexion avec Google
class GoogleSignUpButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onPressed;

  const GoogleSignUpButton({
    super.key,
    required this.isLoading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: OutlinedButton.icon(
        onPressed: isLoading ? null : onPressed,
        icon: Image.asset(
          'assets/google_logo.png',
          height: 24,
          width: 24,
          errorBuilder: (context, error, stackTrace) {
            return const Icon(Icons.g_mobiledata, size: 24);
          },
        ),
        label: const Text(
          'S\'inscrire avec Google',
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
    );
  }
}

/// Widget pour le lien vers la page de connexion
class LoginLink extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onTap;

  const LoginLink({
    super.key,
    required this.isLoading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Vous avez déjà un compte ? ',
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 15,
          ),
        ),
        GestureDetector(
          onTap: isLoading ? null : onTap,
          child: Text(
            'Se connecter',
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