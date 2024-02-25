import 'package:mongo_dart/mongo_dart.dart';

import '../core/data_config_utils.dart';

class RecommendationCache {
  late Db _db;
  bool _containRecommendation = false;
  bool _containAlternativeT = false;

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

  // ignore: unused_element
  Future<bool> _compareDateTime(String toVerify, String collectionPath) async {
    bool isMoreSevenDays = false;

    try {
      final collection = _db.collection(collectionPath);
      final items = await collection.find({'title': toVerify}).toList();

      final currentDate = DateTime.now();

      for (var item in items) {
        if (item.containsKey('createAt')) {
          final createAtString = item['createAt'] as String;
          final createAt =
              DateTime.parse(createAtString); // Converter a string em DateTime
          final difference = currentDate.difference(createAt).inDays;
          print(createAtString);
          if (difference > 7) {
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
      final collection = _db.collection(DataConfigUtils.collecRecommendation);
      final items = await collection.find({'title': toVerify}).toList();
      print('Consultando a verificação...');
      return items
          .isEmpty; // Não encontrou nenhuma recomendação com o título correspondente
    } catch (e) {
      print('Erro ao obter conteúdo da coleção: $e');
      return false;
    }
  }

  Future<void> insertRecommendation(Map<String, dynamic> entity,
      String titleToVerify, Set titleResponse) async {
    await _dbConnect();
    _containRecommendation = await _verifyRecommendation(titleToVerify);

    final bool updateRecommendation = await _compareDateTime(
        titleToVerify, DataConfigUtils.collecRecommendation);

    if (updateRecommendation == true) {
      final query = {'title': titleToVerify};
      await _db
          .collection(DataConfigUtils.collecRecommendation)
          .replaceOne(query, entity);
    } else {
      if (_containRecommendation == false) {
        try {
          if (titleResponse.isNotEmpty) {
            await _db
                .collection(DataConfigUtils.collecRecommendation)
                .insert(entity);
            print('insert sucefull in ${DataConfigUtils.collecRecommendation}');
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
    }
    await _dbClose();
  }

  Future<bool> _verifyAlternativesT(String toVerify) async {
    try {
      final collection = _db.collection(DataConfigUtils.collecAlternativeT);
      // Verifica se existe algum documento na coleção com o título igual
      final count = await collection.count({"title": toVerify});
      return count > 0; // Retorna true se existir um título correspondente
    } catch (e) {
      print(e);
      return false; // Retorna false em caso de erro
    }
  }

  Future<dynamic> insertAlternativeT(
      Map<String, dynamic> entity, String toVerify, Set titleResponse) async {
    await _dbConnect();

    bool updateTitle =
        await _compareDateTime(toVerify, DataConfigUtils.collecAlternativeT);

    if (updateTitle == true) {
      // Se o título for maior que 7 dias dá update
      final query = {'title': toVerify};
      await _db
          .collection(DataConfigUtils.collecAlternativeT)
          .replaceOne(query, entity);
    } else {
      _containAlternativeT = await _verifyAlternativesT(toVerify);

      if (_containAlternativeT == false) {
        try {
          if (titleResponse.isNotEmpty) {
            await _db
                .collection(DataConfigUtils.collecAlternativeT)
                .insert(entity);
            print("Título $titleResponse inserido com sucesso!");
          }
        } catch (e) {
          DatabaseErrorLogger.errorLogger(
              tableName: _db.databaseName,
              responseBody: e,
              operationName: "InsertAlternativeT");
        }
      }
    }
    await _dbClose();
  }
}
