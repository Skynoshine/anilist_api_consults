import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_router/shelf_router.dart';

import 'controller/mangas_controller.dart';
import 'controller/filterByName_controller.dart';
import 'core/http_headers.dart';
import 'repositories/mangas_repository.dart';

void main() async {
  final app = Router();

  final _searchMangaController = SearchMangaController(
      SearchByTitle(), HttpRequestApi(), MangasRepository());

  // Função para lidar com a requisição HTTP
  Future<Response> _handleRequest(Request request) async {
    return app(request);
  }

  // Configuração do servidor Shelf
  final handler =
      const Pipeline().addMiddleware(logRequests()).addHandler(_handleRequest);

  final server = await shelf_io.serve(handler, 'localhost', 8080);

  await _searchMangaController.searchTitleAlternativeEndpoint(app);
  //http://localhost:8080/v1/manga/title-alternative
  print('Servidor rodando em ${server.address.host}:${server.port}');
}
