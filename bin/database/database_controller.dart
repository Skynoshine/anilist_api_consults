import 'package:mongo_dart/mongo_dart.dart';

import '../core/data_config_utils.dart';

class RecommendationCache {
  late Db _db;

  Future<Db> _dbConnect() async {
    final dbUrl = await DataConfigUtils.getDotenv();
    _db = await Db.create(dbUrl);
    
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

  Future<void> insertRecommendation(entity) async {
    try {
      await _dbConnect();
      await _db.collection(DataConfigUtils.collectionDB).insert(entity);
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
