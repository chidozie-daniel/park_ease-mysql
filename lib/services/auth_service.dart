import 'dart:async';
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
      'email': email,
      'password': password,
    }, requireAuth: false);

    if (response['token'] != null) {
      await _saveToken(response['token']);
    }
    if (response['user'] != null) {
      await _saveUser(User.fromJson(response['user']));
    }
    return response;
  }

  Future<Map<String, dynamic>> register(
    String name,
    String email,
    String phone,
    String password,
  ) async {
    final response = await _api.post(ApiConfig.authRegister, {
      'name': name,
      'email': email,
      'phone': phone,
      'password': password,
    }, requireAuth: false);

    if (response['token'] != null) {
      await _saveToken(response['token']);
    }
    if (response['user'] != null) {
      await _saveUser(User.fromJson(response['user']));
    }
    return response;
  }

  Future<void> logout() async {
    final logoutRequest = _api.post(ApiConfig.authLogout, {});
    await _clearAuth();
    unawaited(_completeServerLogout(logoutRequest));
  }

  Future<void> _completeServerLogout(
    Future<Map<String, dynamic>> logoutRequest,
  ) async {
    try {
      await logoutRequest;
    } catch (error) {
      debugPrint('Server logout failed after local logout: $error');
    }
  }

  Future<Map<String, dynamic>> sendOtp(String email) async {
    return await _api.post(ApiConfig.authOtp, {
      'email': email,
    }, requireAuth: false);
  }

  Future<Map<String, dynamic>> verifyOtp(String email, String otp) async {
    return await _api.post(ApiConfig.authOtp, {
      'email': email,
      'otp': otp,
    }, requireAuth: false);
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
