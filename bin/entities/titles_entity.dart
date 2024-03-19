class TitlesObject {
  final String romajiTitle;
  final String englishTitle;
  final String nativeTitle;
  final List<dynamic> titles;

  TitlesObject(
    this.romajiTitle,
    this.englishTitle,
    this.nativeTitle,
    this.titles,
  );
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

