import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../../core/config/api_config.dart';
import '../../../auth/data/services/auth_api_service.dart';
import '../models/maarif_models.dart';

class MaarifApiService {
  MaarifApiService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<MaarifOverview> fetchOverview(String token, {String? santriId}) async {
    final payload = await _getJson('mobile/santri/maarif', token, santriId: santriId);
    if (payload['success'] == true) {
      return MaarifOverview.fromJson(payload);
    }

    throw ApiException('${payload['message'] ?? 'Gagal memuat data maarif.'}');
  }

  Future<Map<String, dynamic>> _getJson(String path, String token, {String? santriId}) async {
    late final http.Response response;
    try {
      final uri = _buildUri(path, santriId);
      response = await _client
          .get(
            uri,
            headers: {
              'Accept': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(const Duration(seconds: 20));
    } on TimeoutException {
      throw ApiException('Koneksi ke server timeout. Cek IP API dan server Laravel.');
    }

    try {
      final body = response.body.trim();
      if (body.isEmpty) {
        return <String, dynamic>{};
      }

      return Map<String, dynamic>.from(jsonDecode(body) as Map);
    } catch (_) {
      throw ApiException('Response API tidak valid.');
    }
  }

  Uri _buildUri(String path, String? santriId) {
    final uri = Uri.parse(ApiConfig.url(path));
    if (santriId == null || santriId.trim().isEmpty) {
      return uri;
    }

    return uri.replace(
      queryParameters: <String, String>{
        ...uri.queryParameters,
        'santri_id': santriId.trim(),
      },
    );
  }
}
