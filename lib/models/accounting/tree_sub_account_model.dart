import 'dart:async';
import 'dart:convert';

import 'package:mongo_dart/mongo_dart.dart';

import '../../utils/system_db.dart';
import '../quality_control/action_model.dart';
import 'tree_main_account_model.dart';

class TreeSubAccountModel {
  TreeSubAccountModel._();

  TreeSubAccountModel(
    this.id, {
    required this.description,
    required this.mainAccount,
    this.value = 0.0,
  });

  late int id;
  late dynamic mid; // Mongo document id
  late String description;
  late double value;
  late TreeMainAccountModel mainAccount;

  static const String collectionName = 'treeSubAccounts';

  static TreeSubAccountModel fromMap(Map<String, dynamic> data) {
    TreeSubAccountModel model = TreeSubAccountModel._();
    model.id = data['id'];
    model.description = data['description'];
    model.value = data['value'] ?? 0.0;
    model.mainAccount = TreeMainAccountModel.fromMap(data['mainAccount']);
    model.mid = data['_id'];

    return model;
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'description': description,
        'value': value,
        'mainAccount': mainAccount.toMap(),
      };

  String toJson() => json.encode(toMap());

  static TreeSubAccountModel fromJson(String jsn) {
    return fromMap(json.decode(jsn));
  }

  static Future<List<TreeSubAccountModel>> getAll() {
    List<TreeSubAccountModel> catgs = [];
    return SystemMDBService.db
        .collection(collectionName)
        .find()
        .transform<TreeSubAccountModel>(
          StreamTransformer.fromHandlers(
            handleData: (data, sink) {
              sink.add(TreeSubAccountModel.fromMap(data));
            },
          ),
        )
        .listen((subCatg) {
          catgs.add(subCatg);
        })
        .asFuture()
        .then((value) => catgs);
  }

  static Stream<TreeSubAccountModel> stream() {
    return SystemMDBService.db.collection(collectionName).find().transform(
      StreamTransformer.fromHandlers(
        handleData: (data, sink) {
          sink.add(TreeSubAccountModel.fromMap(data));
        },
      ),
    );
  }

  Future<TreeSubAccountModel?> aggregate(List<dynamic> pipeline) async {
    var d = await SystemMDBService.db
        .collection(collectionName)
        .aggregate(pipeline);

    return TreeSubAccountModel.fromMap(d);
  }

  static Future<TreeSubAccountModel?> get(int id) async {
    var d = await SystemMDBService.db
        .collection(collectionName)
        .findOne(where.eq('id', id));
    if (d == null) {
      return null;
    }
    return TreeSubAccountModel.fromMap(d);
  }

  static Future<TreeSubAccountModel?> findById(int id) async {
    var d = await SystemMDBService.db
        .collection(collectionName)
        .findOne(where.eq('id', id));
    if (d == null) {
      return null;
    }
    return TreeSubAccountModel.fromMap(d);
  }

  static Future<TreeSubAccountModel?> findBydescription(String description) async {
    var d = await SystemMDBService.db
        .collection(collectionName)
        .findOne(where.eq('description', description));
    if (d == null) {
      return null;
    }
    return TreeSubAccountModel.fromMap(d);
  }

  Future<TreeSubAccountModel> edit([bool fromSyncService = false]) async =>
      await editToCol(collectionName, fromSyncService);

  Future<TreeSubAccountModel> editToCol(String collName,
      [bool fromSyncService = false]) async {
    var r = await SystemMDBService.db.collection(collName).update(
          where.eq('id', id),
          toMap(),
        );
    if (!fromSyncService) {
      await ActionModel.updatedTreeSubAccount(this, collName);
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
      await ActionModel.deletedTreeSubAccount(this, collName);
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
      await ActionModel.createdTreeSubAccount(this, collName);
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
      await ActionModel.deletedTreeSubAccount(this, collectionName);
      print(r);
    }
    return 1;
  }
}