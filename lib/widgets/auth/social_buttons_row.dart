import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../controllers/google_auth_service.dart';
import '../../screens/auth/auth_screen.dart';

class SocialButtonsRow extends StatefulWidget {
  const SocialButtonsRow({super.key});

  @override
  State<SocialButtonsRow> createState() => _SocialButtonsRowState();
}

class _SocialButtonsRowState extends State<SocialButtonsRow> {
  bool _loading = false;

  Future<void> _handleGoogleSignIn() async {
    if (_loading) return;
    setState(() => _loading = true);

    try {
      await GoogleAuthService.instance.signIn();
      // TODO: navigate or update auth state once backend is connected
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Google Sign-In failed. Please try again.',
              style: const TextStyle(fontFamily: 'Inter'),
            ),
            backgroundColor: const Color(0xFF2B0D0D),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleGoogleSignIn,
      child: Container(
        width: double.infinity,
        height: 52,
        decoration: BoxDecoration(
          color: NotaColors.socialBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: NotaColors.border),
        ),
        child: _loading
            ? const Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    'assets/images/google.svg',
                    width: 22,
                    height: 22,
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'Continue with Google',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
