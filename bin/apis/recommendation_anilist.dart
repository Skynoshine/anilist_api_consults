import '../repositories/recommendation_repository.dart';
import '../core/data_config_utils.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';

class RecommendationAnilistApi {
  static Future<List<String>> getRecommendationAnilist(
      String titleForSearch) async {
    print("running $getRecommendationAnilist");

    final body = {
      'query': RecommendationRepository.getQuery(title: titleForSearch)
    };

    final List<String> _titlesAnilist = [];

    final response = await http.post(
      DataConfigUtils.urlAnilist,
      headers: DataConfigUtils.headers,
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
      print('Falha na requisição: ${response.statusCode}');
    }
    return _titlesAnilist;
  }
}
