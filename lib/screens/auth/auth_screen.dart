import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'resetpassword_screen.dart';
import '../../widgets/auth/auth_button.dart';
import '../../widgets/auth/auth_divider.dart';
import '../../widgets/auth/auth_footer.dart';
import '../../widgets/auth/auth_header.dart';
import '../../widgets/auth/auth_tab_toggle.dart';
import '../../widgets/auth/auth_text_field.dart';
import '../../widgets/auth/social_buttons_row.dart';
import '../../helper/auth_validators.dart';

// Colors removed, using theme context

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _isLogin = true;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  void _switchMode(bool isLogin) {
    setState(() {
      _isLogin = isLogin;
    });
  }

  void _toggleMode() {
    setState(() {
      _isLogin = !_isLogin;
    });
  }

  void _submit() {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) return;

    if (_isLogin) {
      debugPrint('Login => ${_emailController.text}');
      context.go('/home');
    } else {
      debugPrint(
        'Sign Up => ${_nameController.text} | ${_emailController.text}',
      );
      context.push('/account-created');
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Widget _buildLabel(String text) {
    return const SizedBox.shrink();
  }

  Widget _sectionLabel(String text, ColorScheme cs) {
    return Text(
      text,
      style: TextStyle(
        color: cs.onSurface.withValues(alpha: 0.5),
        fontSize: 13,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const AuthHeader(),
                const SizedBox(height: 32),
                AuthTabToggle(
                  isLogin: _isLogin,
                  onLoginTap: () => _switchMode(true),
                  onSignUpTap: () => _switchMode(false),
                ),
                const SizedBox(height: 28),
                if (!_isLogin) ...[
                  _sectionLabel('Full Name', cs),
                  const SizedBox(height: 8),
                  AuthTextField(
                    controller: _nameController,
                    hintText: 'John Doe',
                    validator: AuthValidators.validateName,
                  ),
                  const SizedBox(height: 18),
                ],
                _sectionLabel('Email', cs),
                const SizedBox(height: 8),
                AuthTextField(
                  controller: _emailController,
                  hintText: 'your@email.com',
                  keyboardType: TextInputType.emailAddress,
                  validator: AuthValidators.validateEmail,
                ),
                const SizedBox(height: 18),
                _sectionLabel('Password', cs),
                const SizedBox(height: 8),
                AuthTextField(
                  controller: _passwordController,
                  hintText: '••••••••',
                  obscureText: _obscurePassword,
                  validator: AuthValidators.validatePassword,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: cs.onSurface.withValues(alpha: 0.5),
                      size: 20,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                ),
                if (_isLogin) ...[
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const ResetPasswordScreen(),
                          ),
                        );
                      },
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text(
                        'Forgot Password?',
                        style: TextStyle(
                          color: Color(0xFF9810FA),
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
                if (!_isLogin) ...[
                  const SizedBox(height: 18),
                  _sectionLabel('Confirm Password', cs),
                  const SizedBox(height: 8),
                  AuthTextField(
                    controller: _confirmPasswordController,
                    hintText: '••••••••',
                    obscureText: _obscureConfirmPassword,
                    validator: (value) =>
                        AuthValidators.validateConfirmPassword(
                      value,
                      _passwordController.text,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirmPassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: cs.onSurface.withValues(alpha: 0.5),
                        size: 20,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureConfirmPassword = !_obscureConfirmPassword;
                        });
                      },
                    ),
                  ),
                ],
                const SizedBox(height: 28),
                AuthButton(
                  label: _isLogin ? 'Log In' : 'Create Account',
                  onTap: _submit,
                ),
                const SizedBox(height: 22),
                AuthFooter(isLogin: _isLogin, onActionTap: _toggleMode),
                const SizedBox(height: 24),
                AuthDivider(
                  text: _isLogin ? 'OR LOGIN WITH' : 'OR SIGN UP WITH',
                ),
                const SizedBox(height: 20),
                const SocialButtonsRow(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
