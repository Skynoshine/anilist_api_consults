import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import '../core/utils.dart';
import '../core/filters.dart';
import '../database/database_controller.dart';
import '../entities/titles_entity.dart';
import '../querys/titles_query.dart';

class SearchMangaController {
  List<TitlesObject> _mangaEntity = [];
  final FilterByTitle _filter;
  final TitlesQuery _mangaRepository;
  late dynamic updatedTitlesToJson;

  SearchMangaController(
    this._filter,
    this._mangaRepository,
  );

  Future<dynamic> getTitles(
      String searchTerm, RecommendationCache cache, bool containCache) async {
    Set<String> updatedTitles =
        {}; // Utiliza um Set para armazenar os títulos únicos

    if (containCache == false) {
      // Se não possuir no cache, realiza a consulta na api
      final _body = {
        'query': _mangaRepository.getTitleQuery(searchTerm: searchTerm)
      };

      final _response = await http.post(
        Utils.anilistUri,
        headers: Utils.headers,
        body: jsonEncode(_body),
      );

      if (_response.statusCode == 200) {
        final data = jsonDecode(_response.body);

        final mangaDataList = data['data']['Page']['media'] as List<dynamic>;

        for (var manga in mangaDataList) {
          final title = manga['title'];
          var romajiTitle = title['romaji'] ?? 'N/A';
          var englishTitle = title['english'] ?? 'N/A';

          _mangaEntity
              .add(TitlesObject(romajiTitle, englishTitle, 'nativeTitle', []));

          await _filter.filterBySpecificName(
            searchTerm.toLowerCase(),
            updatedTitles,
            englishTitle.toString().toLowerCase(),
            romajiTitle.toString().toLowerCase(),
          ); //Filtra a pesquisa
        }
      } else {
        print('Error: ${_response.statusCode}, ${_response.body}');
      }
    }
    return updatedTitlesToJson = jsonEncode(updatedTitles.toList());
  }

  Future<Future> _insertAlternativeT(
      String title, Set alternativeT, RecommendationCache cache) async {
    final entity = AlternativeTitleEntity(
      createAt: DateTime.now(),
      title: title,
      alternativeTitle: alternativeT.toList(),
    );
    return cache.insertAlternativeT(entity.toJson(), title, alternativeT);
  }

  Future<dynamic> alternativeTitleEndpoint(Router router) async {
    router.get('/v1/manga/title-alternative', (Request request) async {
      final cache = RecommendationCache();
      final searchQuery =
          await request.url.queryParameters['title']!.toLowerCase();

      final bool containCache = await cache.verifyTitleCache(
          collectionPath: Utils.collecAlternativeT, toVerify: searchQuery);

      await getTitles(searchQuery.toString(), cache, containCache);
      final List updatedTitlesJson = jsonDecode(updatedTitlesToJson);

      final content =
          await cache.getCacheContent(Utils.collecAlternativeT, searchQuery);

      if (containCache == true) {
        return Response.ok(
          jsonEncode(content),
          headers: Utils.headers,
        );
      } else {
        try {
          await _insertAlternativeT(
              searchQuery, Set.from(updatedTitlesJson), cache);
        } catch (e) {
          Utils.requestlog(
            name: "SearchTitleAlternativeEndpoint",
            path: request.url.toString(),
            title: searchQuery,
            error: e,
          );
        }
        return Response.ok(
          await updatedTitlesToJson,
          headers: Utils.headers,
        );
      }
    });
  }
}
