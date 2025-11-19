import 'package:flutter/material.dart';

/// En-tête de la page mot de passe oublié
class ForgotPasswordHeader extends StatelessWidget {
  const ForgotPasswordHeader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
            Icons.lock_reset,
            size: 40,
            color: Color(0xFF5B9FD8),
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'Mot de passe oublié ?',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2D3436),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Entrez votre adresse email et nous vous enverrons un code de vérification',
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

/// Champ email
class ForgotPasswordEmailField extends StatelessWidget {
  final TextEditingController controller;
  final bool isLoading;

  const ForgotPasswordEmailField({
    Key? key,
    required this.controller,
    required this.isLoading,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.emailAddress,
      enabled: !isLoading,
      decoration: InputDecoration(
        labelText: 'Email',
        hintText: 'exemple@email.com',
        prefixIcon: const Icon(Icons.email_outlined),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF5B9FD8), width: 2),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Veuillez entrer votre email';
        }
        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
          return 'Email invalide';
        }
        return null;
      },
    );
  }
}

/// ✅ Nouveau bouton "Envoyer le code"
class SendCodeButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onPressed;

  const SendCodeButton({
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
          'Envoyer le code',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

/// Lien retour
class BackToLoginLink extends StatelessWidget {
  final VoidCallback onTap;

  const BackToLoginLink({
    Key? key,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(
          Icons.arrow_back,
          size: 18,
          color: Color(0xFF5B9FD8),
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: onTap,
          child: const Text(
            'Retour à la connexion',
            style: TextStyle(
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