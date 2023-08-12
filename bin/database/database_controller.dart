import 'package:mongo_dart/mongo_dart.dart';

import '../core/data_config_utils.dart';

class RecommendationCache {
  late Db _db;
  bool containRecommendation = false;

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

  Future<bool> _verifyRecommendation(String toVerify) async {
    try {
      final collection = _db.collection(DataConfigUtils.collectionDB);
      final items = await collection.find().toList();

      for (var item in items) {
        final recommendations = item['recommendation'] as List<dynamic>;
        for (var recommendation in recommendations) {
          final title = recommendation['title'] as String;

          if (title.contains(toVerify)) {
            return true;
          }
          
        }
      }
      return false; // Não encontrou nenhuma recomendação com o título correspondente
    } catch (e) {
      print('Erro ao obter conteúdo da coleção: $e');
      return false;
    }
  }

  Future<void> insertRecommendation(
      Map<String, dynamic> entity, String titleToVerify) async {
    await _dbConnect();
    await _verifyRecommendation(titleToVerify);

    if (containRecommendation == false) {
      print(containRecommendation);
      try {
        await _db.collection(DataConfigUtils.collectionDB).insert(entity);
        print('insert sucefull in ${DataConfigUtils.collectionDB}');
      } catch (e) {
        DatabaseErrorLogger.errorLogger(
          tableName: _db.databaseName,
          responseBody: e,
          operationName: 'insertRecommendation',
        );
      } finally {
        await _dbClose();
      }
    } else {
      print('já possuímos recomendação para este mangá!');
    }
  }
}
