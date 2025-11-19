import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'signup/signup_form_fields.dart';
import 'signup/signup_ui_components.dart';

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
    'Collège',
    'Lycée',
    'Université',
    'Formation continue',
    'Autodidacte'
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
    if (!_acceptTerms) {
      _showSnackBar(
        'Veuillez accepter les conditions d\'utilisation',
        Colors.red,
      );
      return;
    }

    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        print('📱 Début de l\'inscription...');

        final result = await _authService.signUp(
          nom: _nomController.text.trim(),
          prenom: _prenomController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text,
          niveau: _selectedNiveau!,
        );

        print('📱 Résultat reçu: $result');

        setState(() => _isLoading = false);

        if (!mounted) return;

        if (result['success'] == true) {
          print('✅ Inscription réussie, navigation vers /home');

          // Récupérer le prénom depuis les données ou utiliser celui saisi
          final prenom = result['data']?['prenom'] ?? _prenomController.text;

          _showSnackBar(
            'Compte créé avec succès ! Bienvenue $prenom',
            Colors.green,
          );

          // Attendre un peu pour que le message s'affiche
          await Future.delayed(const Duration(milliseconds: 500));

          // Navigation vers la page d'accueil
          if (mounted) {
            Navigator.pushReplacementNamed(context, '/home');
          }
        } else {
          print('❌ Erreur d\'inscription: ${result['message']}');
          _showErrorDialog(result['message'] ?? 'Erreur inconnue');
        }
      } catch (e, stackTrace) {
        print('❌ Exception dans _handleSignUp: $e');
        print('Stack trace: $stackTrace');

        setState(() => _isLoading = false);
        _showErrorDialog('Une erreur inattendue s\'est produite: ${e.toString()}');
      }
    }
  }

  void _handleGoogleSignUp() {
    _showSnackBar(
      'Inscription Google en cours de développement',
      Colors.blue,
    );
  }

  void _showSnackBar(String message, Color backgroundColor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red, size: 28),
            SizedBox(width: 12),
            Text('Erreur d\'inscription'),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor, // ✅ Changé
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF2D3436)),
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

                  // En-tête
                  const SignUpHeader(),

                  const SizedBox(height: 32),

                  // Formulaire
                  NomField(
                    controller: _nomController,
                    isLoading: _isLoading,
                  ),
                  const SizedBox(height: 16),

                  PrenomField(
                    controller: _prenomController,
                    isLoading: _isLoading,
                  ),
                  const SizedBox(height: 16),

                  EmailField(
                    controller: _emailController,
                    isLoading: _isLoading,
                  ),
                  const SizedBox(height: 16),

                  NiveauDropdown(
                    selectedNiveau: _selectedNiveau,
                    niveaux: _niveaux,
                    isLoading: _isLoading,
                    onChanged: (value) {
                      setState(() => _selectedNiveau = value);
                    },
                  ),
                  const SizedBox(height: 16),

                  PasswordField(
                    controller: _passwordController,
                    isLoading: _isLoading,
                  ),
                  const SizedBox(height: 16),

                  PasswordField(
                    controller: _confirmPasswordController,
                    isLoading: _isLoading,
                    labelText: 'Confirmer le mot de passe',
                    hintText: 'Répétez le mot de passe',
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez confirmer votre mot de passe';
                      }
                      if (value != _passwordController.text) {
                        return 'Les mots de passe ne correspondent pas';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 20),

                  // Conditions d'utilisation
                  TermsCheckbox(
                    acceptTerms: _acceptTerms,
                    isLoading: _isLoading,
                    onChanged: (value) {
                      setState(() => _acceptTerms = value);
                    },
                  ),

                  const SizedBox(height: 24),

                  // Bouton d'inscription
                  SignUpButton(
                    isLoading: _isLoading,
                    onPressed: _handleSignUp,
                  ),

                  const SizedBox(height: 24),

                  // Séparateur
                  const OrDivider(),

                  const SizedBox(height: 24),

                  // Connexion avec Google
                  GoogleSignUpButton(
                    isLoading: _isLoading,
                    onPressed: _handleGoogleSignUp,
                  ),

                  const SizedBox(height: 24),

                  // Lien vers login
                  LoginLink(
                    isLoading: _isLoading,
                    onTap: () => Navigator.pop(context),
                  ),

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