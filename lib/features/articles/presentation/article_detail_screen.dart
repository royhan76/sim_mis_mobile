import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../auth/data/services/auth_api_service.dart';
import '../../../shared/widgets/app_skeleton.dart';
import '../data/models/article_models.dart';
import '../data/repositories/article_repository.dart';

class ArticleDetailScreen extends StatefulWidget {
  const ArticleDetailScreen({
    super.key,
    required this.articleId,
    required this.repository,
  });

  final int articleId;
  final ArticleRepository repository;

  @override
  State<ArticleDetailScreen> createState() => _ArticleDetailScreenState();
}

class _ArticleDetailScreenState extends State<ArticleDetailScreen> {
  late Future<ArticleItem> _future = _load();

  Future<ArticleItem> _load() => widget.repository.loadArticleDetail(widget.articleId);

  Future<void> _reload() async {
    setState(() {
      _future = _load();
    });
    await _future;
  }

  Future<void> _copyLink(String link) async {
    if (link.trim().isEmpty) {
      return;
    }

    await Clipboard.setData(ClipboardData(text: link));
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Link artikel disalin.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      body: SafeArea(
        child: FutureBuilder<ArticleItem>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const AppArticleDetailSkeleton();
            }

            if (snapshot.hasError) {
              final message = snapshot.error is ApiException
                  ? (snapshot.error as ApiException).message
                  : 'Gagal memuat detail artikel.';
              return _ErrorState(message: message, onRetry: _reload);
            }

            final article = snapshot.data!;
            return RefreshIndicator(
              onRefresh: _reload,
              color: const Color(0xFF0F8B8D),
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(18, 14, 18, 24),
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.arrow_back_rounded),
                      ),
                      const SizedBox(width: 6),
                      const Text(
                        'Artikel Pondok',
                        style: TextStyle(
                          color: Color(0xFF17304D),
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF172B4D).withValues(alpha: 0.05),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                          child: AspectRatio(
                            aspectRatio: 16 / 9,
                            child: _ArticleImage(url: article.imageUrl),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(18),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _DatePill(label: article.date),
                              const SizedBox(height: 12),
                              Text(
                                article.title,
                                style: const TextStyle(
                                  color: Color(0xFF17304D),
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                  height: 1.25,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                article.excerpt.isNotEmpty ? article.excerpt : '-',
                                style: const TextStyle(
                                  color: Color(0xFF4B5C74),
                                  fontSize: 13,
                                  height: 1.6,
                                ),
                              ),
                              const SizedBox(height: 18),
                              const Text(
                                'Isi Artikel',
                                style: TextStyle(
                                  color: Color(0xFF17304D),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                article.content.isNotEmpty ? article.content : '-',
                                style: const TextStyle(
                                  color: Color(0xFF4B5C74),
                                  fontSize: 13,
                                  height: 1.7,
                                ),
                              ),
                              const SizedBox(height: 18),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF1F5F9),
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Link Sumber',
                                      style: TextStyle(
                                        color: Color(0xFF17304D),
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      article.link,
                                      style: const TextStyle(
                                        color: Color(0xFF4B5C74),
                                        fontSize: 12,
                                        height: 1.5,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: TextButton.icon(
                                        onPressed: () => _copyLink(article.link),
                                        icon: const Icon(Icons.copy_rounded, size: 18),
                                        label: const Text('Salin Link'),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
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
            child: Icon(Icons.image_rounded, color: Color(0xFF94A3B8), size: 40),
          ),
        );
      },
    );
  }
}

class _DatePill extends StatelessWidget {
  const _DatePill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF0F8B8D).withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Color(0xFF0F8B8D),
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.warning_amber_rounded, size: 56, color: Color(0xFFE11D48)),
            const SizedBox(height: 12),
            const Text(
              'Artikel belum bisa dimuat',
              style: TextStyle(
                color: Color(0xFF17304D),
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF6B7A90),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 18),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }
}

