class MangasRepository {
  String getTitleQuery({required String searchTerm}) {
    return '''
      query {
        Page {
          media(search: "$searchTerm") {
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
