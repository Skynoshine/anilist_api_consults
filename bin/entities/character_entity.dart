class CharacterEntity {
  final id;
  final String? name;
  final gender;
  final age;
  final descriptionChar;
  final birthday;
  final title;
  final iconImage;

  CharacterEntity({
    this.id,
    this.name,
    this.gender,
    this.age,
    this.descriptionChar,
    this.birthday,
    this.title,
    this.iconImage,
  });

  factory CharacterEntity.fromJson(Map<String, dynamic> json) {
    final character = json['data']['Character'];
    final name = character['name']['full'];

    return CharacterEntity(
      name: name,
    );
  }
}
