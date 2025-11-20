import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';

/// En-tête de la page d'inscription
class SignUpHeader extends StatelessWidget {
  final AppLocalizations l10n;

  const SignUpHeader({super.key, required this.l10n});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.createAccount,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          l10n.joinSmartLearn,
          style: TextStyle(
            fontSize: 15,
            color: colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
      ],
    );
  }
}

/// Checkbox + texte des conditions d'utilisation
class TermsCheckbox extends StatelessWidget {
  final bool acceptTerms;
  final bool isLoading;
  final Function(bool) onChanged;
  final AppLocalizations l10n;

  const TermsCheckbox({
    super.key,
    required this.acceptTerms,
    required this.isLoading,
    required this.onChanged,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Checkbox(
          value: acceptTerms,
          onChanged: isLoading ? null : (v) => onChanged(v ?? false),
          activeColor: const Color(0xFF5B9FD8),
        ),
        Expanded(
          child: GestureDetector(
            onTap: isLoading ? null : () => onChanged(!acceptTerms),
            child: RichText(
              text: TextSpan(
                style: TextStyle(color: colorScheme.onSurface.withOpacity(0.8), fontSize: 14),
                children: [
                  TextSpan(text: l10n.iAcceptThe),
                  TextSpan(
                    text: l10n.termsOfService,
                    style: const TextStyle(color: Color(0xFF5B9FD8), fontWeight: FontWeight.w600),
                  ),
                  TextSpan(text: ' ${l10n.andThe} '),
                  TextSpan(
                    text: l10n.privacyPolicy,
                    style: const TextStyle(color: Color(0xFF5B9FD8), fontWeight: FontWeight.w600),
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

/// Bouton principal "S'inscrire"
class SignUpButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onPressed;
  final AppLocalizations l10n;

  const SignUpButton({
    super.key,
    required this.isLoading,
    required this.onPressed,
    required this.l10n,
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
          l10n.signUp,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

/// Séparateur "OU"
class OrDivider extends StatelessWidget {
  final AppLocalizations l10n;

  const OrDivider({super.key, required this.l10n});

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

/// Bouton Google
class GoogleSignUpButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onPressed;
  final AppLocalizations l10n;

  const GoogleSignUpButton({
    super.key,
    required this.isLoading,
    required this.onPressed,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      height: 56,
      child: OutlinedButton.icon(
        onPressed: isLoading ? null : onPressed,
        icon: Image.asset(
          'assets/google_logo.png',
          height: 24,
          width: 24,
          errorBuilder: (_, __, ___) => const Icon(Icons.g_mobiledata, size: 24),
        ),
        label: Text(
          l10n.signUpWithGoogle,
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
    );
  }
}

/// Lien "Vous avez déjà un compte ? Se connecter"
class LoginLink extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onTap;
  final AppLocalizations l10n;

  const LoginLink({
    super.key,
    required this.isLoading,
    required this.onTap,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          l10n.alreadyHaveAccount,
          style: TextStyle(color: colorScheme.onSurface.withOpacity(0.7), fontSize: 15),
        ),
        GestureDetector(
          onTap: isLoading ? null : onTap,
          child: Text(
            l10n.login,
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