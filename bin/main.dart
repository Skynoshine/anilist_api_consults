import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_router/shelf_router.dart';

import 'controller/recommendation_controller.dart';
import 'controller/titles_alternatives_controller.dart';
import 'core/filters.dart';
import 'querys/titles_query.dart';

void main() async {
  final app = Router();

  final _alternativeTitle =
      SearchMangaController(FilterByTitle(), TitlesQuery());

  final _recommendationsController = RecommendationController();

  Future<Response> _handleRequest(Request request) async {
    return app(request);
  }

  final handler =
      const Pipeline().addMiddleware(logRequests()).addHandler(_handleRequest);

  final server = await shelf_io.serve(handler, 'localhost', 8080);

  //http://localhost:8080/v1/manga/title-alternative?title=
  await _alternativeTitle.alternativeTitleEndpoint(app);

  //http://localhost:8080/v1/manga/recommendations?title=youjo senki
  _recommendationsController.recommendationEndpoint(app);

  print('Servidor rodando em ${server.address.host}:${server.port}');
}
