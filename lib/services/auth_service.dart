import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'api_service.dart';
import '../config/api_config.dart';
import '../models/user.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  late final SharedPreferences _prefs;
  final _api = ApiService();

  User? _currentUser;
  User? get currentUser => _currentUser;
  bool get isAuthenticated => _token != null;
  String? _token;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _token = _prefs.getString(ApiConfig.tokenKey);
    if (_token != null) {
      _api.setToken(_token!);
    }
    final userJson = _prefs.getString(ApiConfig.userKey);
    if (userJson != null) {
      try {
        _currentUser = User.fromJson(_decodeJson(userJson));
      } catch (_) {}
    }
    if (_token != null) {
      await _validateCachedSession();
    }
  }

  Future<void> _validateCachedSession() async {
    try {
      final response = await _api.get(ApiConfig.authMe);
      final userData = response['user'];
      if (userData is Map<String, dynamic>) {
        await _saveUser(User.fromJson(userData));
      }
    } on ApiException catch (error) {
      if (error.statusCode == 401 || error.statusCode == 403) {
        await _clearAuth();
      }
    } catch (error) {
      debugPrint('Could not validate cached session: $error');
    }
  }

  Map<String, dynamic> _decodeJson(String json) =>
      jsonDecode(json) as Map<String, dynamic>;

  Future<void> _saveToken(String token) async {
    _token = token;
    await _prefs.setString(ApiConfig.tokenKey, token);
    _api.setToken(token);
  }

  Future<void> _saveUser(User user) async {
    _currentUser = user;
    await _prefs.setString(ApiConfig.userKey, jsonEncode(user.json()));
  }

  Future<void> _clearAuth() async {
    _token = null;
    _currentUser = null;
    await _prefs.remove(ApiConfig.tokenKey);
    await _prefs.remove(ApiConfig.userKey);
    _api.clearToken();
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await _api.post(ApiConfig.authLogin, {
      'email': email.trim(),
      'password': password,
    }, requireAuth: false);

    await _saveSession(response);
    return response;
  }

  Future<Map<String, dynamic>> loginAdmin(
    String email,
    String password,
  ) async {
    final response = await _api.post(ApiConfig.authLogin, {
      'email': email.trim(),
      'password': password,
    }, requireAuth: false);

    final userData = response['user'];
    final role = userData is Map<String, dynamic> ? userData['role'] : null;
    if (role != 'admin') {
      await _clearAuth();
      throw ApiException('Access denied. Admin credentials required.', 403);
    }

    await _saveSession(response);
    return response;
  }

  Future<Map<String, dynamic>> register(
    String name,
    String email,
    String phone,
    String password,
  ) async {
    return await _api.post(ApiConfig.authRegister, {
      'name': name,
      'email': email,
      'phone': phone,
      'password': password,
    }, requireAuth: false);
  }

  Future<void> _saveSession(Map<String, dynamic> response) async {
    final token = response['token'];
    final userData = response['user'];
    if (token is! String ||
        token.isEmpty ||
        userData is! Map<String, dynamic>) {
      throw ApiException(
        'The server returned an invalid sign-in response.',
        502,
      );
    }

    final user = User.fromJson(userData);
    await _saveToken(token);
    await _saveUser(user);
  }

  Future<void> logout() async {
    try {
      await _api.post(ApiConfig.authLogout, {});
    } catch (error) {
      debugPrint('Server logout failed: $error');
    } finally {
      await _clearAuth();
    }
  }

  Future<Map<String, dynamic>> sendOtp(
    String email, {
    String purpose = 'register',
  }) async {
    if (purpose == 'password_reset') {
      return forgotPassword(email);
    }
    return await _api.post(ApiConfig.authOtp, {
      'email': email,
    }, requireAuth: false);
  }

  Future<Map<String, dynamic>> verifyOtp(String email, String otp) async {
    final response = await _api.post(ApiConfig.authOtp, {
      'email': email,
      'otp': otp,
    }, requireAuth: false);
    if (response['token'] != null && response['user'] != null) {
      await _saveSession(response);
    }
    return response;
  }

  Future<Map<String, dynamic>> forgotPassword(String email) async {
    return await _api.post(ApiConfig.authForgotPassword, {
      'email': email,
    }, requireAuth: false);
  }

  Future<Map<String, dynamic>> resetPassword(
    String email,
    String otp,
    String newPassword,
  ) async {
    return await _api.post(ApiConfig.authResetPassword, {
      'email': email,
      'otp': otp,
      'newPassword': newPassword,
    }, requireAuth: false);
  }

  Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> data) async {
    final response = await _api.put('/api/v1/users/profile', data);
    if (response['user'] != null) {
      await _saveUser(User.fromJson(response['user']));
    }
    return response;
  }

  bool get isAdmin => _currentUser?.role == 'admin';
}
