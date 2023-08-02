class RecommendationEntity {
  final DateTime createAt;
  final List<String> title;
  final List<dynamic> recommendation;

  RecommendationEntity({
    required this.createAt,
    required this.title,
    required this.recommendation,
  });

  Map<String, dynamic> toJson() {
    return {
      'createAt': createAt,
      'title': title,
      'recommendation': recommendation,
    };
  }
}