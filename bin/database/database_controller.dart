import 'package:mongo_dart/mongo_dart.dart';

import '../controller/recommendation_controller.dart';
import '../core/data_config_utils.dart';

class RecommendationCache {
  RecommendationController _controller = RecommendationController();
  late Db _db;

  Future<Db> _dbConnect() async {
    _db = await Db.create(DataConfigUtils.urlMongoDB);
    try {
      await _db.open();
      print('connected ${_db.databaseName}');
    } catch (e) {
      DatabaseErrorLogger.errorLogger(
        tableName: '',
        responseBody: e,
        responseCode: _db.state,
        operationName: '$_dbConnect()',
      );
    }
    return _db;
  }

  Future<void> _dbClose() async {
    if (_db.isConnected) {
      try {
        await _db.close();
        print('connection closed ${_db.state}');
      } catch (e) {
        DatabaseErrorLogger.errorLogger(
          tableName: _db.uriList.toString(),
          responseBody: e,
          responseCode: _db.state,
        );
      }
    }
  }

  Future<void> insertRecommendation() async {
    final dynamic insertEntity = {
      _controller.entity.createAt,
      _controller.entity.recommendation,
      _controller.entity.title,
    };

    try {
      final db = await _dbConnect();
      await db.collection(DataConfigUtils.collectionDB).insert(insertEntity);
      print('insert successful');
    } catch (e) {
      DatabaseErrorLogger.errorLogger(
        tableName: _db.databaseName,

      );
    } finally {
      await _dbClose();
    }
  }
}
