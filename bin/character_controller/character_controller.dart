import 'package:http/http.dart' as http;
import 'dart:convert';

class CharacterControllerApi {
  late String name;
  late String? gender;
  late String? age;
  late dynamic iconImage;
  late int id;
  late String? descriptionChar;
  late bool isFavourite;
  final query = r'''
    query {
      Character(search: "Hitagi Senjougahara") {
        name {
          full
        }
        id
        image {
          large
        }
        gender
        age
        description(asHtml: false)
        isFavourite
      }
    }
  ''';

  Future<void> sendCharacterPostRequest() async {
    final body = json.encode({'query': query});
    final headers = {'Content-Type': 'application/json'};
    final url = Uri.parse('https://graphql.anilist.co');
    final response = await http.post(url, headers: headers, body: body);

    String limitString(String input, int maxLength) {
      return input.length <= maxLength ? input : input.substring(0, maxLength);
    }

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
      descriptionChar = limitString(descriptionChar!, 350);
      isFavourite = character['isFavourite'];

      print(jsonResponse);
    } else {
      print('Erro na chamada da API: ${response.statusCode}');
      throw Exception(response.statusCode);
    }
  }
}
