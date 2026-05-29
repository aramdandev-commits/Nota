import 'package:flutter/material.dart';

enum SpaceButtonVariant { primary, secondary, danger }

/// Reusable full-width action button for Space screens.
class SpaceActionButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final SpaceButtonVariant variant;
  final bool isLoading;

  const SpaceActionButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = SpaceButtonVariant.primary,
    this.isLoading = false,
  });

  Color get _bg {
    switch (variant) {
      case SpaceButtonVariant.primary:
        return const Color(0xFF6B58FF);
      case SpaceButtonVariant.secondary:
        return const Color(0xFF202430);
      case SpaceButtonVariant.danger:
        return const Color(0xFFEF4444).withValues(alpha: 0.15);
    }
  }

  Color get _fg {
    switch (variant) {
      case SpaceButtonVariant.primary:
        return Colors.white;
      case SpaceButtonVariant.secondary:
        return Colors.white;
      case SpaceButtonVariant.danger:
        return const Color(0xFFEF4444);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: _bg,
          foregroundColor: _fg,
          disabledBackgroundColor: _bg.withValues(alpha: 0.5),
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Text(
                label,
                style: TextStyle(
                  color: _fg,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }
}
