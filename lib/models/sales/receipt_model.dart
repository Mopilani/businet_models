import 'dart:async';
import 'dart:convert';

import 'package:mongo_dart/mongo_dart.dart';

import '../../utils/system_db.dart';
import '../costumer_model.dart';
import '../hr/user_model.dart';
import '../patchs.dart';
import '../quality_control/action_model.dart';
import '../system_node_model.dart';
import 'delivery_model.dart';
import 'receipt_entry_model.dart';
import 'receipt_payment_method_entry_model.dart';
import 'stock_model.dart';

class ReceiptModel {
  ReceiptModel(
    this.id, {
    this.note,
    required this.total,
    required this.payed,
    required this.wanted,
    required this.realPayed,
    required this.debitWanted,
    required this.userModel,
    required this.createDate,
    this.expierDate,
    this.returnDate,
    this.cancelDate,
    required this.stockModel,
    required this.costumer,
    this.deliveryModel,
    required this.systemNodeModel,
    required this.shiftNumber,
    // required this.paymentMethodModel,
    required this.receiptState,
    required this.receiptEntries,
    required this.receiptPaymentMethods,
  });

  static const String collectionName = 'rcpts';
  static const String backedCollectionName = 'rcpts-backup';
  static const String suspendedCollectionName = 'rcpts-suspended';

  late int id;
  String? note;
  double total;
  double payed;
  double wanted;
  double realPayed;
  double debitWanted;
  late int shiftNumber;
  late UserModel userModel;
  CostumerModel? costumer;
  late DateTime createDate;
  late DateTime? expierDate;
  late DateTime? returnDate;
  late DateTime? cancelDate;
  late StockModel stockModel;
  late DeliveryModel? deliveryModel;
  late SystemNodeModel systemNodeModel;
  // PaymentMethodModel paymentMethodModel;
  ReceiptState receiptState = ReceiptState.onWait;
  late Map<String, ReceiptEntryModel> receiptEntries;
  late List<ReceiptPaymentMethodEntryModel> receiptPaymentMethods;

  static ReceiptModel fromMap(Map<String, dynamic> data) {
    var bill = ReceiptModel(
      data['id'],
      note: data['note'],
      total: data['total'],
      payed: data['payed'],
      wanted: data['wanted'],
      realPayed: data['realPayed'] ?? 0.0,
      debitWanted: data['debitWanted'] ?? 0.0,
      createDate: stringOrDateTime(data['createDate'])!,
      expierDate: stringOrDateTime(data['expierDate']),
      returnDate: stringOrDateTime(data['returnDate']),
      cancelDate: stringOrDateTime(data['cancelDate']),
      shiftNumber: data['shiftNumber'],
      costumer: data['costumer'] == null
          ? null
          : CostumerModel.fromMap(data['costumer']),
      userModel: UserModel.fromMap(data['userModel']),
      stockModel: StockModel.fromMap(data['stockModel']),
      deliveryModel: data['deliveryModel'] == null
          ? null
          : DeliveryModel.fromMap(data['deliveryModel']),
      systemNodeModel: SystemNodeModel.fromMap(data['systemNodeModel']),
      // paymentMethodModel:
      //     PaymentMethodModel.fromMap(data['paymentMethodModel']),
      receiptPaymentMethods: (data['receiptPaymentMethods'])
          .map<ReceiptPaymentMethodEntryModel>(
            (element) => ReceiptPaymentMethodEntryModel.fromMap(element),
          )
          .toList(),
      receiptEntries: (data['receiptEntries']).map<String, ReceiptEntryModel>(
        (key, value) => MapEntry<String, ReceiptEntryModel>(
          key,
          ReceiptEntryModel.fromMap(value),
        ),
      ),
      receiptState: getReceiptState(data['receiptState'])!,
    );
    return bill;
  }

  Map<String, dynamic> toMap() {
    var userData = userModel.toMap();
    userData['accessLevelModel'] = null;
    var stockData = stockModel.toMap();
    Map<String, Map<String, dynamic>> receiptEntries0 =
        receiptEntries.map<String, Map<String, dynamic>>(
      (key, value) => MapEntry<String, Map<String, dynamic>>(
        key,
        value.toMap(),
      ),
    );
    return {
      'id': id,
      'note': note,
      'total': total,
      'payed': payed,
      'wanted': wanted,
      'costumer': costumer?.toMap(),
      'realPayed': realPayed,
      'debitWanted': debitWanted,
      'createDate': createDate,
      'shiftNumber': shiftNumber,
      'expierDate': expierDate,
      'returnDate': returnDate,
      'cancelDate': cancelDate,
      'userModel': userData,
      'stockModel': stockData,
      'deliveryModel': deliveryModel?.toMap(),
      'systemNodeModel': systemNodeModel.toMap(),
      // 'paymentMethodModel': paymentMethodModel.toMap(),
      // 'sdsd': {23: ''},
      'receiptPaymentMethods': receiptPaymentMethods
          .map<Map<String, dynamic>>(
            (method) => method.toMap(),
          )
          .toList(),
      'receiptEntries': receiptEntries0,
      'receiptState': receiptState.toString(),
    };
  }

  String toJson() {
    Object? toEncodable(dynamic object) {
      if (object is DateTime) {
        return object.toString();
      }
      return object;
    }

    return json.encode(toMap(), toEncodable: toEncodable);
  }

  static ReceiptModel fromJson(String jsn) {
    return fromMap(json.decode(jsn));
  }

  static Future<List<ReceiptModel>> getAll() async {
    List<ReceiptModel> result = [];
    return SystemMDBService.db
        .collection(collectionName)
        .find()
        .transform<ReceiptModel>(
          StreamTransformer.fromHandlers(
            handleData: (data, sink) {
              sink.add(ReceiptModel.fromMap(data));
            },
          ),
        )
        .listen((saleUnit) {
          result.add(saleUnit);
        })
        .asFuture()
        .then((value) => result);
  }

  static Stream<ReceiptModel> stream() {
    return SystemMDBService.db.collection(collectionName).find().transform(
          StreamTransformer.fromHandlers(
            handleData: (data, sink) {
              sink.add(ReceiptModel.fromMap(data));
            },
            handleDone: (sink) {
              sink.close();
            },
          ),
        );
  }

  // Streams the backed-up receitps
  static Stream<ReceiptModel> streamBacked() {
    return SystemMDBService.db.collection(backedCollectionName).find().transform(
          StreamTransformer.fromHandlers(
            handleData: (data, sink) {
              sink.add(ReceiptModel.fromMap(data));
            },
            handleDone: (sink) {
              sink.close();
            },
          ),
        );
  }

  Future<ReceiptModel?> aggregate(List<dynamic> pipeline) async {
    var d = await SystemMDBService.db.collection(collectionName).aggregate(pipeline);

    return ReceiptModel.fromMap(d);
  }

  static Future<ReceiptModel?> get(int id, [bool multiFind = true]) async {
    var value = await SystemMDBService.db
        .collection(collectionName)
        .findOne(where.eq('id', id));
    if (value == null) {
      if (multiFind) {
        value = await SystemMDBService.db
            .collection(backedCollectionName)
            .findOne(where.eq('id', id));
        if (value == null) {
          return null;
        }
      } else {
        return null;
      }
    }
    // print('multiFind ${ReceiptModel.fromMap(value).receiptEntries}');

    return ReceiptModel.fromMap(value);
  }

  static Future<ReceiptModel?> getSuspendedReceipt(int id,
      [bool multiFind = true]) async {
    var value = await SystemMDBService.db
        .collection(suspendedCollectionName)
        .findOne(where.eq('id', id));
    if (value == null) return null;

    await SystemMDBService.db.collection(suspendedCollectionName).remove(
          where.eq('id', id),
        );

    return ReceiptModel.fromMap(value);
  }

  Future<ReceiptModel?> findByName(String name) async {
    var d = await SystemMDBService.db
        .collection(collectionName)
        .findOne(where.eq('id', id));
    if (d == null) {
      return null;
    }
    return ReceiptModel.fromMap(d);
  }

  Future<ReceiptModel> edit([
    Map<String, ReceiptEntryModel>? oldReceiptEntries,
    receiptModelView,
  ]) async {
    var r = await SystemMDBService.db.collection(collectionName).update(
          where.eq('id', id),
          toMap(),
        );
    try {
      await receiptModelView(this);
    } catch (e) {
      //
    }

    if (oldReceiptEntries != null) {
      for (var entry in oldReceiptEntries.entries) {
        var sku = entry.value.skuModel;
        sku.quantity += entry.value.quantity;
        print('+++++++++');
        await sku.edit();
      }
    }
    for (var entry in receiptEntries.entries) {
      var sku = entry.value.skuModel;
      sku.quantity -= entry.value.quantity;
      await sku.edit();
    }
    await ActionModel.updatedReceipt(this, id);
    print(r);
    return this;
  }

  // Future<int> delete(String id) async {
  //   var r = await SystemMDBService.db.collection(collectionName).remove(
  //         where.eq('id', id),
  //       );
  //   // await ActionModel.(id);
  //   print(r);
  //   return 1;
  // }

  Future<ReceiptModel> add(
      [receiptModelView, businetBackendSVCConnector]) async {
    // print('///////////////////////////// $receiptEntries');

    businetBackendSVCConnector.receipt(this).then((res) {
      print(res?.body);
    }); // Backend SVC

    var r = await SystemMDBService.db.collection(collectionName).insert(
          toMap(),
        );

    for (var entry in receiptEntries.entries) {
      var sku = entry.value.skuModel;
      sku.quantity -= entry.value.quantity;
      await sku.edit();
    }

    if (costumer != null) {
      await costumer!.recordReceipt(this);
    }

    try {
      receiptModelView(this).asStream();
    } catch (e, s) {
      print(e);
      print(s);
    }

    await ActionModel.createReceipt(this, id);
    print(r);
    return this;
  }

  static Future<void> _addToBackup(ReceiptModel receiptModel) async {
    var r = await SystemMDBService.db.collection(backedCollectionName).insert(
          receiptModel.toMap(),
        );
    print(r);
  }

  static Future<void> suspend(ReceiptModel receiptModel) async {
    var r = await SystemMDBService.db.collection(suspendedCollectionName).insert(
          receiptModel.toMap(),
        );
    print(r);
  }

  static StreamSubscription backupAndReset() {
    var receiptsStream = stream();
    StreamSubscription subscription;
    dynamic error;
    subscription = receiptsStream
        .transform<ReceiptModel>(
            StreamTransformer.fromHandlers(handleDone: (sink) async {
      sink.close();
      if (error == null) {
        await SystemMDBService.db.collection(collectionName).drop();
        await SystemMDBService.db.createCollection(collectionName);
      }
    }, handleError: (e, s, sink) {
      error = e;
    }))
        .listen(
      (model) async {
        await _addToBackup(model);
      },
      onDone: () async {
        print('Done, Dropping And Createing..');
      },
    );
    return subscription;
  }

  static Stream<ReceiptModel> collectOfTime(
    DateTime from,
    DateTime to, [
    bool withTime = false,
  ]) {
    var modelssStream = stream();
    var musfaStream = modelssStream.transform<ReceiptModel>(
        StreamTransformer.fromHandlers(handleData: (model, sink) {
      int r1;
      int r2;
      if (withTime) {
        r1 = model.createDate.compareTo(from);
        r2 = model.createDate.compareTo(to);
      } else {
        DateTime createDate = DateTime(
          model.createDate.year,
          model.createDate.month,
          model.createDate.day,
        );
        r1 = createDate.compareTo(DateTime(
          from.year,
          from.month,
          from.day,
        ));
        r2 = createDate.compareTo(DateTime(
          to.year,
          to.month,
          to.day,
        ));
      }
      // print('${model.createDate} ${r1} && ${r2}');
      if ((r1 == 1 && r2 == -1) || (r1 == 0 && r2 == 0)) {
        sink.add(model);
      } else if (r1 == 0 && r2 == -1) {
        sink.add(model);
      } else if (r2 == 0 && r1 == 1) {
        sink.add(model);
      }
    }));
    return musfaStream;
  }

  static Stream<ReceiptModel> collectOfTimeStreamBacked(
    DateTime from,
    DateTime to, [
    bool withTime = false,
  ]) {
    var modelssStream = streamBacked();
    var musfaStream = modelssStream.transform<ReceiptModel>(
        StreamTransformer.fromHandlers(handleData: (model, sink) {
      // var r1 = model.createDate.compareTo(from);
      // var r2 = model.createDate.compareTo(to);
      // print('${model.createDate} ${r1 == 1} && ${r2 == 1}');
      // print('${model.createDate} ${r1} && ${r2}');
      // if (!(r1 == 1 && r2 == -1)) {
      //   return;
      // }
      int r1;
      int r2;
      if (withTime) {
        r1 = model.createDate.compareTo(from);
        r2 = model.createDate.compareTo(to);
      } else {
        DateTime createDate = DateTime(
          model.createDate.year,
          model.createDate.month,
          model.createDate.day,
        );
        r1 = createDate.compareTo(DateTime(
          from.year,
          from.month,
          from.day,
        ));
        r2 = createDate.compareTo(DateTime(
          to.year,
          to.month,
          to.day,
        ));
      }
      if ((r1 == 1 && r2 == -1) || (r1 == 0 && r2 == 0)) {
        sink.add(model);
      } else if (r1 == 0 && r2 == -1) {
        sink.add(model);
      } else if (r2 == 0 && r1 == 1) {
        sink.add(model);
      }
      sink.add(model);
    }));
    return musfaStream;
  }
}

enum ReceiptState {
  payed,
  onWait,
  returned,
  canceled,
  partialPay,
}

Map<dynamic, String> receiptStatesTranslations = {
  ReceiptState.canceled: 'ملغية',
  ReceiptState.onWait: 'في الانتظار',
  ReceiptState.partialPay: 'مدفوعة جزئيا',
  ReceiptState.payed: 'مدفوعة',
  ReceiptState.returned: 'راجعة',
  'BillState.canceled': 'ملغية',
  'BillState.onWait': 'في الانتظار',
  'BillState.partialPay': 'مدفوعة جزئيا',
  'BillState.payed': 'مدفوعة',
  'BillState.returned': 'راجعة',
};

ReceiptState? getReceiptState(String state) {
  for (var billState in ReceiptState.values) {
    if (billState.toString() == state) {
      return billState;
    }
  }
  return null;
}
