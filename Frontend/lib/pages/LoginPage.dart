import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import 'SignUpPage.dart';
import '../services/auth_service.dart';
import 'login/login_form_fields.dart';
import 'login/login_ui_components.dart';
import 'package:smart_learn/pages/ForgotPasswordPage.dart';
import '../l10n/app_localizations.dart'; // ✅ Importé

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

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
          final l10n = AppLocalizations.of(context)!;
          _showSnackBar(
            '${l10n.loginSuccess} ${l10n.welcome} ${result['data']['prenom']}',
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
  }

  void _handleForgotPassword() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ForgotPasswordPage()),
    );
    final l10n = AppLocalizations.of(context)!;
    _showSnackBar(l10n.featureInDevelopment, Colors.blue);
  }

  void _handleGoogleLogin() {
    final l10n = AppLocalizations.of(context)!;
    _showSnackBar('${l10n.continueWithGoogle} - ${l10n.featureInDevelopment}', Colors.blue);
  }

  void _handleAppleLogin() {
    final l10n = AppLocalizations.of(context)!;
    _showSnackBar('${l10n.continueWithApple} - ${l10n.featureInDevelopment}', Colors.blue);
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
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 28),
            const SizedBox(width: 12),
            Text(l10n.loginError),
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
    final l10n = AppLocalizations.of(context)!; // ✅ Récupérer les traductions

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
                  LoginHeader(l10n: l10n), // ✅ Passer l10n

                  const SizedBox(height: 48),

                  // Champ Email
                  TextFormField(
                    controller: _emailController,
                    enabled: !_isLoading,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: l10n.email, // ✅ Traduit
                      prefixIcon: const Icon(Icons.email_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return l10n.emailRequired; // ✅ Traduit
                      }
                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                        return l10n.invalidEmail; // ✅ Traduit
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  // Champ Mot de passe
                  TextFormField(
                    controller: _passwordController,
                    enabled: !_isLoading,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: l10n.password, // ✅ Traduit
                      prefixIcon: const Icon(Icons.lock_outline),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return l10n.oldPasswordRequired; // ✅ Traduit
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 12),

                  // Mot de passe oublié
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: _isLoading ? null : _handleForgotPassword,
                      child: Text(l10n.forgotPassword), // ✅ Traduit
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Bouton de connexion
                  ElevatedButton(
                    onPressed: _isLoading ? null : _handleLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF5B9FD8),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                        : Text(
                      l10n.loginButton, // ✅ Traduit
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Séparateur
                  Row(
                    children: [
                      const Expanded(child: Divider()),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          l10n.orContinueWith, // ✅ Traduit
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ),
                      const Expanded(child: Divider()),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Bouton Google
                  OutlinedButton.icon(
                    onPressed: _isLoading ? null : _handleGoogleLogin,
                    icon: const Icon(Icons.g_mobiledata, size: 28),
                    label: Text(l10n.continueWithGoogle), // ✅ Traduit
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Bouton Apple
                  OutlinedButton.icon(
                    onPressed: _isLoading ? null : _handleAppleLogin,
                    icon: const Icon(Icons.apple, size: 24),
                    label: Text(l10n.continueWithApple), // ✅ Traduit
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Lien vers inscription
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(l10n.dontHaveAccount), // ✅ Traduit
                      TextButton(
                        onPressed: _isLoading ? null : _navigateToSignUp,
                        child: Text(
                          l10n.signUp, // ✅ Traduit
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
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

// Widget LoginHeader mis à jour
class LoginHeader extends StatelessWidget {
  final AppLocalizations l10n;

  const LoginHeader({super.key, required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: const Color(0xFF5B9FD8),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Icon(
            Icons.school,
            size: 40,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          l10n.loginTitle, // ✅ Traduit
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2D3436),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          l10n.loginSubtitle, // ✅ Traduit
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[600],
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}