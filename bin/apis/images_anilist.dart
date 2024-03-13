import 'dart:convert';
import 'package:http/http.dart' as http;

import '../core/data_utils.dart';
import '../repositories/images_repository.dart';

class ImagesApi {
  Future<Map<String, dynamic>> getImages(String searchTerm) async {
    Map<String, dynamic> _images = {};

    final _body =
        await {'query': ImagesRepository().getImages(searchTerm: searchTerm)};

    final _response = await http.post(Utils.urlAnilist,
        headers: Utils.headers, body: jsonEncode(_body));

    if (_response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(_response.body);
      final String banner = data['data']['Media']['bannerImage'];
      final Map<String, dynamic> cover = data['data']['Media']['coverImage'];
      _images = {
        'banner': banner,
        'cover': cover,
      };
    } else {
      Utils.requestlog(
        name: "getImages",
        path: Utils.urlAnilist.toString(),
      );
    }
    return _images;
  }
}
