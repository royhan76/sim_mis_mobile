import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../auth/data/services/auth_api_service.dart';
import '../models/article_models.dart';

class ArticleApiService {
  ArticleApiService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;
  static const String _baseUrl = 'https://ppmissarang.com/wp-json/wp/v2';

  Future<List<ArticleItem>> fetchLatestArticles({int limit = 5}) async {
    final payload = await _getJson('posts?per_page=$limit&_embed=1&status=publish');
    if (payload is List) {
      return payload
          .map((item) => ArticleItem.fromJson(_mapWordPressPost(Map<String, dynamic>.from(item as Map))))
          .toList();
    }

    throw ApiException('Gagal memuat artikel.');
  }

  Future<ArticleItem> fetchArticleDetail(int id) async {
    final payload = await _getJson('posts/$id?_embed=1');
    if (payload is Map) {
      return ArticleItem.fromJson(_mapWordPressPost(Map<String, dynamic>.from(payload)));
    }

    throw ApiException('Gagal memuat detail artikel.');
  }

  Future<dynamic> _getJson(String path) async {
    late final http.Response response;
    try {
      response = await _client
          .get(
            Uri.parse('$_baseUrl/$path'),
            headers: const {
              'Accept': 'application/json',
            },
          )
          .timeout(const Duration(seconds: 15));
    } on TimeoutException {
      throw ApiException('Koneksi ke server timeout. Cek jaringan internet di device.');
    }

    try {
      final body = response.body.trim();
      if (body.isEmpty) {
        return <dynamic>[];
      }

      return jsonDecode(body);
    } catch (_) {
      throw ApiException('Response API tidak valid.');
    }
  }

  Map<String, dynamic> _mapWordPressPost(Map<String, dynamic> json) {
    final title = _stripHtml('${json['title']?['rendered'] ?? '-'}');
    final excerpt = _stripHtml('${json['excerpt']?['rendered'] ?? ''}');
    final content = _stripHtml('${json['content']?['rendered'] ?? ''}');
    final imageUrl = _resolveImageUrl(json);

    return <String, dynamic>{
      'id': json['id'],
      'title': title,
      'excerpt': excerpt,
      'content': content,
      'date': _formatDate('${json['date'] ?? ''}'),
      'link': '${json['link'] ?? ''}',
      'image_url': imageUrl,
      'slug': '${json['slug'] ?? ''}',
    };
  }

  String _resolveImageUrl(Map<String, dynamic> json) {
    final embedded = json['_embedded'];
    if (embedded is Map) {
      final media = embedded['wp:featuredmedia'];
      if (media is List && media.isNotEmpty) {
        final first = media.first;
        if (first is Map) {
          final source = first['source_url'];
          if (source is String && source.trim().isNotEmpty) {
            return source;
          }
        }
      }
    }
    return '';
  }

  String _stripHtml(String value) {
    final stripped = value.replaceAll(RegExp(r'<[^>]*>'), ' ');
    return stripped
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&quot;', '"')
        .replaceAll('&#039;', "'")
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  String _formatDate(String value) {
    if (value.trim().isEmpty) {
      return '-';
    }

    try {
      final date = DateTime.parse(value).toLocal();
      final months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
        'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
      ];
      return '${date.day.toString().padLeft(2, '0')} ${months[date.month - 1]} ${date.year}';
    } catch (_) {
      return '-';
    }
  }
}
