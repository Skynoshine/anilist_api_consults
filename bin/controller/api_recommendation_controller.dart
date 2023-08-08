import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import '../repositories/recommendation_repository.dart';
import '../core/data_config_utils.dart';

class ApiRecommendation {
  final DataConfigUtils _utilities = DataConfigUtils();

  final List<String> _titlesAnilist = [];
  final Set<String> recommendation = {};
  final Set<dynamic> titleResponseApi = {};

  // Obtém recomendações da API AniList
  Future<void> _getRecommendationsAnilist(String title) async {
    final _recommendationRepository = RecommendationRepository();
    final body = {'query': _recommendationRepository.getQuery(title: title)};

    final _response = await http.post(
      _utilities.urlAnilist,
      headers: _utilities.headers,
      body: jsonEncode(body),
    );

    if (_response.statusCode == 200) {
      final data = jsonDecode(_response.body);
      final nodes = data['data']['Media']['recommendations']['nodes'];

      for (var node in nodes) {
        final titleObject = node['mediaRecommendation']['title'];
        final titleEnglish = titleObject?['english'];
        final titleRomaji = titleObject?['romaji'];

        if (titleEnglish != null) _titlesAnilist.add(titleEnglish);
        if (titleRomaji != null) _titlesAnilist.add(titleRomaji);
      }
    } else {
      print('Falha na requisição: ${_response.statusCode}');
    }
  }

  // Obtém títulos dos banners da API
  Future<List<String>> _getTitlesFromBanners() async {
    print('loading getTitlesFromBanners()');

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

  // Compara títulos e encontra os em comum
  Future<Set<String>> _compareListsTitles(List<String> titlesBanners) async {
    final Set<String> titlesInCommon = {};

    final setTitlesAnilist =
        _titlesAnilist.map((title) => title.toLowerCase().trim()).toSet();
    final setTitlesBanners =
        titlesBanners.map((title) => title.toLowerCase().trim()).toSet();

    titlesInCommon.addAll(setTitlesAnilist.intersection(setTitlesBanners));

    recommendation
        .add(titlesInCommon.isNotEmpty ? titlesInCommon.toString() : 'n/a');

    return titlesInCommon;
  }

  // Obtém respostas dos títulos dos banners
  Future<void> _getBannerTitleResponse(List<dynamic> items) async {
    try {
      for (var element in recommendation.toList()) {
        final index = items.indexWhere(
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
  }

  Future<void> running(String titleForSearch) async {
    await _getRecommendationsAnilist(titleForSearch);

    final titlesBanners = await _getTitlesFromBanners();

    await _compareListsTitles(titlesBanners);

    await _getBannerTitleResponse(titlesBanners);
  }

  // Configura o router para lidar com as solicitações
  Future<void> setRouter(Router router) async {
    router.get('/v1/manga/recommendations', (Request request) async {
      final title = request.url.queryParameters['title'];
      await running(title!);
      return Response.ok(
        json.encode({"data": titleResponseApi.toList()}),
        headers: _utilities.headers,
      );
    });
  }
}
