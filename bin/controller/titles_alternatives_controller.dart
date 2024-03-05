import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import '../core/data_utils.dart';
import '../database/database_controller.dart';
import '../entities/mangas_entity.dart';
import '../entities/recommendation_entity.dart';
import '../repositories/mangas_repository.dart';
import '../core/filterByName.dart';

class SearchMangaController {
  List<MangasEntity> _mangaEntity = [];
  final SearchByTitle _search;
  final MangasRepository _mangaRepository;
  late dynamic updatedTitlesToJson;

  SearchMangaController(
    this._search,
    this._mangaRepository,
  );

  Future<dynamic> getTitles(String searchTerm) async {
    Set<String> updatedTitles =
        {}; // Utiliza um Set para armazenar os títulos únicos
    final cache = RecommendationCache();
    final bool containAlternativeT = await cache.verifyTitleCache(
        collectionPath: Utils.collecAlternativeT, toVerify: searchTerm);

    if (containAlternativeT == false) {
      // Se não possuir no cache, realiza a consulta na api
      final _body = {
        'query': _mangaRepository.getTitleQuery(searchTerm: searchTerm)
      };

      final _response = await http.post(
        Utils.urlAnilist,
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
              .add(MangasEntity(romajiTitle, englishTitle, 'nativeTitle', []));

          await _search.filterBySpecificName(
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

  Future<Future> _insertAlternativeT(String title, Set alternativeT) async {
    final cache = RecommendationCache();

    final entity = AlternativeTitleEntity(
      createAt: DateTime.now(),
      title: title,
      alternativeTitle: alternativeT.toList(),
    );
    return cache.insertAlternativeT(entity.toJson(), title, alternativeT);
  }

  Future<dynamic> alternativeTitleEndpoint(Router router) async {
    router.get('/v1/manga/title-alternative', (Request request) async {
      final searchQuery =
          await request.url.queryParameters['title']!.toLowerCase();

      await getTitles(searchQuery.toString());
      final List updatedTitlesJson = jsonDecode(updatedTitlesToJson);

      try {
        await _insertAlternativeT(searchQuery, Set.from(updatedTitlesJson));
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
    });
  }
}