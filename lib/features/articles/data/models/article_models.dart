class ArticleItem {
  ArticleItem({
    required this.id,
    required this.title,
    required this.excerpt,
    required this.content,
    required this.date,
    required this.link,
    required this.imageUrl,
    required this.slug,
  });

  final int id;
  final String title;
  final String excerpt;
  final String content;
  final String date;
  final String link;
  final String imageUrl;
  final String slug;

  factory ArticleItem.fromJson(Map<String, dynamic> json) {
    return ArticleItem(
      id: json['id'] is int ? json['id'] as int : int.tryParse('${json['id']}') ?? 0,
      title: '${json['title'] ?? '-'}',
      excerpt: '${json['excerpt'] ?? ''}',
      content: '${json['content'] ?? ''}',
      date: '${json['date'] ?? '-'}',
      link: '${json['link'] ?? ''}',
      imageUrl: '${json['image_url'] ?? ''}',
      slug: '${json['slug'] ?? ''}',
    );
  }
}
