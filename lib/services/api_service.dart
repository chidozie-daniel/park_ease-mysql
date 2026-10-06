import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  String? _token;

  void setToken(String token) {
    _token = token;
  }

  void clearToken() {
    _token = null;
  }

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (_token != null) 'Authorization': 'Bearer $_token',
      };

  Future<http.Response> _send(
    String method,
    Uri uri, {
    Map<String, dynamic>? body,
    required bool requireAuth,
  }) async {
    final headers = requireAuth ? _headers : {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    switch (method) {
      case 'GET':
        return http.get(uri, headers: headers)
            .timeout(ApiConfig.receiveTimeout);
      case 'POST':
        return http
            .post(uri, headers: headers, body: json.encode(body ?? {}))
            .timeout(ApiConfig.receiveTimeout);
      case 'PUT':
        return http
            .put(uri, headers: headers, body: json.encode(body ?? {}))
            .timeout(ApiConfig.receiveTimeout);
      case 'DELETE':
        return http.delete(uri, headers: headers)
            .timeout(ApiConfig.receiveTimeout);
      default:
        throw UnsupportedError('Unsupported method: $method');
    }
  }

  Uri _uri(String endpoint) => Uri.parse('${ApiConfig.baseUrl}$endpoint');

  Future<http.Response> _request(
    String method,
    String endpoint, {
    Map<String, dynamic>? body,
    bool requireAuth = true,
  }) {
    return _send(method, _uri(endpoint), body: body, requireAuth: requireAuth);
  }

  Future<Map<String, dynamic>> get(String endpoint,
      {bool requireAuth = true}) async {
    final response = await _request('GET', endpoint, requireAuth: requireAuth);
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> getUri(Uri uri,
      {bool requireAuth = true}) async {
    final response = await _send('GET', uri, requireAuth: requireAuth);
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> post(String endpoint, Map<String, dynamic> body,
      {bool requireAuth = true}) async {
    final response =
        await _request('POST', endpoint, body: body, requireAuth: requireAuth);
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> put(String endpoint, Map<String, dynamic> body,
      {bool requireAuth = true}) async {
    final response =
        await _request('PUT', endpoint, body: body, requireAuth: requireAuth);
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> delete(String endpoint,
      {bool requireAuth = true}) async {
    final response = await _request('DELETE', endpoint, requireAuth: requireAuth);
    return _handleResponse(response);
  }

  /// A network failure or timeout means the server is unreachable. An
  /// [ApiException] with a 5xx status means the server rejected the request.
  /// Both mean the user should retry; only a 4xx is worth showing verbatim.
  static String describeError(Object error) {
    if (error is ApiException) {
      if (error.statusCode >= 500) {
        return 'The server had a problem. Please try again.';
      }
      return error.message;
    }
    if (error is TimeoutException || error is SocketException) {
      return 'Could not reach the server. Check your connection.';
    }
    return 'Something went wrong. Please try again.';
  }

  Map<String, dynamic> _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return {};
      return json.decode(response.body) as Map<String, dynamic>;
    }

    String? message;
    if (response.body.isNotEmpty) {
      try {
        final decoded = json.decode(response.body);
        if (decoded is Map<String, dynamic>) {
          message = decoded['message'] as String?;
        }
      } catch (_) {
        message = null;
      }
    }
    throw ApiException(
      message ?? 'Request failed (${response.statusCode})',
      response.statusCode,
    );
  }
}

class ApiException implements Exception {
  final String message;
  final int statusCode;

  ApiException(this.message, this.statusCode);

  @override
  String toString() => message;
}