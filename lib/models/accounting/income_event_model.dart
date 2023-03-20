import 'dart:async';
import 'dart:convert';

import 'package:mongo_dart/mongo_dart.dart';

import '../../utils/system_db.dart';
import 'money_account.dart';
import 'payment_method_model.dart';

enum IncomeType {
  costumerPostpay,
  // costumerDebit,
}

class IncomeEventModel {
  IncomeEventModel({
    required this.datetime,
    required this.enteries,
    required this.account,
    required this.total,
    required this.from,
    required this.id,
  }) {
    // id = '$billCreateTime-${sku.id}-$expierDate';
    // id = '${dateTimeToString(DateTime.now())}-${sku.id}-$expierDate';
    // createDate = DateTime.now();
  }

  String id;
  late DateTime datetime;
  late double total;
  late List<PaymentEntryModel> enteries = [];
  // late DateTime billCreateTime;
  late MoneyAccount account;
  late dynamic from;
  late IncomeType type;

  static IncomeEventModel fromMap(Map<String, dynamic> data) {
    // print('================');
    // print(data);
    IncomeEventModel model = IncomeEventModel(
      account: MoneyAccount.fromMap(data['account']),
      from: data['from'],
      datetime: data['datetime'],
      enteries: (data['enteries'])
          .map<PaymentEntryModel>(
            (element) => PaymentEntryModel.fromMap(element),
          )
          .toList(),
      total: data['total'],
      id: data['id'],
    );
    // model.createDate =
    //     data['createDate'] ?? DateTime.now(); // Fix just for debuging
    return model;
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'account': account.toMap(),
        'from': from,
        'datetime': datetime,
        'enteries': enteries
            .map<Map<String, dynamic>>(
              (method) => method.toMap(),
            )
            .toList(),
        'total': total,
      };

  String toJson() => json.encode(toMap());

  static IncomeEventModel fromJson(String jsn) {
    return fromMap(json.decode(jsn));
  }

  static Future<List<IncomeEventModel>> getAll() {
    List<IncomeEventModel> catgs = [];
    return SystemMDBService.db
        .collection('incomeEvents')
        .find()
        .transform<IncomeEventModel>(
          StreamTransformer.fromHandlers(
            handleData: (data, sink) {
              sink.add(IncomeEventModel.fromMap(data));
            },
          ),
        )
        .listen((subCatg) {
          catgs.add(subCatg);
        })
        .asFuture()
        .then((value) => catgs);
  }

  static Stream<IncomeEventModel> stream() {
    return SystemMDBService.db.collection('incomeEvents').find().transform(
      StreamTransformer.fromHandlers(
        handleData: (data, sink) {
          sink.add(IncomeEventModel.fromMap(data));
        },
      ),
    );
  }

  Future<IncomeEventModel?> aggregate(List<dynamic> pipeline) async {
    var d = await SystemMDBService.db.collection('incomeEvents').aggregate(pipeline);

    return IncomeEventModel.fromMap(d);
  }

  static Future<IncomeEventModel?> get(String id) async {
    var d = await SystemMDBService.db
        .collection('incomeEvents')
        .findOne(where.eq('id', id));
    if (d == null) {
      return null;
    }
    return IncomeEventModel.fromMap(d);
  }

  static Future<IncomeEventModel?> findByLevelNumber(int levelNumber) async {
    var d = await SystemMDBService.db
        .collection('incomeEvents')
        .findOne(where.eq('levelNumber', levelNumber));
    if (d == null) {
      return null;
    }
    return IncomeEventModel.fromMap(d);
  }

  Future<IncomeEventModel?> edit() async {
    await SystemMDBService.db.collection('incomeEvents').update(
          where.eq('id', id),
          toMap(),
        );
    return this;
  }

  Future<int> delete(String id) async {
    await SystemMDBService.db.collection('incomeEvents').remove(
          where.eq('id', id),
        );
    return 1;
  }

  Future<IncomeEventModel> add() async {
    await SystemMDBService.db.collection('incomeEvents').insert(
          toMap(),
        );
    return this;
  }
}

class PaymentEntryModel {
  PaymentEntryModel(
    this.id, {
    required this.value,
    required this.paymentMethod,
  });

  int id;
  PaymentMethodModel paymentMethod;
  double value;

  Map<String, dynamic> toMap() => {
        'id': id,
        'paymentMethod': paymentMethod.toMap(),
        'value': value,
      };

  static PaymentEntryModel fromMap(Map<String, dynamic> data) {
    return PaymentEntryModel(
      data['id'],
      paymentMethod: PaymentMethodModel.fromMap(data['paymentMethod']),
      value: data['value'],
    );
  }
}
