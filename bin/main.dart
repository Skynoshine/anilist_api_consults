import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_router/shelf_router.dart';

import 'controller/character_controller.dart';

void main() async {
  final app = Router();

  final _characterController = CharacterControllerApi();

  _characterController.characterEndpoint(app);

  // Função para lidar com a requisição HTTP
  Future<Response> _handleRequest(Request request) async {
    return app(request);
  }

  // Configuração do servidor Shelf
  final handler =
      const Pipeline().addMiddleware(logRequests()).addHandler(_handleRequest);

  final server = await shelf_io.serve(handler, 'localhost', 8080);
  print('Servidor rodando em ${server.address.host}:${server.port}');
}
