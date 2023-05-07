import 'dart:async';
import 'dart:convert';

import 'package:mongo_dart/mongo_dart.dart';

import '../../utils/enums.dart';
import '../../utils/system_db.dart';
import 'money_account.dart';



class TransactionModel {
  TransactionModel(
    this.id, {
    required this.value,
    required this.statement,
    required this.account,
    required this.type,
  });

  TransactionModel._();

  static const String collectionName = 'transactions'; 

  late int id;
  late double value;
  late String statement;
  late MoneyAccount account;
  late TransactionType type;

  static TransactionModel fromMap(Map<String, dynamic> data) {
    TransactionModel model = TransactionModel._();
    model.id = data['id'];
    model.value = data['value'];
    model.statement = data['statement'];
    model.account = MoneyAccount.fromMap(data['account']);
    model.type = transTypeFromString(data['type']);
    return model;
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'value': value,
        'statement': statement,
        'account': account.toMap(),
        'type': type.toString(),
      };

  String toJson() => json.encode(toMap());

  static TransactionModel fromJson(String jsn) {
    return fromMap(json.decode(jsn));
  }

  static Future<List<TransactionModel>> getAll() {
    List<TransactionModel> models = [];
    return SystemMDBService.db
        .collection(collectionName)
        .find()
        .transform<TransactionModel>(
          StreamTransformer.fromHandlers(
            handleData: (data, sink) {
              sink.add(TransactionModel.fromMap(data));
            },
          ),
        )
        .listen((model) {
          models.add(model);
        })
        .asFuture()
        .then((value) => models);
  }

  static Stream<TransactionModel>? stream() {
    return SystemMDBService.db.collection(collectionName).find().transform(
      StreamTransformer.fromHandlers(
        handleData: (data, sink) {
          sink.add(TransactionModel.fromMap(data));
        },
      ),
    );
  }

  Future<TransactionModel?> aggregate(List<dynamic> pipeline) async {
    var d =
        await SystemMDBService.db.collection(collectionName).aggregate(pipeline);

    return TransactionModel.fromMap(d);
  }

  Future<TransactionModel?> get(int id) async {
    var d = await SystemMDBService.db
        .collection(collectionName)
        .findOne(where.eq('id', id));
    if (d == null) {
      return null;
    }
    return TransactionModel.fromMap(d);
  }

  static Future<TransactionModel?> findById(int id) async {
    var d = await SystemMDBService.db
        .collection(collectionName)
        .findOne(where.eq('id', id));
    if (d == null) {
      return null;
    }
    return TransactionModel.fromMap(d);
  }

  Future<TransactionModel?> edit() async {
    await SystemMDBService.db.collection(collectionName).update(
          where.eq('id', id),
          toMap(),
        );

    return this;
  }

  Future<int> delete() async {
    await SystemMDBService.db.collection(collectionName).remove(
          where.eq('id', id),
        );

    return 1;
  }

  Future<int> add() async {
    await SystemMDBService.db.collection(collectionName).insert(
          toMap(),
        );

    return 1;
  }
}
