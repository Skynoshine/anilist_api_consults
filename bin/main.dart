import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_router/shelf_router.dart';

import 'controller/recommendation_controller.dart';
import 'controller/mangas_controller.dart';
import 'core/filterByName.dart';
import 'repositories/mangas_repository.dart';

void main() async {
  final app = Router();

  final _searchMangaController =
      SearchMangaController(SearchByTitle(), MangasRepository());

  final _recommendationsController = RecommendationController();

  Future<Response> _handleRequest(Request request) async {
    return app(request);
  }

  final handler =
      const Pipeline().addMiddleware(logRequests()).addHandler(_handleRequest);

  final server = await shelf_io.serve(handler, 'localhost', 8080);

  //http://localhost:8080/v1/manga/title-alternative
  await _searchMangaController.searchTitleAlternativeEndpoint(app);

  //http://localhost:8080/v1/manga/recommendations?title=youjo senki
  _recommendationsController.router(app);

  print('Servidor rodando em ${server.address.host}:${server.port}');
}
