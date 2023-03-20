import 'dart:async';
import 'dart:convert';

import 'package:mongo_dart/mongo_dart.dart';

import '../../utils/system_db.dart';
import '../quality_control/action_model.dart';

class TreeMainAccountModel {
  TreeMainAccountModel._();

  TreeMainAccountModel(
    this.id, {
    required this.description,
  });

  late int id;
  late dynamic mid; // Mongo document id
  late String description;

  static const String collectionName = 'treeMainAccounts';

  static TreeMainAccountModel fromMap(Map<String, dynamic> data) {
    TreeMainAccountModel model = TreeMainAccountModel._();
    model.id = data['id'];
    model.description = data['description'];
    model.mid = data['_id'];

    return model;
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'description': description,
      };

  String toJson() => json.encode(toMap());

  static TreeMainAccountModel fromJson(String jsn) {
    return fromMap(json.decode(jsn));
  }

  static Future<List<TreeMainAccountModel>> getAll() {
    List<TreeMainAccountModel> catgs = [];
    return SystemMDBService.db
        .collection(collectionName)
        .find()
        .transform<TreeMainAccountModel>(
          StreamTransformer.fromHandlers(
            handleData: (data, sink) {
              sink.add(TreeMainAccountModel.fromMap(data));
            },
          ),
        )
        .listen((subCatg) {
          catgs.add(subCatg);
        })
        .asFuture()
        .then((value) => catgs);
  }

  static Stream<TreeMainAccountModel> stream() {
    return SystemMDBService.db.collection(collectionName).find().transform(
      StreamTransformer.fromHandlers(
        handleData: (data, sink) {
          sink.add(TreeMainAccountModel.fromMap(data));
        },
      ),
    );
  }

  Future<TreeMainAccountModel?> aggregate(List<dynamic> pipeline) async {
    var d = await SystemMDBService.db
        .collection(collectionName)
        .aggregate(pipeline);

    return TreeMainAccountModel.fromMap(d);
  }

  static Future<TreeMainAccountModel?> get(int id) async {
    var d = await SystemMDBService.db
        .collection(collectionName)
        .findOne(where.eq('id', id));
    if (d == null) {
      return null;
    }
    return TreeMainAccountModel.fromMap(d);
  }

  static Future<TreeMainAccountModel?> findById(int id) async {
    var d = await SystemMDBService.db
        .collection(collectionName)
        .findOne(where.eq('id', id));
    if (d == null) {
      return null;
    }
    return TreeMainAccountModel.fromMap(d);
  }

  static Future<TreeMainAccountModel?> findBydescription(String description) async {
    var d = await SystemMDBService.db
        .collection(collectionName)
        .findOne(where.eq('description', description));
    if (d == null) {
      return null;
    }
    return TreeMainAccountModel.fromMap(d);
  }

  Future<TreeMainAccountModel> edit([bool fromSyncService = false]) async =>
      await editToCol(collectionName, fromSyncService);

  Future<TreeMainAccountModel> editToCol(String collName,
      [bool fromSyncService = false]) async {
    var r = await SystemMDBService.db.collection(collName).update(
          where.eq('id', id),
          toMap(),
        );
    if (!fromSyncService) {
      await ActionModel.updatedTreeMainAccount(this, collName);
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
      await ActionModel.deletedTreeMainAccount(this, collName);
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
      await ActionModel.createdTreeMainAccount(this, collName);
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
      await ActionModel.deletedTreeMainAccount(this, collectionName);
      print(r);
    }
    return 1;
  }
}