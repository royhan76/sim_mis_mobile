import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../../core/config/api_config.dart';
import '../models/santri_session.dart';

class ApiException implements Exception {
  ApiException(this.message, [this.statusCode]);

  final String message;
  final int? statusCode;

  @override
  String toString() => message;
}

class AuthApiService {
  AuthApiService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<SantriSession> login({
    required String username,
    required String password,
  }) async {
    late final http.Response response;
    try {
      response = await _client
          .post(
            Uri.parse(ApiConfig.url('mobile/santri/login')),
            headers: const {
              'Accept': 'application/json',
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'username': username,
              'password': password,
            }),
          )
          .timeout(const Duration(seconds: 20));
    } on TimeoutException {
      throw ApiException('Koneksi ke server timeout. Cek IP API dan server Laravel.');
    }

    final payload = _decodeResponse(response.body);
    if (response.statusCode >= 200 && response.statusCode < 300 && payload['success'] == true) {
      return SantriSession.fromJson(payload);
    }

    throw ApiException(
      _normalizeMessage(_extractMessage(response.body, payload, fallback: 'Login gagal.')),
      response.statusCode,
    );
  }

  Future<SantriSession> me(String token) async {
    late final http.Response response;
    try {
      response = await _client
          .get(
            Uri.parse(ApiConfig.url('mobile/santri/me')),
            headers: {
              'Accept': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(const Duration(seconds: 20));
    } on TimeoutException {
      throw ApiException('Koneksi ke server timeout. Cek IP API dan server Laravel.');
    }

    final payload = _decodeResponse(response.body);
    if (response.statusCode >= 200 && response.statusCode < 300 && payload['success'] == true) {
      final data = payload['data'] as Map<String, dynamic>?;
      if (data == null) {
        throw ApiException('Data profil tidak ditemukan.');
      }

      return SantriSession.fromStoredJson({
        'token': token,
        'token_type': 'Bearer',
        'user': data['user'] ?? {},
        'santri': data['santri'],
      });
    }

    throw ApiException(
      '${payload['message'] ?? 'Gagal mengambil profil santri.'}',
      response.statusCode,
    );
  }

  Future<void> logout(String token) async {
    try {
      await _client
          .post(
            Uri.parse(ApiConfig.url('mobile/santri/logout')),
            headers: {
              'Accept': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(const Duration(seconds: 20));
    } on TimeoutException {
      throw ApiException('Koneksi ke server timeout. Cek IP API dan server Laravel.');
    }
  }

  Map<String, dynamic> _decodeResponse(String body) {
    try {
      final trimmed = body.trim();
      if (trimmed.isEmpty) {
        return <String, dynamic>{};
      }

      final decoded = jsonDecode(trimmed);
      if (decoded is Map) {
        return Map<String, dynamic>.from(decoded);
      }

      return <String, dynamic>{};
    } catch (_) {
      return <String, dynamic>{'message': body.trim()};
    }
  }

  String _extractMessage(String body, Map<String, dynamic> payload, {required String fallback}) {
    final payloadMessage = payload['message']?.toString().trim();
    if (payloadMessage != null && payloadMessage.isNotEmpty) {
      return payloadMessage;
    }

    final rawBody = body.trim();
    if (rawBody.isNotEmpty) {
      return rawBody;
    }

    return fallback;
  }

  String _normalizeMessage(String message) {
    final trimmed = message.trim();
    if (trimmed.isEmpty) {
      return 'Login gagal.';
    }

    final normalized = trimmed.toLowerCase().replaceAll(RegExp(r'\s+'), ' ');
    if (normalized.contains('secret is not set')) {
      return 'Server login belum dikonfigurasi. Hubungi admin.';
    }

    if (normalized.contains('jwt secret is not set')) {
      return 'Server login belum dikonfigurasi. Hubungi admin.';
    }

    return trimmed;
  }
}
