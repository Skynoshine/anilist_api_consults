class HttpRequestApi {
  Map<String, String> headers = const {'Content-Type': 'application/json'};
  final Uri url = Uri.parse("https://graphql.anilist.co");
}
