import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import '../repositories/recommendation_repository.dart';
import '../core/data_config_utils.dart';

class ApiRecommendation {
  DataConfigUtils _utilities = DataConfigUtils();

  List<String> titlesBanners = [];
  List<String> _titlesAnilist = [];
  Set<String> recommendation = {};
  Set<String> titlesInCommon = {};
  List<dynamic> _items = [];
  Set<dynamic> titleResponseApi = {};

  Future<String> _getRecommendationsAnilist(
      String title, bool showTitles) async {
    final _recommendationRepository = RecommendationRepository();

    final body = {'query': _recommendationRepository.getQuery(title: title)};

    final _response = await http.post(
      _utilities.urlAnilist,
      headers: _utilities.headers,
      body: jsonEncode(body),
    );

    if (_response.statusCode == 200) {
      final data = jsonDecode(_response.body);
      final List<dynamic> nodes =
          data['data']['Media']['recommendations']['nodes'];

      for (var node in nodes) {
        final titleObject = node['mediaRecommendation']['title'];
        final titleEnglish =
            titleObject != null ? titleObject['english'] : null;
        final titleRomaji = titleObject != null ? titleObject['romaji'] : null;

        if (titleEnglish != null) {
          _titlesAnilist.add(titleEnglish);
        }
        if (titleRomaji != null) {
          _titlesAnilist.add(titleRomaji);
        }
      }
      if (showTitles) {
        print('\ntitles anilist:${_titlesAnilist.toString()}');
      }
    } else {
      print('Falha na requisição: ${_response.statusCode}');
    }
    return _titlesAnilist.toString().toLowerCase();
  }

  Future<List<String>> _getTitlesFromBanners(bool showTitles) async {
    final response = await http.get(_utilities.urlBannersApi);

    if (response.statusCode == 200) {
      final decodedData = json.decode(response.body) as Map<String, dynamic>;

      _items = decodedData['data'] as List<dynamic>;
      titlesBanners = _items.map((item) => item['title'].toString()).toList();

      if (showTitles) {
        print('\nbanners titles:${titlesBanners.toString()}');
      }
    } else {
      print('Falha na requisição: ${response.statusCode}');
    }
    return titlesBanners;
  }

  Future<Set<String>> _compareListsTitles() async {
    Set<String> setTitlesAnilist =
        _titlesAnilist.map((title) => title.toLowerCase().trim()).toSet();
    Set<String> setTitlesBanners =
        titlesBanners.map((title) => title.toLowerCase().trim()).toSet();

    titlesInCommon = setTitlesAnilist.intersection(setTitlesBanners);

    if (titlesInCommon.isNotEmpty) {
      recommendation.add(titlesInCommon.toString());
    } else {
      recommendation.add('n/a');
    }
    return titlesInCommon;
  }

  Future<Set<dynamic>> _getBannerTitleResponse() async {
    try {
      for (var element in recommendation.toList()) {
        final search = _items.toString().toLowerCase();
        Map<String, dynamic> item =
            _items.firstWhere((e) => e['title'].toString().contains(search));
        titleResponseApi.add(item);
      }
    } catch (e) {
      print('failed to get bannerTitleResponse');
    }
    return titleResponseApi;
  }

  Future<dynamic> running(String titleForSearch) async {
    await _getRecommendationsAnilist(titleForSearch, false);
    // Chama fetchTitlesFromApi para preencher _titlesBanners
    await _getTitlesFromBanners(false);
    // Comparar os títulos para ver se tem algum em comum
    await _compareListsTitles();
    //pegar títulos completos
    await _getBannerTitleResponse();
  }

  Future<dynamic> setRouter(Router router) async {
    router.get('/v1/manga/recommendations', (Request request) async {
      final title = request.url.queryParameters['title'];
      await _getRecommendationsAnilist(title!, true);
      return Response.ok(
        json.encode({"data": titleResponseApi.toList()}),
        headers: _utilities.headers,
      );
    });
  }
}
