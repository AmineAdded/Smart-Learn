import 'package:flutter/material.dart';
import '../services/password_reset_service.dart';
import 'reset_password/reset_password_widgets.dart';

class ResetPasswordPage extends StatefulWidget {
  final String token;

  const ResetPasswordPage({
    Key? key,
    required this.token,
  }) : super(key: key);

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _passwordResetService = PasswordResetService();

  bool _isLoading = false;
  bool _isVerifying = true;
  bool _isTokenValid = false;
  String? _userEmail;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _verifyToken();
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  /// Vérifier la validité du token au chargement de la page
  Future<void> _verifyToken() async {
    final result = await _passwordResetService.verifyToken(
      token: widget.token,
    );

    setState(() {
      _isVerifying = false;
      _isTokenValid = result['success'];
      _userEmail = result['email'];
      _errorMessage = result['message'];
    });
  }

  /// Réinitialiser le mot de passe
  Future<void> _handleResetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final result = await _passwordResetService.resetPassword(
      token: widget.token,
      newPassword: _passwordController.text,
    );

    setState(() => _isLoading = false);

    if (!mounted) return;

    if (result['success']) {
      _showSuccessDialog();
    } else {
      _showErrorDialog(result['message']);
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: const [
            Icon(Icons.check_circle, color: Color(0xFF00B894), size: 28),
            SizedBox(width: 12),
            Text('Succès !'),
          ],
        ),
        content: const Text(
          'Votre mot de passe a été réinitialisé avec succès.\n\nVous pouvez maintenant vous connecter avec votre nouveau mot de passe.',
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop(); // Fermer le dialogue
              Navigator.of(context).pushNamedAndRemoveUntil(
                '/login',
                    (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF5B9FD8),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Se connecter'),
          ),
        ],
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

  void _navigateToForgotPassword() {
    Navigator.of(context).pushReplacementNamed('/forgot-password');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Color(0xFF2D3436)),
          onPressed: () => Navigator.of(context).pushNamedAndRemoveUntil(
            '/login',
                (route) => false,
          ),
        ),
      ),
      body: SafeArea(
        child: _isVerifying
            ? const TokenVerificationLoader()
            : !_isTokenValid
            ? TokenErrorWidget(
          message: _errorMessage ?? 'Le lien est invalide ou a expiré',
          onRetry: _navigateToForgotPassword,
        )
            : SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 40),

                  // En-tête
                  const ResetPasswordHeader(),

                  const SizedBox(height: 16),

                  // Afficher l'email
                  if (_userEmail != null) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF6C5CE7).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.email_outlined,
                            size: 20,
                            color: Color(0xFF6C5CE7),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _userEmail!,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Critères du mot de passe
                  const PasswordCriteriaBox(),

                  const SizedBox(height: 24),

                  // Champ nouveau mot de passe
                  NewPasswordField(
                    controller: _passwordController,
                    isLoading: _isLoading,
                  ),

                  const SizedBox(height: 16),

                  // Champ confirmer mot de passe
                  ConfirmPasswordField(
                    controller: _confirmPasswordController,
                    passwordController: _passwordController,
                    isLoading: _isLoading,
                  ),

                  const SizedBox(height: 32),

                  // Bouton réinitialiser
                  ResetPasswordButton(
                    isLoading: _isLoading,
                    onPressed: _handleResetPassword,
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