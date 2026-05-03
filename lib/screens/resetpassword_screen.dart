import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nota/widgets/auth_button.dart';
import 'package:nota/widgets/auth_header.dart';
import 'package:nota/widgets/auth_text_field.dart';
import '../screens/auth_screen.dart';
import '../helper/auth_validators.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _linkSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _linkSent = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NotaColors.bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const AuthHeader(),
                const SizedBox(height: 28),

                // Back to Login
                GestureDetector(
                  onTap: () => context.pop(),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.chevron_left_rounded,
                        color: NotaColors.purple,
                        size: 20,
                      ),
                      Text(
                        'Back to Login',
                        style: TextStyle(
                          color: NotaColors.purple,
                          fontSize: 14,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Title
                const Text(
                  'Reset Password',
                  style: TextStyle(
                    color: NotaColors.textPrimary,
                    fontSize: 22,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 24),

                if (_linkSent) ...[
                  // Success banner
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 18,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0D2B1A),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: const Color(0xFF22C55E).withValues(alpha: 0.3),
                      ),
                    ),
                    child: const Text(
                      'Reset link sent to your email',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFF22C55E),
                        fontSize: 14,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ] else ...[
                  // Email field
                  AuthTextField(
                    controller: _emailController,
                    hintText: 'your@email.com',
                    keyboardType: TextInputType.emailAddress,
                    validator: AuthValidators.validateEmail,
                  ),
                  const SizedBox(height: 20),

                  // Send Reset Link button
                  AuthButton(label: 'Send Reset Link', onTap: _submit),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
