import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import '../apis/banners_titles.dart';
import '../apis/recommendation_anilist.dart';
import '../core/data_config_utils.dart';
import '../entities/recommendation_entity.dart';

class RecommendationController {
  late RecommendationEntity entity;
  // Compara títulos e encontra os em comum e retorna titulo em comum e recomendaçao
  Future<Set<String>> _compareListsTitles(
      List<String> titlesBanners, List<String> _titlesAnilist) async {
    final Set<String> recommendation = {};
    final Set<String> titlesInCommon = {};

    print('running $_compareListsTitles');

    final setTitlesAnilist =
        _titlesAnilist.map((title) => title.toLowerCase().trim()).toSet();
    final setTitlesBanners =
        titlesBanners.map((title) => title.toLowerCase().trim()).toSet();

    titlesInCommon.addAll(setTitlesAnilist.intersection(setTitlesBanners));

    recommendation
        .add(titlesInCommon.isNotEmpty ? titlesInCommon.toString() : 'n/a');

    return recommendation;
  }

  // Configura o router para lidar com as solicitações
  Future<void> setRouter(Router router) async {
    router.get('/v1/manga/recommendations', (Request request) async {
      final titleQuery = await request.url.queryParameters['title'];

      final titlesBanners = await BannersTitlesApi.getTitlesFromBanners();

      final titlesAnilist =
          await RecommendationAnilistApi.getRecommendationAnilist(
              titleQuery!.toLowerCase());

      final recommendation = await _compareListsTitles(
          titlesBanners.map((e) => e['title'].toString()).toList(),
          titlesAnilist);

      final titleResponseApi = await BannersTitlesApi.getBannerTitleResponse(
          titlesBanners, recommendation);

      entity = RecommendationEntity(
        createAt: DateTime.now(),
        title: titleQuery,
        recommendation: titleResponseApi.toList(),
      );

      return Response.ok(
        json.encode({
          "createAt": entity.createAt.toString(),
          "title": entity.title,
          "recommendation": entity.recommendation,
        }),
        headers: DataConfigUtils.headers,
      );
    });
  }
}
