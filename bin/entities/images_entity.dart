class ImagesEntity {
  final String extraLarge;
  final String large;
  final String medium;
  final String color;

  ImagesEntity(
    this.extraLarge,
    this.large,
    this.medium,
    this.color,
  );

  factory ImagesEntity.fromJson(Map<String, dynamic> json) {
    final image = json['data']['Page']['media']['coverImage'];
    final extraLarge = image['extralarge'];
    final large = image['large'];
    final medium = image['medium'];
    final color = image['color'];

    return ImagesEntity(extraLarge, large, medium, color);
  }
}

//EM PRODUÇÃO