import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import 'api_service.dart';

class AuthService {
  final ApiService _api = ApiService();

  // Local caching variables
  static String? _currentUserEmail;
  static String? _currentUserId;
  static bool _isLoggedIn = false;
  static String? _lastVerifiedOtp;

  bool get isLoggedInLocally => _isLoggedIn;
  String? get currentEmail => _currentUserEmail;
  String? get currentUserId => _currentUserId;

  // ─── Helper to extract clean error message ─────────────────────────────
  String _extractMessage(dynamic responseData, String fallback) {
    if (responseData is Map<String, dynamic>) {
      return responseData['message'] ?? fallback;
    }
    return fallback;
  }

  // ─── EMAIL + PASSWORD AUTH (REST API) ──────────────────────────────────

  Future<void> signInWithEmailPassword(String email, String password) async {
    try {
      final response = await _api.post('/auth/login', data: {
        'email': email,
        'password': password,
      });

      final statusCode = response.statusCode ?? 500;

      if (statusCode >= 200 && statusCode < 300) {
        final data = response.data;
        final token = data['token'] as String;
        final userMap = data['user'] as Map<String, dynamic>;

        await _api.saveToken(token);
        _currentUserEmail = userMap['email'];
        _currentUserId = userMap['uid']?.toString();
        _isLoggedIn = true;
        await _saveSession(email, _currentUserId!);
      } else {
        throw Exception(_extractMessage(response.data, 'Login failed. Please check your credentials.'));
      }
    } on Exception {
      rethrow;
    } catch (e) {
      throw Exception('Connection error. Please make sure the server is running.');
    }
  }

  Future<void> signUpWithEmailPassword(String email, String password) async {
    try {
      final response = await _api.post('/auth/signup', data: {
        'email': email,
        'password': password,
        'name': email.split('@')[0],
      });

      final statusCode = response.statusCode ?? 500;

      if (statusCode >= 200 && statusCode < 300) {
        final data = response.data;
        final token = data['token'] as String;
        final userMap = data['user'] as Map<String, dynamic>;

        await _api.saveToken(token);
        _currentUserEmail = userMap['email'];
        _currentUserId = userMap['uid']?.toString();
        _isLoggedIn = true;
        await _saveSession(email, _currentUserId!);
      } else {
        throw Exception(_extractMessage(response.data, 'Signup failed. Please try again.'));
      }
    } on Exception {
      rethrow;
    } catch (e) {
      throw Exception('Connection error. Please make sure the server is running.');
    }
  }

  // ─── PASSWORD RESET OTP (REST API) ─────────────────────────────────────

  Future<void> requestPasswordResetOTP(String email) async {
    try {
      final response = await _api.post('/auth/forgot-password', data: {
        'email': email,
      });
      final statusCode = response.statusCode ?? 500;
      if (statusCode < 200 || statusCode >= 300) {
        throw Exception(_extractMessage(response.data, 'Failed to request OTP'));
      }
    } on Exception {
      rethrow;
    } catch (e) {
      throw Exception('Connection error. Please make sure the server is running.');
    }
  }

  Future<bool> verifyPasswordResetOTP(String email, String otp) async {
    try {
      final response = await _api.post('/auth/verify-otp', data: {
        'email': email,
        'otp': otp,
      });
      final statusCode = response.statusCode ?? 500;
      if (statusCode >= 200 && statusCode < 300) {
        _lastVerifiedOtp = otp;
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  Future<void> updatePasswordWithOTP(String email, String newPassword) async {
    try {
      final response = await _api.post('/auth/reset-password', data: {
        'email': email,
        'otp': _lastVerifiedOtp ?? '',
        'password': newPassword,
      });
      final statusCode = response.statusCode ?? 500;
      if (statusCode >= 200 && statusCode < 300) {
        _lastVerifiedOtp = null;
      } else {
        throw Exception(_extractMessage(response.data, 'Failed to reset password'));
      }
    } on Exception {
      rethrow;
    } catch (e) {
      throw Exception('Connection error. Please make sure the server is running.');
    }
  }

  // ─── DEMO LOGIN ───────────────────────────────────────────────────────

  Future<void> demoLogin() async {
    const String email = 'demo@orbit.app';
    const String password = 'demopassword';
    try {
      await signUpWithEmailPassword(email, password);
    } catch (_) {
      try {
        await signInWithEmailPassword(email, password);
      } catch (_) {
        // If backend unreachable, do local demo
        _currentUserEmail = email;
        _currentUserId = 'demo_user';
        _isLoggedIn = true;
        await _saveSession(email, 'demo_user');
      }
    }
  }

  // ─── SIGN OUT ─────────────────────────────────────────────────────────

  Future<void> signOut() async {
    _currentUserEmail = null;
    _currentUserId = null;
    _isLoggedIn = false;
    await _api.clearToken();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('orbit_user_email');
    await prefs.remove('orbit_user_id');
  }

  // ─── USER PROFILE (REST API) ──────────────────────────────────────────

  Future<UserModel?> getUserProfile(String uid) async {
    try {
      final response = await _api.get('/auth/me');
      if (response.statusCode == 200) {
        return UserModel.fromJson(response.data);
      }
    } catch (_) {}
    return null;
  }

  Future<void> createUserProfile(UserModel user) async {
    // Profiling is handled automatically inside backend signup route
  }

  // ─── SESSION PERSISTENCE ──────────────────────────────────────────────

  Future<void> _saveSession(String email, String uid) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('orbit_user_email', email);
    await prefs.setString('orbit_user_id', uid);
  }

  Future<bool> restoreSession() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('orbit_user_email');
    final uid = prefs.getString('orbit_user_id');
    final token = await _api.getToken();

    if (email != null && uid != null && token != null) {
      _currentUserEmail = email;
      _currentUserId = uid;
      _isLoggedIn = true;
      return true;
    }
    return false;
  }
}
