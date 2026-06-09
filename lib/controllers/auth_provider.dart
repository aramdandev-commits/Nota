import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/user_model.dart';
import '../services/auth_service.dart';
import '../services/pusher_service.dart';

class AuthProvider extends ChangeNotifier {
  static const _tokenKey = 'auth_token';
  static const _userNameKey = 'auth_user_name';
  static const _userEmailKey = 'auth_user_email';
  static const _userIdKey = 'auth_user_id';

  final String currentApiBaseUrl =
      "https://synopsis-cursive-ethics.ngrok-free.dev";
  // I will replace the string below with the new port 8080 ngrok link when my backend dev sends it
  final String reverbWsHost = "synopsis-cursive-ethics.ngrok-free.dev";

  final _service = AuthService();

  UserModel? _user;
  bool _isLoading = false;
  String? _error;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _user != null;
  String? get token => _user?.token;

  // ── Persistence ───────────────────────────────────────────────────────────

  /// Call once at app start (e.g. in SplashScreen) to restore session.
  Future<bool> tryRestoreSession() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_tokenKey);
    if (token == null || token.isEmpty) return false;

    final userId = prefs.getString(_userIdKey) ?? '';
    _user = UserModel(
      id: userId,
      name: prefs.getString(_userNameKey) ?? '',
      email: prefs.getString(_userEmailKey) ?? '',
      token: token,
    );
    notifyListeners();

    // Initialize Pusher for persistent session
    PusherService().initPusher(
      userId: userId,
      userToken: token,
      websocketHost: reverbWsHost,
      authUrl: "$currentApiBaseUrl/broadcasting/auth",
    );

    return true;
  }

  Future<void> _persistUser(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, user.token);
    await prefs.setString(_userNameKey, user.name);
    await prefs.setString(_userEmailKey, user.email);
    await prefs.setString(_userIdKey, user.id);
  }

  Future<void> _clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userNameKey);
    await prefs.remove(_userEmailKey);
    await prefs.remove(_userIdKey);
  }

  // ── Auth actions ──────────────────────────────────────────────────────────

  /// Returns `null` on success, or an error message string on failure.
  Future<String?> login({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    try {
      final user = await _service.login(email: email, password: password);
      _user = user;
      await _persistUser(user);

      // Initialize Pusher upon login
      PusherService().initPusher(
        userId: user.id.toString(),
        userToken: user.token,
        websocketHost: reverbWsHost,
        authUrl: "$currentApiBaseUrl/broadcasting/auth",
      );

      _error = null;
      return null; // success
    } on AuthException catch (e) {
      _error = e.message;
      return e.message;
    } catch (e) {
      _error = 'Unexpected error. Please try again.';
      return _error;
    } finally {
      _setLoading(false);
    }
  }

  /// Returns `null` on success, or an error message string on failure.
  Future<String?> register({
    required String name,
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    _setLoading(true);
    try {
      final user = await _service.register(
        name: name,
        email: email,
        password: password,
        confirmPassword: confirmPassword,
      );
      _user = user;
      await _persistUser(user);

      // Initialize Pusher upon registration
      PusherService().initPusher(
        userId: user.id.toString(),
        userToken: user.token,
        websocketHost: reverbWsHost,
        authUrl: "$currentApiBaseUrl/broadcasting/auth",
      );

      _error = null;
      return null; // success
    } on AuthException catch (e) {
      _error = e.message;
      return e.message;
    } catch (e) {
      _error = 'Unexpected error. Please try again.';
      return _error;
    } finally {
      _setLoading(false);
    }
  }

  /// Returns `null` on success, or an error message string on failure.
  Future<String?> forgotPassword({required String email}) async {
    _setLoading(true);
    try {
      await _service.forgotPassword(email: email);
      _error = null;
      return null; // success
    } on AuthException catch (e) {
      _error = e.message;
      return e.message;
    } catch (e) {
      _error = 'Unexpected error. Please try again.';
      return _error;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    // Disconnect Pusher before clearing session
    PusherService().disconnect();

    _user = null;
    _error = null;
    await _clearSession();
    notifyListeners();
  }

  // ── helpers ───────────────────────────────────────────────────────────────

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
