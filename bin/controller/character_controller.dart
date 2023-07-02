import 'package:http/http.dart' as http;
import 'dart:convert';

class CharacterControllerApi {
  late String name;
  late String? gender;
  late String? age;
  late var iconImage;
  late int id;
  late String? descriptionChar;
  late var birthday;
  late var title;

  final query = r'''
    query {
  Character(search: "Koyomi Araragi") {
    name {
      full
    }
    image {
          large
        }
    id
    gender
    age
    description(asHtml: false)
    dateOfBirth {
      year
      month
      day
      }
    media {
      nodes {
        title {
          english
        }
      }
    }
  }
}
  ''';

  Future<void> sendCharacterPostRequest() async {
    final body = json.encode({'query': query});
    final headers = {'Content-Type': 'application/json'};
    final url = Uri.parse('https://graphql.anilist.co');
    final response = await http.post(url, headers: headers, body: body);

    String limitString(String input, int maxLength) =>
        input.length <= maxLength ? input : input.substring(0, maxLength);

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      final character = jsonResponse['data']['Character'];
      final imageLink = character['image']['large'];

      // Requisição para obter os bytes da imagem
      final imageBytes = await http.get(Uri.parse(imageLink));
      iconImage = imageBytes.bodyBytes;
      // Converte o link em imagem para bytes

      name = character['name']['full'];

      gender = character['gender'];

      age = character['age'];

      id = character['id'];

      descriptionChar = character['description'];

      birthday = character['dateOfBirth'];

      title = character['media']['nodes'];

      print(jsonResponse);
    } else {
      print('Erro na chamada da API: ${response.body}');
      throw Exception(response.statusCode);
    }
  }
}
