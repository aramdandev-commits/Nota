import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// Result returned after a Google Sign-In attempt.
class GoogleSignInResult {
  final String email;
  final String? displayName;
  final String? photoUrl;
  final String? idToken;
  final String? accessToken;

  const GoogleSignInResult({
    required this.email,
    this.displayName,
    this.photoUrl,
    this.idToken,
    this.accessToken,
  });
}

/// Service that wraps Google Sign-In.
///
/// Current behaviour: runs the OAuth flow and returns the user's tokens.
/// The tokens are printed in debug mode so you can verify them.
///
/// ── Connecting to your own API ────────────────────────────────────────────
/// When your backend is ready, add your HTTP call inside [signIn] right after
/// the result is built, for example:
///
/// ```dart
/// final response = await http.post(
///   Uri.parse('$baseUrl/auth/google'),
///   headers: {'Content-Type': 'application/json'},
///   body: jsonEncode({'id_token': result.idToken}),
/// );
/// ```
///
/// ── Android setup (no Firebase needed) ───────────────────────────────────
/// 1. Go to https://console.cloud.google.com → APIs & Services → Credentials
/// 2. Create an OAuth 2.0 Client ID of type "Android"
/// 3. Use your app's package name (com.example.nota) and SHA-1 fingerprint
/// 4. No google-services.json required — just the client ID registered there
/// 5. Pass that client ID to the [GoogleSignIn] constructor below if needed:
///    GoogleSignIn(clientId: 'YOUR_WEB_CLIENT_ID.apps.googleusercontent.com')
///    (Web client ID is used for idToken verification on your backend)
/// ─────────────────────────────────────────────────────────────────────────
class GoogleAuthService {
  GoogleAuthService._();
  static final GoogleAuthService instance = GoogleAuthService._();

  final _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
    // TODO: add your web client ID here when ready:
    // serverClientId: 'YOUR_WEB_CLIENT_ID.apps.googleusercontent.com',
  );

  /// Launches the Google Sign-In flow.
  ///
  /// Returns a [GoogleSignInResult] on success, or `null` if the user
  /// cancelled. Throws on unexpected errors.
  Future<GoogleSignInResult?> signIn() async {
    try {
      final account = await _googleSignIn.signIn();
      if (account == null) return null; // user cancelled

      final auth = await account.authentication;

      final result = GoogleSignInResult(
        email: account.email,
        displayName: account.displayName,
        photoUrl: account.photoUrl,
        idToken: auth.idToken,
        accessToken: auth.accessToken,
      );

      // Debug — remove once backend is wired up
      debugPrint('Google Sign-In success: ${result.email}');
      debugPrint('idToken: ${result.idToken}');
      debugPrint('accessToken: ${result.accessToken}');

      // TODO: send result.idToken to your API here

      return result;
    } catch (e) {
      debugPrint('Google Sign-In error: $e');
      rethrow;
    }
  }

  /// Signs the current user out.
  Future<void> signOut() async {
    await _googleSignIn.signOut();
  }
}
