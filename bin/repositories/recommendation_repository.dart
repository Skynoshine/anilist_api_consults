class RecommendationRepository {
  String getRecommendationQuery({required String title}) {
    return '''
    query{
       Media(search: "$title"){
         recommendations{
          nodes{
             mediaRecommendation{
               title{
                 english
                 romaji
          }
        }
      }
    }
  }
}
    ''';
  }
}
