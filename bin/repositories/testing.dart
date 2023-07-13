import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_router/shelf_router.dart';

class SearchMangaData {
  final String _apiUrl = 'https://graphql.anilist.co';
  late dynamic updatedTitlesJson;

  Future<void> searchManga(String searchTerm) async {
    final String query = '''
      query {
        Page {
          media(search: "$searchTerm", type: MANGA) {
            id
            title {
              romaji
              english
              native
            }
            synonyms
          }
        }
      }
    ''';

    final headers = {'Content-Type': 'application/json'};
    final body = {'query': query};

    final response = await http.post(Uri.parse(_apiUrl),
        headers: headers, body: jsonEncode(body));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final mangaDataList = data['data']['Page']['media'] as List<dynamic>;

      final Set<String> updatedTitles =
          {}; // Utiliza um Set para armazenar os títulos únicos

      for (var manga in mangaDataList) {
        final title = manga['title'];
        var romajiTitle = title['romaji'] ?? 'N/A';
        var englishTitle = title['english'] ?? 'N/A';
        print(englishTitle);

        if (romajiTitle == searchTerm || englishTitle == searchTerm) {
          if (!_containsIgnoredKeywords(romajiTitle) &&
              !_containsIgnoredKeywords(englishTitle)) {
            romajiTitle = romajiTitle.toString().toLowerCase();
            englishTitle = englishTitle.toString().toLowerCase();

            if (!updatedTitles.contains(romajiTitle)) {
              updatedTitles.add(romajiTitle);
            }
            if (!updatedTitles.contains(englishTitle)) {
              updatedTitles.add(englishTitle);
            }
          }
        }
      }

      updatedTitlesJson = jsonEncode(updatedTitles
          .toList()); // Converte o Set para uma lista antes de fazer o encode em JSON
    } else {
      print('Error: ${response.statusCode}, ${response.body}');
    }
  }

  bool _containsIgnoredKeywords(String title) {
    final ignoredKeywords = [
      'Special One-Shot',
      'Special Chapter',
      ':'
    ]; // Palavras-chave a serem ignoradas

    for (var keyword in ignoredKeywords) {
      if (title.contains(keyword)) {
        return true;
      }
    }

    return false;
  }
}

void main() async {
  final searchMangaData = SearchMangaData();
  await searchMangaData.searchManga('One Punch');
  print(searchMangaData.updatedTitlesJson);

  //final app = Router();

  //app.get('/v1/manga/title-alternative', (Request request) {
    //return Response.ok(searchMangaData.updatedTitlesJson,
    //    headers: {'Content-Type': 'application/json'});
  //});

  //Future<Response> _handleRequest(Request request) async {
    //return app(request);
  //}

  //final handler =
    //const Pipeline().addMiddleware(logRequests()).addHandler(_handleRequest);

  //final server = await shelf_io.serve(handler, 'localhost', 8080);
  //print('Servidor rodando em ${server.address.host}:${server.port}');
}