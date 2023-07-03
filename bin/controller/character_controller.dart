import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import '../repositories/character_repository.dart';

class CharacterControllerApi {
  late dynamic response;

  final _requestApi = HttpRequestApi(); // Instância da classe HttpRequestApi
  final Uri url = Uri.parse("https://graphql.anilist.co");

  final repository = CharacterRepository();

  // Função para lidar com erros
  Response _handleError(dynamic e) {
    final errorMessage = 'Erro na solicitação: $e';
    final responseBody = jsonEncode({'error': errorMessage});
    return Response.internalServerError(
      body: responseBody,
      headers: {'Content-Type': 'application/json'},
    );
  }

  Future<CharacterModelos> characterEndpoint(Router router) async {
    _requestApi.body = await json.encode({'query': repository.query});
    response = await http.post(
      url,
      headers: _requestApi.headers,
      body: _requestApi.body,
    );

    router.get('/character', (Request request) async {
      if (response.statusCode == 200) {
        final models = CharacterModelos();
        print(models.name);

        print(response.body);
        return Response.ok(response.body);
      } else {
        print(response.body);
        return Response.badRequest();
      }
    });
    router.get('/character/icon', (Request request) async {
      if (response.statusCode == 200) {
        print(_requestApi.body);
        try {
          return Response.ok('ok');
        } catch (e) {
          return _handleError(e);
        }
      }
    });
    ;
    return CharacterModelos();
  }
}
