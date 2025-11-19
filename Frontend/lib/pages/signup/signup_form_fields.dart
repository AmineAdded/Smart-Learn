import 'package:flutter/material.dart';

/// Widget pour le champ Nom
class NomField extends StatelessWidget {
  final TextEditingController controller;
  final bool isLoading;

  const NomField({
    super.key,
    required this.controller,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      textCapitalization: TextCapitalization.words,
      enabled: !isLoading,
      decoration: InputDecoration(
        labelText: 'Nom',
        hintText: 'Votre nom',
        prefixIcon: const Icon(Icons.person_outline),
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
          return 'Veuillez entrer votre nom';
        }
        return null;
      },
    );
  }
}

/// Widget pour le champ Prénom
class PrenomField extends StatelessWidget {
  final TextEditingController controller;
  final bool isLoading;

  const PrenomField({
    super.key,
    required this.controller,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      textCapitalization: TextCapitalization.words,
      enabled: !isLoading,
      decoration: InputDecoration(
        labelText: 'Prénom',
        hintText: 'Votre prénom',
        prefixIcon: const Icon(Icons.person_outline),
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
          return 'Veuillez entrer votre prénom';
        }
        return null;
      },
    );
  }
}

/// Widget pour le champ Email
class EmailField extends StatelessWidget {
  final TextEditingController controller;
  final bool isLoading;

  const EmailField({
    super.key,
    required this.controller,
    required this.isLoading,
  });

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

/// Widget pour le dropdown Niveau
class NiveauDropdown extends StatelessWidget {
  final String? selectedNiveau;
  final List<String> niveaux;
  final bool isLoading;
  final Function(String?) onChanged;

  const NiveauDropdown({
    super.key,
    required this.selectedNiveau,
    required this.niveaux,
    required this.isLoading,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: selectedNiveau,
      decoration: InputDecoration(
        labelText: 'Niveau d\'études',
        prefixIcon: const Icon(Icons.school_outlined),
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
      hint: const Text('Sélectionnez votre niveau'),
      items: niveaux.map((niveau) {
        return DropdownMenuItem<String>(
          value: niveau,
          child: Text(niveau),
        );
      }).toList(),
      onChanged: isLoading ? null : onChanged,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Veuillez sélectionner votre niveau';
        }
        return null;
      },
    );
  }
}

/// Widget pour le champ Mot de passe
class PasswordField extends StatefulWidget {
  final TextEditingController controller;
  final bool isLoading;
  final String labelText;
  final String hintText;
  final String? Function(String?)? validator;

  const PasswordField({
    super.key,
    required this.controller,
    required this.isLoading,
    this.labelText = 'Mot de passe',
    this.hintText = 'Min. 8 caractères',
    this.validator,
  });

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool _isPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: !_isPasswordVisible,
      enabled: !widget.isLoading,
      decoration: InputDecoration(
        labelText: widget.labelText,
        hintText: widget.hintText,
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
          borderSide: const BorderSide(color: Color(0xFF5B9FD8), width: 2),
        ),
      ),
      validator: widget.validator ??
              (value) {
            if (value == null || value.isEmpty) {
              return 'Veuillez entrer un mot de passe';
            }
            if (value.length < 8) {
              return 'Le mot de passe doit contenir au moins 8 caractères';
            }
            if (!RegExp(r'[A-Z]').hasMatch(value)) {
              return 'Le mot de passe doit contenir une majuscule';
            }
            if (!RegExp(r'[0-9]').hasMatch(value)) {
              return 'Le mot de passe doit contenir un chiffre';
            }
            return null;
          },
    );
  }
}