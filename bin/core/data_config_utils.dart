import 'dart:developer';

class DataConfigUtils {
  static final Map<String, String> headers = const {
    'Content-Type': 'application/json'
  };

  static final Uri urlAnilist = Uri.parse("https://graphql.anilist.co");

  static final Uri urlBannersApi =
      Uri.parse('https://monolito.lucas-cm.com.br/v1/recommendations/list');

  static final String collectionDB = "recommendation_cache";

  static final String urlMongoDB =
      "mongodb+srv://skynoshine:YuXn7nDIYkAOdNjA@cluster0.ajm09w1.mongodb.net/recommendation_cache";
  static void requestlog({
    Map<String, dynamic>? header,
    Map<String, dynamic>? body,
    dynamic responseBody,
    dynamic responseCode,
    required String path,
    String? name,
  }) {
    final now = DateTime.now();
    final formattedDateTime = '${now.day}/${now.month}/${now.year}'
        ' ${now.hour}:${now.minute}:${now.second}';

    final message = '''
    ---------------- LOG ----------------
    --- Request Data e Hora: $formattedDateTime ---
    --- Request Header: $header ---
    --- Request Path: $path ---
    --- Request Body: $body ---
    --- Response Body: $responseBody ---
    --- Response Code: $responseCode ---
    ---------------- FIM ----------------
    ''';

    log(message, name: name ?? '');
  }
}
