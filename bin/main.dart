import 'dart:convert';

import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_router/shelf_router.dart';

import 'controller/character_controller.dart';
import 'controller/mangas_controller.dart';

void main() async {
  final _characterController = CharacterControllerApi();
  await _characterController.sendCharacterPostRequest();

  final _mangaController = MangasControllerApi();
  _mangaController.viewMangaRequest();

  final router = Router();

  // Função para lidar com erros
  Response _handleError(dynamic e) {
    final errorMessage = 'Erro na solicitação: $e';
    final responseBody = jsonEncode({'error': errorMessage});
    return Response.internalServerError(
      body: responseBody,
      headers: {'Content-Type': 'application/json'},
    );
  }
  // Endpoint "/character" para obter os dados do personagem
  router.get('/character', (Request request) {
    final responseMap = {
      //'name': _characterController.name,
      //'id': _characterController.id,
      //'gender': _characterController.gender,
      //'age': _characterController.age,
      //'birthday': _characterController.birthday,
      //'description': _characterController.descriptionChar,
      //'titles': _characterController.title,
      'volumes': _mangaController.titleManga,
    };
    final responseBody = jsonEncode(responseMap);
    return Response.ok(responseBody, headers: {
      'Content-Type': 'application/json',
    });
  });

  // Endpoint "/character/icon" para obter a imagem do personagem
  router.get('/character/icon', (Request request) {
    try {
      return Response.ok(_characterController.iconImage,
          headers: {'Content-Type': 'image/jpeg'});
    } catch (e) {
      return _handleError(e);
    }
  });

  router.get('/mangas/list', (Request request){
    try{
      return Response.ok(_mangaController.titleManga,
        headers: {'Content-Type': "application/json"}
      );
    }catch(e){
      return _handleError(e);
    }
  });

  // Função para lidar com a requisição HTTP
  Future<Response> _handleRequest(Request request) async {
    return router(request);
  }

  // Configuração do servidor Shelf
  final handler =
      const Pipeline().addMiddleware(logRequests()).addHandler(_handleRequest);

  final server = await shelf_io.serve(handler, 'localhost', 8080);
  print('Servidor rodando em ${server.address.host}:${server.port}');
}
