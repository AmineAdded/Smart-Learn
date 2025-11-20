import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';

/// En-tête de connexion (logo + titre)
class LoginHeader extends StatelessWidget {
  final AppLocalizations l10n;

  const LoginHeader({Key? key, required this.l10n}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
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
        Text(
          l10n.welcomeBack, // "Bienvenue !" ou "Welcome back!"
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          l10n.loginToContinue, // "Connectez-vous pour continuer"
          style: TextStyle(
            fontSize: 16,
            color: colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
      ],
    );
  }
}

/// Lien "Mot de passe oublié ?"
class ForgotPasswordLink extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onPressed;
  final AppLocalizations l10n;

  const ForgotPasswordLink({
    Key? key,
    required this.isLoading,
    required this.onPressed,
    required this.l10n,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: isLoading ? null : onPressed,
        child: Text(
          l10n.forgotPassword,
          style: const TextStyle(
            color: Color(0xFF5B9FD8),
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

/// Bouton principal "Se connecter"
class LoginButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onPressed;
  final AppLocalizations l10n;

  const LoginButton({
    Key? key,
    required this.isLoading,
    required this.onPressed,
    required this.l10n,
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
          disabledBackgroundColor: Colors.grey[300],
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: isLoading
            ? const SizedBox(
          height: 24,
          width: 24,
          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
        )
            : Text(
          l10n.login,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

/// Séparateur "OU"
class LoginDivider extends StatelessWidget {
  final AppLocalizations l10n;

  const LoginDivider({Key? key, required this.l10n}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Expanded(child: Divider(color: colorScheme.outline.withOpacity(0.3))),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            l10n.or,
            style: TextStyle(
              color: colorScheme.onSurface.withOpacity(0.6),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(child: Divider(color: colorScheme.outline.withOpacity(0.3))),
      ],
    );
  }
}

/// Boutons sociaux (Google, Apple)
class SocialLoginButtons extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onGooglePressed;
  final AppLocalizations l10n;

  const SocialLoginButtons({
    Key? key,
    required this.isLoading,
    required this.onGooglePressed,
    required this.l10n,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        SizedBox(
          height: 56,
          child: OutlinedButton.icon(
            onPressed: isLoading ? null : onGooglePressed,
            icon: Image.asset(
              'assets/google_logo.png',
              height: 24,
              width: 24,
              errorBuilder: (_, __, ___) => const Icon(Icons.g_mobiledata, size: 24),
            ),
            label: Text(
              l10n.continueWithGoogle,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: colorScheme.onSurface,
              ),
            ),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: colorScheme.outline.withOpacity(0.5)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
      ],
    );
  }
}

/// Lien "Pas encore de compte ? S'inscrire"
class SignUpLink extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onTap;
  final AppLocalizations l10n;

  const SignUpLink({
    Key? key,
    required this.isLoading,
    required this.onTap,
    required this.l10n,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          l10n.noAccountYet,
          style: TextStyle(color: colorScheme.onSurface.withOpacity(0.7), fontSize: 15),
        ),
        GestureDetector(
          onTap: isLoading ? null : onTap,
          child: Text(
            l10n.signUp,
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