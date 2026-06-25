import '../models/article_models.dart';
import '../services/article_api_service.dart';

class ArticleRepository {
  ArticleRepository({ArticleApiService? apiService}) : _apiService = apiService ?? ArticleApiService();

  final ArticleApiService _apiService;

  Future<List<ArticleItem>> loadLatestArticles({int limit = 5}) {
    return _apiService.fetchLatestArticles(limit: limit);
  }

  Future<ArticleItem> loadArticleDetail(int id) {
    return _apiService.fetchArticleDetail(id);
  }
}
