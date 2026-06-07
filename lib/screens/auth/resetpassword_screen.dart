import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nota/controllers/auth_provider.dart';
import 'package:nota/l10n/app_localizations.dart';
import 'package:nota/widgets/auth/auth_button.dart';
import 'package:nota/widgets/auth/auth_header.dart';
import 'package:nota/widgets/auth/auth_text_field.dart';
import 'package:provider/provider.dart';
import '../../helper/auth_validators.dart';

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

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final error = await context.read<AuthProvider>().forgotPassword(
          email: _emailController.text.trim(),
        );

    if (!mounted) return;

    if (error == null) {
      setState(() => _linkSent = true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error),
          backgroundColor: const Color(0xFFDB2777),
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isLoading = context.watch<AuthProvider>().isLoading;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.chevron_left_rounded,
                        color: Color(0xFF9810FA),
                        size: 20,
                      ),
                      Text(
                        AppLocalizations.of(context)!.backToLogin,
                        style: const TextStyle(
                          color: Color(0xFF9810FA),
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
                Text(
                  AppLocalizations.of(context)!.resetPassword,
                  style: TextStyle(
                    color: cs.onSurface,
                    fontSize: 22,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  AppLocalizations.of(context)!.resetPasswordSubtitle,
                  style: TextStyle(
                    color: cs.onSurface.withValues(alpha: 0.5),
                    fontSize: 14,
                    fontFamily: 'Inter',
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
                    child: Column(
                      children: [
                        const Icon(Icons.mark_email_read_outlined,
                            color: Color(0xFF22C55E), size: 32),
                        const SizedBox(height: 10),
                        Text(
                          AppLocalizations.of(context)!.passwordResetLinkSent,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Color(0xFF22C55E),
                            fontSize: 14,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  AuthButton(
                    label: AppLocalizations.of(context)!.backToLogin,
                    onTap: () => context.pop(),
                  ),
                ] else ...[
                  // Email field
                  AuthTextField(
                    controller: _emailController,
                    hintText: 'your@email.com',
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) =>
                        AuthValidators.validateEmail(context, value),
                  ),
                  const SizedBox(height: 20),

                  // Send Reset Link button
                  AuthButton(
                    label: AppLocalizations.of(context)!.sendResetLink,
                    onTap: isLoading ? null : _submit,
                    isLoading: isLoading,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
