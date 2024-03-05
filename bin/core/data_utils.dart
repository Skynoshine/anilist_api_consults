import 'dart:developer';

import 'package:dotenv/dotenv.dart' as dotenv;

class Utils {
  static final Map<String, String> headers = const {
    'Content-Type': 'application/json'
  };

  static String getDotenv() {
    var env = dotenv.DotEnv(includePlatformEnvironment: true)..load();
    env.load();
    final urlMongoDB = env['MONGODB_URL'];
    return urlMongoDB!;
  }

  static final Uri urlAnilist = Uri.parse("https://graphql.anilist.co");

  static final Uri urlBannersApi =
      Uri.parse('https://monolito.lucas-cm.com.br/v1/recommendations/list');

  static final String collecRecommendation = "recommendation_cache";
  static final String collecAlternativeT = "alternative_titles_cache";

  static void requestlog({
    Map<String, dynamic>? header,
    Map<String, dynamic>? body,
    dynamic responseBody,
    dynamic responseCode,
    required String path,
    String? name,
    String? title,
    Object? error,
  }) {
    final now = DateTime.now();
    final formattedDateTime = '${now.day}/${now.month}/${now.year}'
        ' ${now.hour}:${now.minute}:${now.second}';

    final message = '''
    ---------------- LOG ----------------
    --- Request Data e Hora: $formattedDateTime ---
    --- Request Header: $header ---
    --- Request Path: $path ---
    --- Title Searched: $title ---
    --- Request Body: $body ---
    --- Response Body: $responseBody ---
    --- Response Code: $responseCode ---
    --- Error: $error ---
    ---------------- FIM ----------------
    ''';

    log(message, name: name ?? '');
  }
}

class DbLogger {
  static void errorLogger({
    Map<String, dynamic>? queryParameters,
    dynamic responseBody,
    dynamic responseCode,
    required String? tableName,
    String? operationName,
    Object? error,
  }) {
    final now = DateTime.now();
    final formattedDateTime = '${now.day}/${now.month}/${now.year}'
        ' ${now.hour}:${now.minute}:${now.second}';

    final message = '''
    ---------------- DATABASE ERROR LOG ----------------
    --- Timestamp: $formattedDateTime ---
    --- Table Name: $tableName ---
    --- Operation Name: ${operationName ?? 'N/A'} ---
    --- Query Parameters: $queryParameters ---
    --- Response Body: $responseBody ---
    --- Response Code: $responseCode ---
    --- Error: $error ---
    ---------------- END ----------------
    ''';

    log(message);
  }
}
