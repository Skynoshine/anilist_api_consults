import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import '../core/data_utils.dart';
import '../entities/mangas_entity.dart';
import '../repositories/mangas_repository.dart';

import '../core/filterByName.dart';

class SearchMangaController {
  List<MangasEntity> _mangaEntity = [];
  final SearchByTitle _search;
  final MangasRepository _mangaRepository;

  late dynamic updatedTitlesJson;

  SearchMangaController(
    this._search,
    this._mangaRepository,
  );

  Future<dynamic> searchManga(String searchTerm) async {
    final body = {
      'query': _mangaRepository.getTitleQuery(searchTerm: searchTerm)
    };

    final response = await http.post(
      Utils.urlAnilist,
      headers: Utils.headers,
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      Set<String> updatedTitles =
          {}; // Utiliza um Set para armazenar os títulos únicos

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
      updatedTitlesJson = jsonEncode(updatedTitles.toList());

      print(updatedTitlesJson);
    } else {
      print('Error: ${response.statusCode}, ${response.body}');
    }
  }

  Future<dynamic> searchTitleAlternativeEndpoint(Router router) async {
    await searchManga('attack on titan');

    router.get('/v1/manga/title-alternative/', (Request request) async {
      return Response.ok(
        await updatedTitlesJson,
        headers: Utils.headers,
      );
    });
  }
}
