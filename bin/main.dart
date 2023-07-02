import 'dart:convert';

import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_router/shelf_router.dart';

import 'controller/character_controller.dart';

void main() async {
  final characterController = CharacterControllerApi();
  await characterController.sendCharacterPostRequest();

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
      'name': characterController.name,
      'id': characterController.id,
      'gender': characterController.gender,
      'age': characterController.age,
      'description': characterController.descriptionChar,
    };

    final responseBody = jsonEncode(responseMap);
    return Response.ok(responseBody, headers: {
      'Content-Type': 'application/json',
    });
  });

  // Endpoint "/character/icon" para obter a imagem do personagem
  router.get('/character/icon', (Request request) {
    try {
      return Response.ok(characterController.iconImage,
          headers: {'Content-Type': 'image/jpeg'});
    } catch (e) {
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
