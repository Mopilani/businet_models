
import 'dart:async';
import 'dart:convert';

import 'package:mongo_dart/mongo_dart.dart';

import '../../utils/system_db.dart';
import '../quality_control/action_model.dart';

// class Currency {
//   static const String sudanesePound = 'ج.س';
//   static const String usDollar = 'USD';
// }

class CurrencyModel {
  CurrencyModel._();

  CurrencyModel(
    this.id, {
    required this.brief,
  });

  late int id;
  late dynamic mid; // Mongo document id
  late String brief;

  static const String collectionName = 'currencies';

  static CurrencyModel fromMap(Map<String, dynamic> data) {
    CurrencyModel model = CurrencyModel._();
    model.id = data['id'];
    model.brief = data['brief'];
    model.mid = data['_id'];

    return model;
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'brief': brief,
      };

  String toJson() => json.encode(toMap());

  static CurrencyModel fromJson(String jsn) {
    return fromMap(json.decode(jsn));
  }

  static Future<List<CurrencyModel>> getAll() {
    List<CurrencyModel> catgs = [];
    return SystemMDBService.db
        .collection(collectionName)
        .find()
        .transform<CurrencyModel>(
          StreamTransformer.fromHandlers(
            handleData: (data, sink) {
              sink.add(CurrencyModel.fromMap(data));
            },
          ),
        )
        .listen((subCatg) {
          catgs.add(subCatg);
        })
        .asFuture()
        .then((value) => catgs);
  }

  static Stream<CurrencyModel> stream() {
    return SystemMDBService.db.collection(collectionName).find().transform(
      StreamTransformer.fromHandlers(
        handleData: (data, sink) {
          sink.add(CurrencyModel.fromMap(data));
        },
      ),
    );
  }

  Future<CurrencyModel?> aggregate(List<dynamic> pipeline) async {
    var d = await SystemMDBService.db
        .collection(collectionName)
        .aggregate(pipeline);

    return CurrencyModel.fromMap(d);
  }

  static Future<CurrencyModel?> get(int id) async {
    var d = await SystemMDBService.db
        .collection(collectionName)
        .findOne(where.eq('id', id));
    if (d == null) {
      return null;
    }
    return CurrencyModel.fromMap(d);
  }

  static Future<CurrencyModel?> findById(int id) async {
    var d = await SystemMDBService.db
        .collection(collectionName)
        .findOne(where.eq('id', id));
    if (d == null) {
      return null;
    }
    return CurrencyModel.fromMap(d);
  }

  static Future<CurrencyModel?> findByBrief(String brief) async {
    var d = await SystemMDBService.db
        .collection(collectionName)
        .findOne(where.eq('brief', brief));
    if (d == null) {
      return null;
    }
    return CurrencyModel.fromMap(d);
  }

  Future<CurrencyModel> edit([bool fromSyncService = false]) async =>
      await editToCol(collectionName, fromSyncService);

  Future<CurrencyModel> editToCol(String collName,
      [bool fromSyncService = false]) async {
    var r = await SystemMDBService.db.collection(collName).update(
          where.eq('id', id),
          toMap(),
        );
    if (!fromSyncService) {
      await ActionModel.updatedCurrency(this, collName);
      print(r);
    }
    return this;
  }

  Future<int> delete([bool fromSyncService = false]) async =>
      await deleteFromColl(collectionName, fromSyncService);

  Future<int> deleteFromColl(String collName,
      [bool fromSyncService = false]) async {
    var r = await SystemMDBService.db.collection(collName).remove(
          where.eq('id', id),
        );
    if (!fromSyncService) {
      await ActionModel.deletedCurrency(this, collName);
      print(r);
    }
    return 1;
  }

  Future<int> add([bool fromSyncService = false]) async =>
      await addToCol(collectionName, fromSyncService);

  Future<int> addToCol(String collName, [bool fromSyncService = false]) async {
    var r = await SystemMDBService.db.collection(collName).insert(
          toMap(),
        );
    if (!fromSyncService) {
      await ActionModel.createdCurrency(this, collName);
    }
    print(r);
    return 1;
  }

  Future<int> moveToColl(
      String fromCollectionName, String toCollectionName) async {
    var r = await deleteFromColl(fromCollectionName);
    print(r);
    r = await addToCol(toCollectionName);
    print(r);
    return 1;
  }

  Future<int> deleteWithMID([bool fromSyncService = false]) async {
    print(mid);
    var r = await SystemMDBService.db.collection(collectionName).remove(
          where.eq('_id', mid),
        );
    if (!fromSyncService) {
      await ActionModel.deletedCurrency(this, collectionName);
      print(r);
    }
    return 1;
  }
}

  // Future<CurrencyModel?> edit() async {
  //   var r = await SystemMDBService.db.collection(collectionName).update(
  //         where.eq('_id', mid),
  //         toMap(),
  //       );
  //   print(r);
  //   return this;
  // }

  // static Future<int> delete(int id) async {
  //   var r = await SystemMDBService.db.collection(collectionName).remove(
  //         where.eq('id', id),
  //       );
  //   print(r);
  //   return 1;
  // }


  // Future<int> add() async {
  //   var r = await SystemMDBService.db.collection(collectionName).insert(
  //         toMap(),
  //       );
  //   print(r);
  //   return 1;
  // }
