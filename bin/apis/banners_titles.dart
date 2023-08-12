import 'dart:convert';
import 'package:http/http.dart' as http;

import '../core/data_config_utils.dart';

class BannersTitlesApi {
  static Future<List> getTitlesFromBanners() async {
    print('running $getTitlesFromBanners');

    List titlesBanners = [];

    final response = await http.get(DataConfigUtils.urlBannersApi);

    DataConfigUtils.requestlog(
      path: DataConfigUtils.urlBannersApi.toString(),
      responseBody: response.body,
      responseCode: response.statusCode,
    );

    if (response.statusCode == 200) {
      final decodedData = json.decode(response.body) as Map<String, dynamic>;
      titlesBanners = decodedData['data'] as List<dynamic>;
    } else {
      print('Falha na requisição: ${response.statusCode}');
    }
    return titlesBanners;
  }

  // Obtém respostas dos títulos dos banners e retorna o resultado
  static Future<Set> getBannerTitleResponse(
      List items, Set<String> recommendation) async {
    final Set<dynamic> titleResponseApi = {};

    print('running $getBannerTitleResponse');

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
      print('failed to get bannerTitleResponse: $e');
    }
    return titleResponseApi;
  }
}
