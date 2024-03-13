class ImagesRepository {
  String getImages({required String searchTerm}) {
    return '''
        query {
      Media(search: "$searchTerm", type: MANGA) {
        title {
          romaji
        }
        bannerImage
        coverImage {
          large
        }
      }
    }
    ''';
  }
}
