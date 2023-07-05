import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import '../core/http_headers.dart';
import '../entities/character_entity.dart';
import '../repositories/character_repository.dart';

class CharacterControllerApi {
  final _requestApi = HttpRequestApi(); // Instância da classe HttpRequestApi
  final Uri url = Uri.parse("https://graphql.anilist.co");

  // Função para lidar com erros
  Response _handleError(dynamic e) {
    final errorMessage = 'Erro na solicitação: $e';
    final responseBody = jsonEncode({'error': errorMessage});
    return Response.internalServerError(
      body: responseBody,
      headers: {'Content-Type': 'application/json'},
    );
  }

  Future<void> characterEndpoint(Router router) async {
    router.get('/character', (Request request) async {
      final query = request.url.queryParameters;
      final repository = CharacterRepository();

      final response = await http.post(
        url,
        headers: _requestApi.headers,
        body: json.encode(
          {
            'query': repository.getQuery(name: query['name'] ?? ''),
          },
        ),
      );
      final body = json.decode(response.body);

      if (body['errors'] != null) {
        return Response.ok(response.body);
      }

      final models = CharacterEntity.fromJson(body);
      print(models.name);

      print(response.body);
      return Response.ok(response.body);
    });
    router.get('/character/icon', (Request request) async {
      try {
        return Response.ok('ok');
      } catch (e) {
        return _handleError(e);
      }
    });
  }
}
