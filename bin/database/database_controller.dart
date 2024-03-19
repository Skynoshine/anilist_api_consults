import 'package:mongo_dart/mongo_dart.dart';

import '../core/utils.dart';

class RecommendationCache {
  late Db _db;
  final String _titlesCollection = Utils.collecAlternativeT;
  final String _recommendationCollection = Utils.collecRecommendation;

  // Conecta ao banco de dados
  Future<Db> _dbConnect(String function) async {
    final dbUrl = await Utils.getDotenv(); // Obtém a URL do banco de dados
    _db = await Db.create(dbUrl); // Cria uma conexão com o banco de dados
    try {
      await _db.open(); // Abre a conexão com o banco de dados
      print('${_db.state} in $function'); // Registra o estado do banco de dados
    } catch (e) {
      DbLogger.errorLogger(
        tableName: _db.state.toString(),
        responseBody: e,
        responseCode: _db.state,
        operationName: '$_dbConnect()', // Registra erros de conexão
      );
    }
    return _db; // Retorna a conexão com o banco de dados
  }

  // Fecha a conexão com o banco de dados
  Future<void> _dbClose(String function) async {
    if (_db.isConnected) {
      try {
        await _db.close(); // Fecha a conexão com o banco de dados
        print(
            "${_db.state} in $function"); // Registra o estado do banco de dados
      } catch (e) {
        DbLogger.errorLogger(
          tableName: _db.uriList.toString(),
          responseBody: e, // Registra erros de conexão
          responseCode: _db.state,
        );
      }
    }
  }

  // Compara as datas para verificar se a recomendação precisa ser atualizada
  Future<bool> _compareDateTime(String toVerify, String collectionPath) async {
    // Verifica se o título possui mais de 7 dias
    bool isMoreSevenDays = false;
    try {
      final collection = _db.collection(collectionPath);
      final items = await collection.find({'title': toVerify}).toList();
      final currentDate = DateTime.now();

      for (var item in items) {
        if (item.containsKey('createAt')) {
          final createAtString = item['createAt'] as String;
          final createAt =
              DateTime.parse(createAtString); // Converte a string em DateTime
          final dateTimeDifference = currentDate.difference(createAt).inDays;
          if (dateTimeDifference > 7) {
            //Se a recomendação possuir mais de 7 dias, retorna TRUE
            return isMoreSevenDays = true;
          }
        }
      }
    } catch (e) {
      Utils.requestlog(
        name: 'CompareDateTime',
        path: collectionPath,
        error: e,
      );
    }
    return isMoreSevenDays;
  }

  // Insere uma nova recomendação
  Future<void> insertRecommendation(
      Map<String, dynamic> entity, String toVerify, Set titleResponse) async {
    await _dbConnect("insertRecommendation"); // Conecta ao banco de dados

    final bool isMoreSevenDays = await _compareDateTime(toVerify,
        _recommendationCollection); // Verifica se o título possui mais de 7 dias

    // Se o título tiver mais de 7 dias, atualiza a recomendação
    if (isMoreSevenDays == true) {
      final query = {'title': toVerify};
      await _db.collection(_recommendationCollection).replaceOne(query, entity);
    } else {
      // Se não houver recomendações com o título correspondente, insere uma nova recomendação
      final bool containRecommendation =
          await _checkDoubleContent(toVerify, _recommendationCollection);
      if (containRecommendation == false) {
        try {
          if (titleResponse.isNotEmpty) {
            await _db.collection(Utils.collecRecommendation).insert(entity);
            print('insert $toVerify sucefull in ${_recommendationCollection}');
          }
        } catch (e) {
          DbLogger.errorLogger(
            tableName: _db.databaseName,
            operationName: 'insertRecommendation',
            error: e,
          );
        }
      }
    }
    await _dbClose(
        "InsertRecommendation"); // Fecha a conexão com o banco de dados
  }

  // Verifica se há títulos alternativos correspondentes
  Future<bool> _checkDoubleContent(
      String toVerify, String collectionPath) async {
    try {
      final collection = _db.collection(collectionPath);
      // Verifica se existe algum documento na coleção com o título igual
      final count = await collection.count({"title": toVerify});
      return count > 0; // Retorna true se houver um título correspondente
    } catch (e) {
      Utils.requestlog(
        name: 'verifyAlternativesT',
        path: collectionPath,
        error: e,
      );
      return false; // Retorna false em caso de erro
    }
  }

  Future<bool> verifyTitleCache(
      {required String collectionPath, required String toVerify}) async {
    bool containInCache = false;
    try {
      await _dbConnect("verifyTitleCache"); // Conecta ao banco de dados
      final collection = _db.collection(collectionPath);
      final search = where.eq(await "title", toVerify.toLowerCase());
      final result = await collection.findOne(search);
      final doubleContent = await _checkDoubleContent(toVerify, collectionPath);

      final isMoreSevenDays = await _compareDateTime(toVerify,
          collectionPath); // Verifica se o título possui mais de 7 dias

      if (result != null) {
        // Se já tiver o título no cache, retorna true
        containInCache = true;
      }
      if (isMoreSevenDays == true || doubleContent == false) {
        // Se já tiver, e ter mais que 7 dias, retorna false
        containInCache = false;
      }
      await _dbClose("verifyTitleCache");
    } catch (e) {
      DbLogger.errorLogger(
        operationName: 'verifyTitleCache',
        tableName: collectionPath,
        error: e,
      );
    }
    return containInCache;
  }

  Future<Map<String, dynamic>?> getCacheContent(
      String collectionPath, String titleSearch) async {
    await _dbConnect("getCacheContent");
    final collection = _db.collection(collectionPath);
    final table = where.eq(await "title", titleSearch.toLowerCase());

    final response = await collection.findOne(table);

    if (response != null) {
      response.remove("_id");
      response.remove("recommendation" "_uid");
    }

    await _dbClose("getCacheContent");
    return response;
  }

  Future<dynamic> insertAlternativeT(
      Map<String, dynamic> entity, String toVerify, Set titleResponse) async {
    // Verifica se a requisição não está vazia
    if (entity["alternativeTitle"].isNotEmpty) {
      await _dbConnect("InsertAlternativeT"); // Conecta ao banco de dados

      bool isMoreSevenDays =
          await _compareDateTime(toVerify, _titlesCollection);

      if (isMoreSevenDays == true) {
        // Se o título for maior que 7 dias dá update
        final query = {'title': toVerify};
        await _db
            .collection(Utils.collecAlternativeT)
            .replaceOne(query, entity);
      } else {
        final bool _containAlternativeT =
            await _checkDoubleContent(toVerify, _titlesCollection);

        if (_containAlternativeT == false) {
          // Se já não possuir o título, será inserido
          try {
            if (titleResponse.isNotEmpty) {
              await _db.collection(Utils.collecAlternativeT).insert(entity);
              print(
                  "insert $titleResponse sucefull in ${Utils.collecAlternativeT}");
            }
          } catch (e) {
            DbLogger.errorLogger(
                tableName: _db.databaseName,
                responseBody: e,
                operationName: "InsertAlternativeT");
          }
        }
      }
      await _dbClose("InsertAlternativeT");
    }
  }
}
