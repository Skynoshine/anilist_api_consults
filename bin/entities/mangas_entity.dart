class MangasEntity {
  final String romajiTitle;
  final String englishTitle;
  final String nativeTitle;
  final List<dynamic> titles;

  MangasEntity(
    this.romajiTitle,
    this.englishTitle,
    this.nativeTitle,
    this.titles,
  );

  factory MangasEntity.fromJson(Map<String, dynamic> json) {
    final titlesList = json['data']['Page']['media'];
    final romajiTitle = titlesList['title']['romaji'] ?? 'N/A';
    final englishTitle = titlesList['title']['english'] ?? 'N/A';
    final nativeTitle = titlesList['title']['native'] ?? 'N/A';

    return MangasEntity(
      romajiTitle,
      englishTitle,
      nativeTitle,
      titlesList,
    );
  }
}
