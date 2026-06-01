class NewsModel {
  final String title;
  final String description;
  final String url;
  final String source;

  NewsModel({
    required this.title,
    required this.description,
    required this.url,
    required this.source,
  });

  factory NewsModel.fromJson(Map<String, dynamic> json) {
    return NewsModel(
      title: json['title']?.toString() ?? 'Sem título',
      description: json['description']?.toString() ?? 'Sem descrição',
      url: json['url']?.toString() ?? '',
      source: json['source']?['name']?.toString() ?? 'Fonte desconhecida',
    );
  }
}
