import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'interests_selection_screen.dart';
import 'signup/signup_form_fields.dart';
import 'signup/signup_ui_components.dart';
import '../../l10n/app_localizations.dart'; // AJOUTÉ

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final _nomController = TextEditingController();
  final _prenomController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _authService = AuthService();

  bool _acceptTerms = false;
  bool _isLoading = false;

  String? _selectedNiveau;
  final List<String> _niveaux = [
    'Collège', 'Lycée', 'Université', 'Formation continue', 'Autodidacte'
  ];

  @override
  void dispose() {
    _nomController.dispose();
    _prenomController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignUp() async {
    final l10n = AppLocalizations.of(context)!;

    if (!_acceptTerms) {
      _showSnackBar(l10n.acceptTermsRequired, Colors.red);
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final result = await _authService.signUp(
        nom: _nomController.text.trim(),
        prenom: _prenomController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
        niveau: _selectedNiveau!,
      );

      setState(() => _isLoading = false);
      if (!mounted) return;

      if (result['success'] == true) {
        final prenom = result['data']?['prenom'] ?? _prenomController.text;
        _showSnackBar(l10n.signUpSuccess(prenom), Colors.green);

        await Future.delayed(const Duration(milliseconds: 600));

        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => InterestsSelectionScreen(isOnboarding: true),
            ),
          );
        }
      } else {
        _showErrorDialog(result['message'] ?? l10n.unknownError);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      final l10n = AppLocalizations.of(context)!;
      _showErrorDialog(l10n.unexpectedError);
    }
  }

  void _handleGoogleSignUp() {
    final l10n = AppLocalizations.of(context)!;
    _showSnackBar(l10n.googleSignUpInDevelopment, Colors.blue);
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _showErrorDialog(String message) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        icon: const Icon(Icons.error_outline, color: Colors.red, size: 28),
        title: Text(l10n.signUpError),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.ok, style: const TextStyle(color: Color(0xFF5B9FD8))),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 20),
                  SignUpHeader(l10n: l10n),
                  const SizedBox(height: 32),

                  NomField(controller: _nomController, isLoading: _isLoading, l10n: l10n),
                  const SizedBox(height: 16),
                  PrenomField(controller: _prenomController, isLoading: _isLoading, l10n: l10n),
                  const SizedBox(height: 16),
                  EmailField(controller: _emailController, isLoading: _isLoading, l10n: l10n),
                  const SizedBox(height: 16),

                  NiveauDropdown(
                    selectedNiveau: _selectedNiveau,
                    niveaux: _niveaux,
                    isLoading: _isLoading,
                    onChanged: (value) => setState(() => _selectedNiveau = value),
                    l10n: l10n,
                  ),
                  const SizedBox(height: 16),

                  PasswordField(controller: _passwordController, isLoading: _isLoading, l10n: l10n),
                  const SizedBox(height: 16),

                  PasswordField(
                    controller: _confirmPasswordController,
                    isLoading: _isLoading,
                    labelText: l10n.confirmPassword,
                    hintText: l10n.repeatPassword,
                    validator: (value) {
                      if (value?.isEmpty ?? true) return l10n.confirmPasswordRequired;
                      if (value != _passwordController.text) return l10n.passwordsDoNotMatch;
                      return null;
                    },
                    l10n: l10n,
                  ),

                  const SizedBox(height: 20),
                  TermsCheckbox(
                    acceptTerms: _acceptTerms,
                    isLoading: _isLoading,
                    onChanged: (v) => setState(() => _acceptTerms = v!),
                    l10n: l10n,
                  ),

                  const SizedBox(height: 24),
                  SignUpButton(isLoading: _isLoading, onPressed: _handleSignUp, l10n: l10n),

                  const SizedBox(height: 24),
                  OrDivider(l10n: l10n),

                  const SizedBox(height: 24),
                  GoogleSignUpButton(isLoading: _isLoading, onPressed: _handleGoogleSignUp, l10n: l10n),

                  const SizedBox(height: 24),
                  LoginLink(isLoading: _isLoading, onTap: () => Navigator.pop(context), l10n: l10n),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}