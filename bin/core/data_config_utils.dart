class DataConfigUtils {
  Map<String, String> headers = const {'Content-Type': 'application/json'};

  final Uri urlAnilist = Uri.parse("https://graphql.anilist.co");

  final Uri urlBannersApi =
      Uri.parse('https://monolito.lucas-cm.com.br/v1/recommendations/list');

  final String collectionDB = "recommendation_cache";

  final String urlMongoDB =
      "mongodb+srv://skynoshine:YuXn7nDIYkAOdNjA@cluster0.ajm09w1.mongodb.net/recommendation_cache";
}
