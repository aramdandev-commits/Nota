import 'package:flutter/material.dart';
import 'package:nota/l10n/app_localizations.dart';

class AuthValidators {
  static String? validateName(BuildContext context, String? value) {
    final l10n = AppLocalizations.of(context)!;

    if (value == null || value.trim().isEmpty) {
      return l10n.name;
    }

    if (value.trim().length < 3) {
      return l10n.validationName;
    }

    return null;
  }

  static String? validateEmail(BuildContext context, String? value) {
    final l10n = AppLocalizations.of(context)!;

    if (value == null || value.trim().isEmpty) {
      return l10n.email;
    }

    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!emailRegex.hasMatch(value.trim())) {
      return l10n.invalidEmailAddress;
    }

    return null;
  }

  static String? validatePassword(BuildContext context, String? value) {
    final l10n = AppLocalizations.of(context)!;

    if (value == null || value.isEmpty) {
      return l10n.password;
    }

    if (value.length < 8) {
      return l10n.validationPasswordAtLeast8Characters;
    }

    if (!value.contains(RegExp(r'[a-z]'))) {
      return l10n.validationPasswordLowercaseLetters;
    }

    if (!value.contains(RegExp(r'[A-Z]'))) {
      return l10n.validationPasswordUppercaseLetters;
    }

    if (!value.contains(RegExp(r'[0-9]'))) {
      return l10n.validationPasswordNumbers;
    }

    if (!value.contains(RegExp(r'[!@#\$%^&*(),.?":{}|<>]'))) {
      return l10n.validationPasswordSpecialCharacter;
    }

    return null;
  }

  static String? validateConfirmPassword(
    BuildContext context,
    String? value,
    String originalPassword,
  ) {
    if (value == null || value.isEmpty) {
      return AppLocalizations.of(context)!.confirmPassword;
    }

    if (value != originalPassword) {
      return AppLocalizations.of(context)!.validationConfirmPassword;
    }

    return null;
  }
}
