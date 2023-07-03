import 'dart:convert';

import '../controller/character_controller.dart';

class HttpRequestApi {
  Map<String, String> headers;
  late dynamic body;

  HttpRequestApi({
    this.headers = const {'Content-Type': 'application/json'},
    this.body,
  });
}

class CharacterRepository {
  final String query;
  CharacterRepository(
      {this.query = r'''
    query {
      Character(search: "Koyomi Araragi") {
        id
        name {
          full
        }
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
  '''});
}

class CharacterModelos {
  late dynamic id;
  late String? name;
  late dynamic gender;
  late dynamic age;
  late dynamic descriptionChar;
  late dynamic birthday;
  late dynamic title;
  late dynamic iconImage;

  CharacterModelos({
    this.id,
    this.name,
    this.gender,
    this.age,
    this.descriptionChar,
    this.birthday,
    this.title,
    this.iconImage,
  });

  factory CharacterModelos.fromJson(Map<String, dynamic> json) {
    final controller = CharacterControllerApi();
    final jsonResponse = jsonDecode(controller.response);
    final character = jsonResponse['data']['Character'];
    final name = character['name']['full'];

    return CharacterModelos(
      name: name,
    );
  }
}
