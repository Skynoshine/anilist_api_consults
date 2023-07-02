import 'dart:convert';
import 'package:http/http.dart' as http;

class SearchController {
  final url = Uri.parse('https://graphql.anilist.co');

  final query = '''
    query {
      Character(search: "Koyomi Araragi") {
        id
        name {
          full
        }
        image {
          large
        }
      }
    }
  ''';

  Future<dynamic> fetchDataFromApi() async {
    final body = json.encode({'query': query});
    final headers = {'Content-Type': 'application/json'};

    final response = await http.post(url, headers: headers, body: body);

    if (response.statusCode == 200) {
      var jsonResponse = jsonDecode(response.body);
      print(jsonResponse);
      jsonResponse['data']['Character']['name'];
    } else {
      print('Erro na chamada da API: ${response.statusCode}');
      throw Exception(response.statusCode);
    }
  }
}
