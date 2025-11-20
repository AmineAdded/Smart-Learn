import 'package:flutter/material.dart';
import 'SignUpPage.dart';
import '../services/auth_service.dart';
import 'login/login_form_fields.dart';
import 'login/login_ui_components.dart';
import 'package:smart_learn/pages/ForgotPasswordPage.dart';
import '../l10n/app_localizations.dart'; // AJOUTÉ

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
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final result = await _authService.login(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      setState(() => _isLoading = false);
      if (!mounted) return;

      if (result['success']) {
        final l10n = AppLocalizations.of(context)!;
        _showSnackBar(
          l10n.loginSuccess(result['data']['prenom']),
          Colors.green,
        );
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        _showErrorDialog(result['message']);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      final l10n = AppLocalizations.of(context)!;
      _showErrorDialog(l10n.unexpectedError);
    }
  }

  void _handleForgotPassword() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ForgotPasswordPage()),
    );
  }

  void _handleGoogleLogin() {
    final l10n = AppLocalizations.of(context)!;
    _showSnackBar(l10n.featureInDevelopment, Colors.blue);
  }

  void _navigateToSignUp() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SignUpPage()),
    );
  }

  void _showSnackBar(String message, Color backgroundColor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _showErrorDialog(String message) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        icon: Icon(Icons.error_outline, color: Colors.red, size: 28),
        title: Text(l10n.loginError),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.ok, style: TextStyle(color: colorScheme.primary)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      // Plus de Colors.white → compatible dark mode
      backgroundColor: colorScheme.surface,
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

                  // Composants déjà traduits
                  LoginHeader(l10n: l10n),

                  const SizedBox(height: 48),

                  LoginEmailField(
                    controller: _emailController,
                    isLoading: _isLoading,
                    l10n: l10n,
                  ),
                  const SizedBox(height: 16),

                  LoginPasswordField(
                    controller: _passwordController,
                    isLoading: _isLoading,
                    l10n: l10n,
                  ),

                  const SizedBox(height: 12),

                  ForgotPasswordLink(
                    isLoading: _isLoading,
                    onPressed: _handleForgotPassword,
                    l10n: l10n,
                  ),

                  const SizedBox(height: 32),

                  LoginButton(
                    isLoading: _isLoading,
                    onPressed: _handleLogin,
                    l10n: l10n,
                  ),

                  const SizedBox(height: 24),

                  LoginDivider(l10n: l10n),

                  const SizedBox(height: 24),

                  SocialLoginButtons(
                    isLoading: _isLoading,
                    onGooglePressed: _handleGoogleLogin,
                    l10n: l10n,
                  ),

                  const SizedBox(height: 32),

                  SignUpLink(
                    isLoading: _isLoading,
                    onTap: _navigateToSignUp,
                    l10n: l10n,
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