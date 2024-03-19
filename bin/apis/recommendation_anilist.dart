import '../querys/recommendation_query.dart';
import '../core/utils.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';

class RecommendationAnilistApi {
  static Future<List<String>> getRecommendationAnilist(
      String titleForSearch) async {

    final body = {
      'query': await RecommendationQuery()
          .getRecommendationQuery(title: titleForSearch)
    };

    final List<String> _titlesAnilist = [];

    final response = await http.post(
      Utils.anilistUri,
      headers: Utils.headers,
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final nodes = data['data']['Media']['recommendations']['nodes'];

      //Pegar os títulos do Anilist
      for (var node in nodes) {
        final titleObject = node['mediaRecommendation']['title'];
        final titleEnglish = titleObject?['english'];
        final titleRomaji = titleObject?['romaji'];

        if (titleEnglish != null) _titlesAnilist.add(titleEnglish);
        if (titleRomaji != null) _titlesAnilist.add(titleRomaji);
      }
    } else {
      Utils.requestlog(
        name: 'GetRecommendationAnilist',
        title: titleForSearch,
        path: Utils.anilistUri.toString(),
        header: Utils.headers,
        responseCode: response.statusCode,
        responseBody: response.body,
      );
    }
    return _titlesAnilist;
  }
}
