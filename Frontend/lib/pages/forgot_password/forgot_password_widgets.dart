import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';

/// En-tête "Mot de passe oublié"
class ForgotPasswordHeader extends StatelessWidget {
  final AppLocalizations l10n;

  const ForgotPasswordHeader({Key? key, required this.l10n}) : super(key: key);

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
          child: const Icon(Icons.lock_reset, size: 40, color: Color(0xFF5B9FD8)),
        ),
        const SizedBox(height: 24),
        Text(
          l10n.forgotPasswordTitle,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          l10n.forgotPasswordSubtitle,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 15,
            color: colorScheme.onSurface.withOpacity(0.7),
            height: 1.4,
          ),
        ),
      ],
    );
  }
}

/// Champ Email – identique au login mais traduit
class ForgotPasswordEmailField extends StatelessWidget {
  final TextEditingController controller;
  final bool isLoading;
  final AppLocalizations l10n;

  const ForgotPasswordEmailField({
    Key? key,
    required this.controller,
    required this.isLoading,
    required this.l10n,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.emailAddress,
      enabled: !isLoading,
      decoration: InputDecoration(
        labelText: l10n.email,
        hintText: l10n.emailExample,
        prefixIcon: const Icon(Icons.email_outlined),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF5B9FD8), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return l10n.emailRequired;
        }
        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
          return l10n.invalidEmail;
        }
        return null;
      },
    );
  }
}

/// Bouton "Envoyer le code"
class SendCodeButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onPressed;
  final AppLocalizations l10n;

  const SendCodeButton({
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
          l10n.sendCode,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

/// Lien "Retour à la connexion"
class BackToLoginLink extends StatelessWidget {
  final VoidCallback onTap;
  final AppLocalizations l10n;

  const BackToLoginLink({
    Key? key,
    required this.onTap,
    required this.l10n,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.arrow_back, size: 18, color: Color(0xFF5B9FD8)),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: onTap,
          child: Text(
            l10n.backToLogin,
            style: const TextStyle(
              color: Color(0xFF5B9FD8),
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}