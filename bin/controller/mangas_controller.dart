import 'package:http/http.dart' as http;
import 'dart:convert';

class MangasControllerApi {
  late var titleManga;
  late int? volumes;
  
  final query = r''' 
    query{
      Media(isAdult: false){
        title{
          english
        }
        volumes
      }
    }
  ''';

  Future<void> viewMangaRequest() async {
    final body = json.encode({'query': query});
    final headers = {'Content-Type': 'application/json'};
    final url = Uri.parse('https://graphql.anilist.co');
    final response = await http.post(url, headers: headers, body: body);

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      final mangaList = jsonResponse['data']['Media'];

      titleManga = mangaList['title']['english'];
      volumes = mangaList['volumes'];
    } else {
      print('Erro na chamada da API: ${response.body}');
      throw Exception(response.statusCode);
    }
  }
}
