import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../services/password_reset_service.dart';
import 'forgot_password/forgot_password_widgets.dart';
import 'VerifyCodePage.dart'; // ✅ Nouvelle page

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({Key? key}) : super(key: key);

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordResetService = PasswordResetService();

  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleSendCode() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final result = await _passwordResetService.forgotPassword(
      email: _emailController.text.trim(),
    );

    setState(() => _isLoading = false);

    if (!mounted) return;

    if (result['success']) {
      // ✅ Naviguer vers la page de vérification du code
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => VerifyCodePage(
            email: _emailController.text.trim(),
          ),
        ),
      );
    } else {
      _showErrorDialog(result['message']);
    }
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
            Text('Erreur'),
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
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: Colors.white,
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
                  const SizedBox(height: 40),
                  ForgotPasswordHeader(l10n: l10n),
                  const SizedBox(height: 48),

                  ForgotPasswordEmailField(
                    controller: _emailController,
                    isLoading: _isLoading,
                    l10n: l10n,
                  ),

                  const SizedBox(height: 32),

                  SendCodeButton( // ✅ Nouveau bouton
                    isLoading: _isLoading,
                    onPressed: _handleSendCode,
                    l10n: l10n,
                  ),

                  const SizedBox(height: 24),

                  BackToLoginLink(
                    onTap: () => Navigator.pop(context),
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