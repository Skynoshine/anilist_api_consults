import 'dart:convert';
import 'package:http/http.dart' as http;

import '../core/utils.dart';

class MangaEasyBannersApi {
  static Future<List> getTitlesFromBanners() async {
    List titlesBanners = [];
    final response = await http.get(Utils.mangaEasyBanners);

    if (response.statusCode == 200) {
      final decodedData = json.decode(response.body) as Map<String, dynamic>;
      titlesBanners = decodedData['data'] as List<dynamic>;
    } else {
      Utils.requestlog(
        name: "GetTitlesFromBanners",
        path: Utils.mangaEasyBanners.toString(),
        responseCode: response.statusCode,
        header: Utils.headers,
        responseBody: response.body,
      );
    }
    return titlesBanners;
  }

  // Obtém respostas dos títulos dos banners e retorna o resultado
  static Future<Set> getBannerTitleResponse(
      List items, Set<String> recommendation) async {
    final Set<dynamic> titleResponseApi = {};
    try {
      for (var element in recommendation.toList()) {
        final int index = items.indexWhere(
          (e) => e['title'].toString().toLowerCase().contains(element
              .toLowerCase()
              .replaceFirst('{', '')
              .replaceFirst('}', '')),
        );
        if (index != -1) {
          titleResponseApi.add(items[index]);
        }
      }
    } catch (e) {
      Utils.requestlog(
        name: 'GetBannerTitleResponse',
        path: Utils.collecAlternativeT,
        error: e,
      );
    }
    return titleResponseApi;
  }
}
