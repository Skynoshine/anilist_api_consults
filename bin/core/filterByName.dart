class SearchByTitle {
  bool _containsIgnoredKeywords(String title) {
    final ignoredKeywords = [
      'Special One-Shot',
      'Special Chapter',
      ':'
    ]; // Palavras-chave a serem ignoradas

    for (var keyword in ignoredKeywords) {
      if (title.contains(keyword)) {
        return true;
      }
    }
    return false;
  }

  Future<void> filterBySpecificName(
    String titleParam,
    Set<String> updatedTitles,
    String englishTitle,
    String romajiTitle,
  ) async {
    if (englishTitle == titleParam || romajiTitle == titleParam) {
      if (!_containsIgnoredKeywords(englishTitle) &&
          !_containsIgnoredKeywords(romajiTitle)) {
        englishTitle = englishTitle.toString().toLowerCase();
        romajiTitle = romajiTitle.toString().toLowerCase();

        if (!updatedTitles.contains(englishTitle)) {
          updatedTitles.add(englishTitle);
        }
        if (!updatedTitles.contains(romajiTitle)) {
          updatedTitles.add(romajiTitle);
        }
      } // Verificar se possui palavras bloqueadas
    }
  }

  Future<Set<String>> filterByAbrangeName(
    String title,
    Set<String> updatedTitles,
    String englishTitle,
    String romajiTitle,
  ) async {
    if (englishTitle.contains(title) || romajiTitle.contains(title)) {
      if (!_containsIgnoredKeywords(englishTitle) &&
          !_containsIgnoredKeywords(romajiTitle)) {
        englishTitle = englishTitle.toString().toLowerCase();
        romajiTitle = romajiTitle.toString().toLowerCase();

        if (!updatedTitles.contains(romajiTitle)) {
          updatedTitles.add(romajiTitle);
        }
        if (!updatedTitles.contains(englishTitle)) {
          updatedTitles.add(englishTitle);
        }
      }
    }

    return updatedTitles;
  }
}
