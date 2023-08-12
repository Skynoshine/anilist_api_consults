import 'package:mongo_dart/mongo_dart.dart';

import '../core/data_config_utils.dart';
import '../controller/api_recommendation_controller.dart';
import '../entities/recommendation_entity.dart';

class RecommendationCache {
  late Db _db;

  ApiRecommendation _apiRecommendation = ApiRecommendation();

  Future<dynamic> _dbConnect() async {
    _db = await Db.create(DataConfigUtils.urlMongoDB);
    try {
      await _db.open();
      print('connected ${_db.databaseName}');
    } catch (e) {
      print('failed to connect ${_db.databaseName} ${_db.state}');
    }
    return _db;
  }

  Future<void> _dbClose() async {
    if (_db.isConnected) {
      try {
        await _db.close();
        print('connection closed ${_db.state}');
      } catch (e) {
        print('failed to close connection${_db.state}');
      }
    } else {
      print('error ${_db.databaseName} ${_db.state}');
    }
  }

  Future<void> _showTableContents() async {
    final collection = _db.collection(DataConfigUtils.collectionDB);

    try {
      final documents = await collection.find().toList();
      print(documents);
    } catch (e) {
      print('error to show content in${_db.databaseName}, ${_db.state}');
    }
  }

  Future<void> insertRecommendation() async {
    DateTime createAt = DateTime.now();

    RecommendationEntity entity = RecommendationEntity(
      createAt: createAt,
      title: title,
      recommendation: recommendation.toList(),
    );

    try {
      //await _db.collection(_utils.collectionDB).insert(entity.toJson());
      print('entity: ${entity.toJson()}');
    } catch (e) {
      print('error insert');
    }
  }
}

Future<void> main() async {
  RecommendationCache cache = RecommendationCache();

  await cache._apiRecommendation.running('made in abyss');
}
