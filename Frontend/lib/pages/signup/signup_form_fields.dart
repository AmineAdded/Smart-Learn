import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';

/// Champ Nom
class NomField extends StatelessWidget {
  final TextEditingController controller;
  final bool isLoading;
  final AppLocalizations l10n;

  const NomField({
    super.key,
    required this.controller,
    required this.isLoading,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      textCapitalization: TextCapitalization.words,
      enabled: !isLoading,
      decoration: InputDecoration(
        labelText: l10n.lastName,
        hintText: l10n.yourLastName,
        prefixIcon: const Icon(Icons.person_outline),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF5B9FD8), width: 2),
        ),
      ),
      validator: (value) =>
      value?.isEmpty ?? true ? l10n.lastNameRequired : null,
    );
  }
}

/// Champ Prénom
class PrenomField extends StatelessWidget {
  final TextEditingController controller;
  final bool isLoading;
  final AppLocalizations l10n;

  const PrenomField({
    super.key,
    required this.controller,
    required this.isLoading,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      textCapitalization: TextCapitalization.words,
      enabled: !isLoading,
      decoration: InputDecoration(
        labelText: l10n.firstName,
        hintText: l10n.yourFirstName,
        prefixIcon: const Icon(Icons.person_outline),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF5B9FD8), width: 2),
        ),
      ),
      validator: (value) =>
      value?.isEmpty ?? true ? l10n.firstNameRequired : null,
    );
  }
}

/// Champ Email
class EmailField extends StatelessWidget {
  final TextEditingController controller;
  final bool isLoading;
  final AppLocalizations l10n;

  const EmailField({
    super.key,
    required this.controller,
    required this.isLoading,
    required this.l10n,
  });

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
      ),
      validator: (value) {
        if (value?.isEmpty ?? true) return l10n.emailRequired;
        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value!)) {
          return l10n.invalidEmail;
        }
        return null;
      },
    );
  }
}

/// Dropdown Niveau d’études
class NiveauDropdown extends StatelessWidget {
  final String? selectedNiveau;
  final List<String> niveaux;
  final bool isLoading;
  final Function(String?) onChanged;
  final AppLocalizations l10n;

  const NiveauDropdown({
    super.key,
    required this.selectedNiveau,
    required this.niveaux,
    required this.isLoading,
    required this.onChanged,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: selectedNiveau,
      decoration: InputDecoration(
        labelText: l10n.educationLevel,
        prefixIcon: const Icon(Icons.school_outlined),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF5B9FD8), width: 2),
        ),
      ),
      hint: Text(l10n.selectYourLevel),
      items: niveaux.map((n) => DropdownMenuItem(value: n, child: Text(n))).toList(),
      onChanged: isLoading ? null : onChanged,
      validator: (value) =>
      value == null ? l10n.educationLevelRequired : null,
    );
  }
}

/// Champ Mot de passe (avec œil)
class PasswordField extends StatefulWidget {
  final TextEditingController controller;
  final bool isLoading;
  final String labelText;
  final String hintText;
  final String? Function(String?)? validator;
  final AppLocalizations l10n;

  const PasswordField({
    super.key,
    required this.controller,
    required this.isLoading,
    this.labelText = '',
    this.hintText = '',
    this.validator,
    required this.l10n,
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
        labelText: widget.labelText.isNotEmpty ? widget.labelText : widget.l10n.password,
        hintText: widget.hintText.isNotEmpty ? widget.hintText : widget.l10n.passwordHint,
        prefixIcon: const Icon(Icons.lock_outline),
        suffixIcon: IconButton(
          icon: Icon(_isPasswordVisible ? Icons.visibility_off : Icons.visibility),
          onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
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
            if (value?.isEmpty ?? true) return widget.l10n.passwordRequired;
            if (value!.length < 8) return widget.l10n.passwordMin8Chars;
            if (!RegExp(r'[A-Z]').hasMatch(value)) return widget.l10n.passwordUppercaseRequired;
            if (!RegExp(r'[0-9]').hasMatch(value)) return widget.l10n.passwordDigitRequired;
            return null;
          },
    );
  }
}