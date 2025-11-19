import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/password_reset_service.dart';
import 'ResetPasswordPage.dart';

class VerifyCodePage extends StatefulWidget {
  final String email;

  const VerifyCodePage({
    Key? key,
    required this.email,
  }) : super(key: key);

  @override
  State<VerifyCodePage> createState() => _VerifyCodePageState();
}

class _VerifyCodePageState extends State<VerifyCodePage> {
  final _passwordResetService = PasswordResetService();
  final List<TextEditingController> controllers = List.generate(6, (index) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());
  bool _isLoading = false;
  String _errorMessage = '';
  @override
  void dispose() {
  for (var controller in controllers) {
  controller.dispose();
  }
  for (var node in _focusNodes) {
  node.dispose();
  }
  super.dispose();
  }
  String _getCode() {
  return controllers.map((controller) => controller.text).join();
  }
  Future<void> _verifyCode() async {
  final code = _getCode();
  if (code.length != 6) {
  setState(() => _errorMessage = 'Veuillez entrer les 6 chiffres');
  return;
  }

  setState(() {
  _isLoading = true;
  _errorMessage = '';
  });

  final result = await _passwordResetService.verifyCode(code: code);

  setState(() => _isLoading = false);

  if (!mounted) return;

  if (result['success']) {
  // ✅ Naviguer vers la page de réinitialisation avec le token
  Navigator.pushReplacement(
  context,
  MaterialPageRoute(
  builder: (context) => ResetPasswordPage(
  token: result['token'], // ✅ Token UUID du backend
  ),
  ),
  );
  } else {
  setState(() => _errorMessage = result['message']);
  // Vider les champs en cas d'erreur
  for (var controller in controllers) {
  controller.clear();
  }
  _focusNodes[0].requestFocus();
  }
  }
  Future<void> _resendCode() async {
  setState(() => _isLoading = true);
  final result = await _passwordResetService.forgotPassword(
  email: widget.email,
  );

  setState(() => _isLoading = false);

  if (!mounted) return;

  if (result['success']) {
  ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(
  content: const Text('Un nouveau code a été envoyé'),
  backgroundColor: Colors.green,
  behavior: SnackBarBehavior.floating,
  ),
  );
  }
  }
  @override
  Widget build(BuildContext context) {
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
  child: Column(
  crossAxisAlignment: CrossAxisAlignment.stretch,
  children: [
  const SizedBox(height: 40),
  // Icône
  Container(
  width: 80,
  height: 80,
  decoration: BoxDecoration(
  color: const Color(0xFF6C5CE7).withOpacity(0.1),
  borderRadius: BorderRadius.circular(20),
  ),
  child: const Icon(
  Icons.mail_outline,
  size: 40,
  color: Color(0xFF6C5CE7),
  ),
  ),

  const SizedBox(height: 24),

  // Titre
  const Text(
  'Vérification du code',
  style: TextStyle(
  fontSize: 28,
  fontWeight: FontWeight.bold,
  color: Color(0xFF2D3436),
  ),
  ),

  const SizedBox(height: 12),

  // Description
  Text(
  'Nous avons envoyé un code à 6 chiffres à',
  textAlign: TextAlign.center,
  style: TextStyle(
  fontSize: 15,
  color: Colors.grey[600],
  ),
  ),

  const SizedBox(height: 8),

  Text(
  widget.email,
  textAlign: TextAlign.center,
  style: const TextStyle(
  fontSize: 16,
  fontWeight: FontWeight.w600,
  color: Color(0xFF6C5CE7),
  ),
  ),

  const SizedBox(height: 48),

  // Champs de code OTP
  Row(
  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  children: List.generate(
  6,
  (index) => _buildCodeBox(index),
  ),
  ),

  if (_errorMessage.isNotEmpty) ...[
  const SizedBox(height: 16),
  Text(
  _errorMessage,
  textAlign: TextAlign.center,
  style: const TextStyle(
  color: Colors.red,
  fontSize: 14,
  ),
  ),
  ],

  const SizedBox(height: 32),

  // Bouton vérifier
  SizedBox(
  height: 56,
  child: ElevatedButton(
  onPressed: _isLoading ? null : _verifyCode,
  style: ElevatedButton.styleFrom(
  backgroundColor: const Color(0xFF6C5CE7),
  foregroundColor: Colors.white,
  elevation: 0,
  disabledBackgroundColor: Colors.grey[300],
  shape: RoundedRectangleBorder(
  borderRadius: BorderRadius.circular(12),
  ),
  ),
  child: _isLoading
  ? const SizedBox(
  height: 24,
  width: 24,
  child: CircularProgressIndicator(
  color: Colors.white,
  strokeWidth: 2,
  ),
  )
      : const Text(
  'Vérifier le code',
  style: TextStyle(
  fontSize: 16,
  fontWeight: FontWeight.w600,
  ),
  ),
  ),
  ),

  const SizedBox(height: 24),

  // Lien pour renvoyer le code
  Row(
  mainAxisAlignment: MainAxisAlignment.center,
  children: [
  Text(
  'Vous n\'avez pas reçu le code ? ',
  style: TextStyle(
  fontSize: 14,
  color: Colors.grey[600],
  ),
  ),
  GestureDetector(
  onTap: _isLoading ? null : _resendCode,
  child: const Text(
  'Renvoyer',
  style: TextStyle(
  fontSize: 14,
  color: Color(0xFF6C5CE7),
  fontWeight: FontWeight.w600,
  ),
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
  );
  }
  Widget _buildCodeBox(int index) {
  return Container(
  width: 50,
  height: 60,
  decoration: BoxDecoration(
  color: Colors.white,
  borderRadius: BorderRadius.circular(12),
  border: Border.all(
  color: controllers[index].text.isNotEmpty
  ? const Color(0xFF6C5CE7)
      : Colors.grey[300]!,
  width: 2,
  ),
  ),
  child: TextField(
  controller: controllers[index],
  focusNode: _focusNodes[index],
  textAlign: TextAlign.center,
  keyboardType: TextInputType.number,
  maxLength: 1,
  style: const TextStyle(
  fontSize: 24,
  fontWeight: FontWeight.bold,
  color: Color(0xFF2D3436),
  ),
  decoration: const InputDecoration(
  counterText: '',
  border: InputBorder.none,
  ),
  inputFormatters: [
  FilteringTextInputFormatter.digitsOnly,
  ],
  onChanged: (value) {
  setState(() => _errorMessage = '');
  if (value.isNotEmpty && index < 5) {
  _focusNodes[index + 1].requestFocus();
  }

  // Auto-vérifier quand tous les champs sont remplis
  if (index == 5 && value.isNotEmpty) {
  _verifyCode();
  }
  },
  onTap: () {
  // Sélectionner le texte au clic
  controllers[index].selection = TextSelection(
  baseOffset: 0,
  extentOffset: controllers[index].text.length,
  );
  },
  ),
  );
  }
}