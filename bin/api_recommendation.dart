import 'dart:convert';
import 'package:http/http.dart' as http;

import '../bin/repositories/recommendation_repository.dart';
import 'core/http_headers.dart';

class ApiRecommendation {
  final HttpRequestApi _requestApi;

  List<String> _titlesBanners = [];
  List<String> _titlesAnilist = [];
  Set<String> recommendation = {};
  Set<String> _titlesInCommon = {};

  ApiRecommendation(
    this._requestApi,
  );

  Future<Object> _fetchTitlesFromBanners(bool showTitles) async {
    final response = await http.get(_requestApi.urlRecommendations);

    if (response.statusCode == 200) {
      final decodedData = json.decode(response.body) as Map<String, dynamic>;
    
      final List<dynamic> items = decodedData['data'] as List<dynamic>;
      _titlesBanners = items.map((item) => item['title'].toString()).toList();

      if (showTitles) {
        print('\nbanners titles:${_titlesBanners.toString().toLowerCase()}');
      }
      return _titlesBanners;
    } else {
      print('Falha na requisição: ${response.statusCode}');
      return [];
    }
  }

  Future<dynamic> _compareListsTitles() async {
    Set<String> setTitlesAnilist =
        _titlesAnilist.map((title) => title.toLowerCase().trim()).toSet();
    Set<String> setTitlesBanners =
        _titlesBanners.map((title) => title.toLowerCase().trim()).toSet();

    _titlesInCommon = setTitlesAnilist.intersection(setTitlesBanners);

    if (_titlesInCommon.isNotEmpty) {
      recommendation.add(_titlesInCommon.toString());
      print('\ntitlesInCommon: $_titlesInCommon');
    } else {
     recommendation.add('n/a'); 
    }
  }

  Future<dynamic> _fetchRecommendationsAnilist(String title) async {
    final _recommendationRepository = RecommendationRepository();

    final body = {'query': _recommendationRepository.getQuery(title: title)};

    final _response = await http.post(
      _requestApi.urlGraphql,
      headers: _requestApi.headers,
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
      print('\ntitles anilist:${_titlesAnilist.toString().toLowerCase()}');

      // Chama fetchTitlesFromApi para preencher _titlesBanners
      await _fetchTitlesFromBanners(true);
      // Comparar os títulos para ver se tem algum em comum
      await _compareListsTitles();

      return _titlesAnilist.toString().toLowerCase();
    } else {
      print('Falha na requisição: ${_response.statusCode}');
    }
  }
}

void main() async {
  final apiRecommendation = ApiRecommendation(HttpRequestApi());
  // Aguarda recommendations para preencher _titlesAnilist
  await apiRecommendation._fetchRecommendationsAnilist("made in abyss");
}
