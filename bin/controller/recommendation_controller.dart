import 'dart:convert';

import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import '../apis/banners_titles.dart';
import '../apis/recommendation_anilist.dart';
import '../core/data_utils.dart';
import '../database/database_controller.dart';
import '../entities/recommendation_entity.dart';

class RecommendationController {
  // Compara títulos e encontra os em comum e retorna titulo em comum e recomendaçao
  Future<Set<String>> _compareTitles(
      List<String> titlesBanners, List<String> _titlesAnilist) async {
    final Set<String> recommendation = {};
    final Set<String> titlesInCommon = {};

    final setTitlesAnilist =
        _titlesAnilist.map((title) => title.toLowerCase().trim()).toSet();
    final setTitlesBanners =
        titlesBanners.map((title) => title.toLowerCase().trim()).toSet();

    titlesInCommon.addAll(setTitlesAnilist.intersection(setTitlesBanners));

    recommendation
        .add(titlesInCommon.isNotEmpty ? titlesInCommon.toString() : 'n/a');

    return recommendation;
  }

  Future _getRecommendations(String titleQuery, request) async {
    final cache = RecommendationCache();

    final titlesBanners = await BannersTitlesApi.getTitlesFromBanners();

    final titlesAnilist =
        await RecommendationAnilistApi.getRecommendationAnilist(
            titleQuery.toLowerCase());

    final recommendation = await _compareTitles(
        titlesBanners.map((e) => e['title'].toString()).toList(),
        titlesAnilist);

    final titleResponseApi = await BannersTitlesApi.getBannerTitleResponse(
        titlesBanners, recommendation);

    final entity = RecommendationEntity(
      createAt: DateTime.now(),
      title: titleQuery,
      recommendation: titleResponseApi.toList(),
    );

    cache.insertRecommendation(
        entity.toJson(), titleQuery.toString(), titleResponseApi);

    final entityEncoded = jsonEncode(entity.toJson());

    if (titleResponseApi.toList().isNotEmpty) {
      return Response.ok(
        entityEncoded,
        headers: Utils.headers,
      );
    } else {
      return Response.notFound(
        entityEncoded,
        headers: Utils.headers,
      );
    }
  }

  Future<dynamic> recommendationEndpoint(Router router) async {
    final cache = RecommendationCache();

    router.get('/v1/manga/recommendations', (Request request) async {
      final titleQuery = request.url.queryParameters['title'];
      final isRepeat = await cache.verifyTitleCache(
          collectionPath: Utils.collecRecommendation, toVerify: titleQuery!);

      final content =
          await cache.getCacheContent(Utils.collecRecommendation, titleQuery);
      print(content);

      if (isRepeat == true) {
        return Response.ok(
          content.toString(),
          headers: Utils.headers,
        );
      } else {
        return _getRecommendations(titleQuery, request);
      }
    });
  }
}
