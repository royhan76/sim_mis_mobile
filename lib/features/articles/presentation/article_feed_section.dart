import 'package:flutter/material.dart';

import '../../auth/data/services/auth_api_service.dart';
import '../../../shared/widgets/app_skeleton.dart';
import '../data/models/article_models.dart';
import '../data/repositories/article_repository.dart';
import 'article_detail_screen.dart';
import 'article_list_screen.dart';

class ArticleFeedSection extends StatefulWidget {
  const ArticleFeedSection({super.key});

  @override
  State<ArticleFeedSection> createState() => _ArticleFeedSectionState();
}

class _ArticleFeedSectionState extends State<ArticleFeedSection> {
  final ArticleRepository _repository = ArticleRepository();
  final PageController _pageController = PageController(viewportFraction: 0.82);
  late Future<List<ArticleItem>> _future = _load();
  int _activePage = 0;

  Future<List<ArticleItem>> _load() => _repository.loadLatestArticles(limit: 5);

  Future<void> _reload() async {
    setState(() {
      _future = _load();
    });
    await _future;
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Artikel Pondok',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: const Color(0xFF17304D),
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => ArticleListScreen(repository: _repository),
                  ),
                );
              },
              child: const Text('Lihat Semua'),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'Informasi dan berita terbaru dari website utama pondok.',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: const Color(0xFF6B7A90)),
        ),
        const SizedBox(height: 12),
        FutureBuilder<List<ArticleItem>>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const AppArticleFeedSkeleton();
            }

            if (snapshot.hasError) {
              final message = snapshot.error is ApiException
                  ? (snapshot.error as ApiException).message
                  : 'Gagal memuat artikel.';
              return _ErrorState(message: message, onRetry: _reload);
            }

            final articles = snapshot.data ?? const <ArticleItem>[];
            if (articles.isEmpty) {
              return const _EmptyState();
            }

            return Column(
              children: [
                SizedBox(
                  height: 228,
                  child: PageView.builder(
                    controller: _pageController,
                    physics: const BouncingScrollPhysics(),
                    itemCount: articles.length,
                    onPageChanged: (index) {
                      if (_activePage == index) {
                        return;
                      }
                      setState(() {
                        _activePage = index;
                      });
                    },
                    itemBuilder: (context, index) {
                      final article = articles[index];
                      return Padding(
                        padding: EdgeInsets.only(
                          right: index == articles.length - 1 ? 0 : 12,
                        ),
                        child: _ArticleCard(
                          article: article,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) => ArticleDetailScreen(
                                  articleId: article.id,
                                  repository: _repository,
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(articles.length.clamp(1, 4).toInt(), (
                    index,
                  ) {
                    final selected =
                        index ==
                        _activePage.clamp(0, articles.length - 1).toInt();
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      width: selected ? 18 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: selected
                            ? const Color(0xFF0F8B8D)
                            : const Color(0xFFD7E0EA),
                        borderRadius: BorderRadius.circular(999),
                      ),
                    );
                  }),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _ArticleCard extends StatelessWidget {
  const _ArticleCard({required this.article, required this.onTap});

  final ArticleItem article;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF172B4D).withValues(alpha: 0.07),
                blurRadius: 22,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 7,
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(24),
                  ),
                  child: _ArticleImage(url: article.imageUrl),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
                child: Text(
                  article.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF17304D),
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    height: 1.22,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ArticleImage extends StatelessWidget {
  const _ArticleImage({required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    final imageUrl = url.trim();
    if (imageUrl.isEmpty) {
      return Container(
        color: const Color(0xFFEFF3F8),
        child: const Center(
          child: Icon(Icons.image_rounded, color: Color(0xFF94A3B8), size: 40),
        ),
      );
    }

    return Image.network(
      imageUrl,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          color: const Color(0xFFEFF3F8),
          child: const Center(
            child: Icon(
              Icons.image_rounded,
              color: Color(0xFF94A3B8),
              size: 40,
            ),
          ),
        );
      },
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.article_rounded, size: 42, color: Color(0xFF0F8B8D)),
          SizedBox(height: 10),
          Text(
            'Belum ada artikel',
            style: TextStyle(
              color: Color(0xFF17304D),
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Artikel dari website pondok akan tampil di sini.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF6B7A90),
              fontSize: 12,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            size: 42,
            color: Color(0xFFE11D48),
          ),
          const SizedBox(height: 10),
          const Text(
            'Artikel belum bisa dimuat',
            style: TextStyle(
              color: Color(0xFF17304D),
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF6B7A90),
              fontSize: 12,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 12),
          TextButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Coba Lagi'),
          ),
        ],
      ),
    );
  }
}
