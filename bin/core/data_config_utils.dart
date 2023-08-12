class DataConfigUtils {
  static final Map<String, String> headers = const {'Content-Type': 'application/json'};

  static final Uri urlAnilist = Uri.parse("https://graphql.anilist.co");

  static final Uri urlBannersApi =
      Uri.parse('https://monolito.lucas-cm.com.br/v1/recommendations/list');

  static final String collectionDB = "recommendation_cache";

  static final String urlMongoDB =
      "mongodb+srv://skynoshine:YuXn7nDIYkAOdNjA@cluster0.ajm09w1.mongodb.net/recommendation_cache";
}
