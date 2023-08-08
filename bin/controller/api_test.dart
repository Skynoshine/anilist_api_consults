import 'dart:convert';

import 'package:http/http.dart' as http;

import '../core/data_config_utils.dart';
import '../repositories/recommendation_repository.dart';

class ApiRecommendation {
  final DataConfigUtils _utilities = DataConfigUtils();

  //obter recomendação do Anilist
  Future<List<String>> _getRecommendationAnilist(String titleForSearch) async {
    print("running $_getRecommendationAnilist");

    final recommendationRepository = RecommendationRepository();
    final body = {
      'query': recommendationRepository.getQuery(title: titleForSearch)
    };

    final List<String> _titlesAnilist = [];

    final response = await http.post(
      _utilities.urlAnilist,
      headers: _utilities.headers,
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

  // Obtém títulos dos banners da API
  Future<List<String>> _getTitlesFromBanners() async {
    print('running $_getTitlesFromBanners');

    final List<String> titlesBanners = [];

    final response = await http.get(_utilities.urlBannersApi);

    if (response.statusCode == 200) {
      final decodedData = json.decode(response.body) as Map<String, dynamic>;
      final items = decodedData['data'] as List<dynamic>;

      titlesBanners.addAll(items.map((item) => item['title'].toString()));
    } else {
      print('Falha na requisição: ${response.statusCode}');
    }
    return titlesBanners;
  }

  // Compara títulos e encontra os em comum e retorna titulo em comum e recomendaçao
  Future<Set<String>> _compareListsTitles(
      List<String> titlesBanners, List<String> _titlesAnilist) async {
    final Set<String> recommendation = {};
    final Set<String> titlesInCommon = {};

    print('running $_compareListsTitles');

    final setTitlesAnilist =
        _titlesAnilist.map((title) => title.toLowerCase().trim()).toSet();
    final setTitlesBanners =
        titlesBanners.map((title) => title.toLowerCase().trim()).toSet();

    titlesInCommon.addAll(setTitlesAnilist.intersection(setTitlesBanners));

    recommendation
        .add(titlesInCommon.isNotEmpty ? titlesInCommon.toString() : 'n/a');

    return recommendation;
  }

// Obtém respostas dos títulos dos banners e retorna o resultado
  Future<Set> _getBannerTitleResponse(
      List<dynamic> items, Set<String> recommendation) async {
    final Set<dynamic> titleResponseApi = {};

    print('running $_getBannerTitleResponse');

    try {
      for (var element in recommendation.toList()) {
        print('Element: $element');
        print('Items: $items');

        final int index = items.indexWhere(
          (e) => e['title'].toString().toLowerCase().contains(element
              .toLowerCase()
              .replaceFirst('{', '')
              .replaceFirst('}', '')),
        );
        if (index != -1) {
          titleResponseApi.add(items[index]);
        }
      }
    } catch (e) {
      print('failed to get bannerTitleResponse: $e');
    }
    return titleResponseApi;
  }
}

void main() async {
  ApiRecommendation recommendation = ApiRecommendation();

  final titlesAnilist =
      await recommendation._getRecommendationAnilist("Youjo Senki");

  final titlesBanners = await recommendation._getTitlesFromBanners();

  final recommendationName =
      await recommendation._compareListsTitles(titlesBanners, titlesAnilist);

  await recommendation._getBannerTitleResponse(
      titlesBanners, recommendationName);
}
