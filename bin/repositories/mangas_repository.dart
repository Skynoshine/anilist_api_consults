class MangasRepository {
  String getTitleQuery({required String searchTerm}) {
    return '''
      query {
        Page {
          media(search: "$searchTerm", type: MANGA) {
            id
            title {
              romaji
              english
              native
            }
            synonyms
          }
        }
      }
    ''';
  }
}
