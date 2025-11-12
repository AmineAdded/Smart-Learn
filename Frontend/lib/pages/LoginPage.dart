import 'package:flutter/material.dart';
import 'SignUpPage.dart';
import '../services/auth_service.dart';
import 'login/login_form_fields.dart';
import 'login/login_ui_components.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();

  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        final result = await _authService.login(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );

        setState(() => _isLoading = false);

        if (!mounted) return;

        if (result['success']) {
          _showSnackBar(
            'Connexion réussie ! Bienvenue ${result['data']['prenom']}',
            Colors.green,
          );

          // Navigation vers la page d'accueil
          Navigator.pushReplacementNamed(context, '/home');
        } else {
          _showErrorDialog(result['message']);
        }
      } catch (e) {
        setState(() => _isLoading = false);
        _showErrorDialog('Une erreur inattendue s\'est produite');
      }
    }
  }

  void _handleForgotPassword() {
    _showSnackBar(
      'Fonctionnalité en cours de développement',
      Colors.blue,
    );
  }

  void _handleGoogleLogin() {
    _showSnackBar(
      'Connexion Google en cours de développement',
      Colors.blue,
    );
  }

  void _handleAppleLogin() {
    _showSnackBar(
      'Connexion Apple en cours de développement',
      Colors.blue,
    );
  }

  void _navigateToSignUp() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SignUpPage()),
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
        title: Row(
          children: const [
            Icon(Icons.error_outline, color: Colors.red, size: 28),
            SizedBox(width: 12),
            Text('Erreur de connexion'),
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
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 60),

                  // Logo et titre
                  const LoginHeader(),

                  const SizedBox(height: 48),

                  // Formulaire
                  LoginEmailField(
                    controller: _emailController,
                    isLoading: _isLoading,
                  ),
                  const SizedBox(height: 16),

                  LoginPasswordField(
                    controller: _passwordController,
                    isLoading: _isLoading,
                  ),

                  const SizedBox(height: 12),

                  // Mot de passe oublié
                  ForgotPasswordLink(
                    isLoading: _isLoading,
                    onPressed: _handleForgotPassword,
                  ),

                  const SizedBox(height: 32),

                  // Bouton de connexion
                  LoginButton(
                    isLoading: _isLoading,
                    onPressed: _handleLogin,
                  ),

                  const SizedBox(height: 24),

                  // Séparateur
                  const LoginDivider(),

                  const SizedBox(height: 24),

                  // Connexion avec Google/Apple
                  SocialLoginButtons(
                    isLoading: _isLoading,
                    onGooglePressed: _handleGoogleLogin,
                    onApplePressed: _handleAppleLogin,
                  ),

                  const SizedBox(height: 32),

                  // Lien vers inscription
                  SignUpLink(
                    isLoading: _isLoading,
                    onTap: _navigateToSignUp,
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