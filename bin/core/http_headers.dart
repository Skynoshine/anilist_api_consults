class HttpRequestApi {
  Map<String, String> headers = const {'Content-Type': 'application/json'};
  final Uri url = Uri.parse("https://graphql.anilist.co");
  final Uri urlRecommendations =
      Uri.parse('https://monolito.lucas-cm.com.br/v1/recommendations/list');
}
