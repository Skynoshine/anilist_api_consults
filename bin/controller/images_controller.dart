import '../apis/images_anilist.dart';

class ImagesController {
  Future getImages(String searchTerm) async {
    final images = await ImagesApi().getImages(searchTerm);
  }
}
