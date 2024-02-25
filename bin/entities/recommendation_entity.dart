class RecommendationEntity {
  final DateTime createAt;
  final String title;
  final List recommendation;

  RecommendationEntity({
    required this.createAt,
    required this.title,
    required this.recommendation,
  });

  Map<String, dynamic> toJson() {
    return {
      'createAt': createAt.toString(),
      'title': title,
      'recommendation': recommendation,
    };
  }
}

class AlternativeTitleEntity {
  final DateTime createAt;
  final String title;
  final List alternativeTitle;

  AlternativeTitleEntity({
    required this.createAt,
    required this.title,
    required this.alternativeTitle,
  });

  Map<String, dynamic> toJson() {
    return {
      'createAt': createAt.toString(),
      'title': title,
      'alternativeTitle': alternativeTitle,
    };
  }
}
