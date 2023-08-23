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

  Future<bool> _compareDateTime(String toVerify) async {
    bool isMoreSevenDays = false;

    try {
      final collection = _db.collection(DataConfigUtils.collectionDB);
      final items = await collection.find({'title': toVerify}).toList();

      final currentDate = DateTime.now();

      for (var item in items) {
        if (item.containsKey('createAt')) {
          final createAtString = item['createAt'] as String;
          final createAt =
              DateTime.parse(createAtString); // Converter a string em DateTime
          final difference = currentDate.difference(createAt).inDays;

          if (difference > 7) {
            //maior que 7 dias
            return isMoreSevenDays = true;
          } else {
            return isMoreSevenDays = false;
          }
        }
      }
    } catch (e) {
      print(e);
    }
    return isMoreSevenDays;
  }

  Future<bool> _verifyRecommendation(String toVerify) async {
    try {
      final collection = _db.collection(DataConfigUtils.collectionDB);
      final items = await collection.find({'title': toVerify}).toList();
      return items
          .isNotEmpty; // Não encontrou nenhuma recomendação com o título correspondente
    } catch (e) {
      print('Erro ao obter conteúdo da coleção: $e');
      return false;
    }
  }

  Future<void> updateRecommendation(String titleToUpdate) async {
    try {
      final collection = _db.collection(DataConfigUtils.collectionDB);
      final currentDate = DateTime.now();

      final updateData = {
        'updatedAt': currentDate.toString(),
      };

      print('Recommendation $titleToUpdate updated successfully.');
    } catch (e) {
      print(e);
    }
  }

  Future<void> insertRecommendation(Map<String, dynamic> entity,
      String titleToVerify, Set titleResponse) async {
    await _dbConnect();
    containRecommendation = await _verifyRecommendation(titleToVerify);

    if (containRecommendation == false) {
      // Não possui recomendação
      try {
        if (titleResponse.isNotEmpty) {
          await _db.collection(DataConfigUtils.collectionDB).insert(entity);
          print('insert sucefull in ${DataConfigUtils.collectionDB}');
        }
      } catch (e) {
        DatabaseErrorLogger.errorLogger(
          tableName: _db.databaseName,
          responseBody: e,
          operationName: 'insertRecommendation',
        );
      }
    } else {
      print('já possuímos recomendação para este mangá!');
    }
    await _dbClose();
  }
}
