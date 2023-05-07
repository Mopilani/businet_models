import 'dart:async';
import 'dart:convert';

import 'package:mongo_dart/mongo_dart.dart';

import '../../utils/enums.dart';
import '../../utils/system_db.dart';
import '../hr/user_model.dart';
import 'tree_sub_account_model.dart';
import 'user_lite_model.dart';

class StaticsModel {
  StaticsModel(
    this.id, {
    required this.meta,
  });

  dynamic id;
  Map<dynamic, dynamic> meta = {};

  static const String collectionName = 'statics';

  static StaticsModel fromMap(Map<String, dynamic> data) {
    StaticsModel model = StaticsModel(
      data['id'],
      meta: data['meta'],
    );
    return model;
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'meta': meta,
      };

  String toJson() => json.encode(toMap());

  static StaticsModel fromJson(String jsn) {
    return fromMap(json.decode(jsn));
  }

  static Future<List<StaticsModel>> getAll() {
    List<StaticsModel> catgs = [];
    return SystemMDBService.db
        .collection(collectionName)
        .find()
        .transform<StaticsModel>(
          StreamTransformer.fromHandlers(
            handleData: (data, sink) {
              sink.add(StaticsModel.fromMap(data));
            },
          ),
        )
        .listen((subCatg) {
          catgs.add(subCatg);
        })
        .asFuture()
        .then((value) => catgs);
  }

  static Future<List<StaticsModel>> getOf(String collectionName) {
    List<StaticsModel> catgs = [];
    return SystemMDBService.db
        .collection(collectionName)
        .find()
        .transform<StaticsModel>(
          StreamTransformer.fromHandlers(
            handleData: (data, sink) {
              sink.add(StaticsModel.fromMap(data));
            },
          ),
        )
        .listen((subCatg) {
          catgs.add(subCatg);
        })
        .asFuture()
        .then((value) => catgs);
  }

  static Stream<StaticsModel> streamOf(String collectionName) {
    return SystemMDBService.db.collection(collectionName).find().transform(
      StreamTransformer.fromHandlers(
        handleData: (data, sink) {
          sink.add(StaticsModel.fromMap(data));
        },
      ),
    );
  }

  static Stream<StaticsModel> stream() {
    return SystemMDBService.db.collection(collectionName).find().transform(
      StreamTransformer.fromHandlers(
        handleData: (data, sink) {
          sink.add(StaticsModel.fromMap(data));
        },
      ),
    );
  }

  Future<StaticsModel?> aggregate(List<dynamic> pipeline) async {
    var d = await SystemMDBService.db
        .collection(collectionName)
        .aggregate(pipeline);

    return StaticsModel.fromMap(d);
  }

  static Future<StaticsModel?> get(dynamic id) async {
    var d = await SystemMDBService.db
        .collection(collectionName)
        .findOne(where.eq('id', id));
    if (d == null) {
      return null;
    }
    return StaticsModel.fromMap(d);
  }

  Future<StaticsModel?> edit() async {
    var r = await SystemMDBService.db.collection(collectionName).update(
          where.eq('id', id),
          toMap(),
        );
    print(r);
    return this;
  }

  Future<int> delete([int? id]) async {
    var r = await SystemMDBService.db.collection(collectionName).remove(
          where.eq('id', id ?? id),
        );
    print(r);
    return 1;
  }

  static Future<int> deleteOf(String collectionName) async {
    var r = await SystemMDBService.db.collection(collectionName).drop();
    print(r);
    return 1;
  }

  Future<StaticsModel> add() async {
    var r = await SystemMDBService.db.collection(collectionName).insert(
          toMap(),
        );
    print(r);
    return this;
  }

  Future<StaticsModel> addTo(String collectionName) async {
    var r = await SystemMDBService.db.collection(collectionName).insert(
          toMap(),
        );
    print(r);
    return this;
  }

  static Future<int> requestIdFor(fieldKey) async {
    StaticsModel? model = await get(0);
    if (model == null) {
      var newModel = StaticsModel(0, meta: {});
      newModel.meta[fieldKey] = 0;
      await newModel.add();
      return newModel.meta[fieldKey];
    } else {
      if (model.meta[fieldKey] == null) {
        model.meta[fieldKey] = 0;
      }
      model.meta[fieldKey] += 1;
      await model.edit();
      print(model.meta);
      return model.meta[fieldKey];
    }
  }
}
