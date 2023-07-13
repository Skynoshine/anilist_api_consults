// ignore_for_file: unused_import

import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_router/shelf_router.dart';

import '../core/http_headers.dart';
import '../entities/mangas_entity.dart';
import '../repositories/mangas_repository.dart';

import 'searching_controller.dart';

class SearchMangaController {
  final _mangaEntity = MangasEntity('', '', '', []);
  final _search = SearchByTitle();
  final _requestApi = HttpRequestApi(); // Instância da classe HttpRequestApi
  final _mangaRepository = MangasRepository();

  late dynamic updatedTitlesJson;

  Future<void> searchManga(String searchTerm) async {
    final _body = {
      'query': _mangaRepository.getTitleQuery(searchTerm: searchTerm)
    };

    final _response = await http.post(
      _requestApi.url,
      headers: _requestApi.headers,
      body: jsonEncode(_body),
    );

    if (_response.statusCode == 200) {
      final data = jsonDecode(_response.body);

      final Set<String> updatedTitles =
          {}; // Utiliza um Set para armazenar os títulos únicos

      final mangaDataList = data['data']['Page']['media'] as List<dynamic>;

      for (var manga in mangaDataList) {
        final title = manga['title'];
        var romajiTitle = title['romaji'] ?? 'N/A';
        var englishTitle = title['english'] ?? 'N/A';

        await _search.searchAbrangeName(
            searchTerm, updatedTitles, englishTitle, romajiTitle);
      }
      updatedTitlesJson = jsonEncode(updatedTitles.toList());
    } else {
      print('Error: ${_response.statusCode}, ${_response.body}');
    }
  }
}

Future<void> main() async {
  final _searchMangaController = SearchMangaController();

  _searchMangaController.searchManga('One Piece');
}
