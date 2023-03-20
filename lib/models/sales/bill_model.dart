import 'dart:async';
import 'dart:convert';

import 'package:mongo_dart/mongo_dart.dart';

import '../../utils/enums.dart';
import '../../utils/system_db.dart';
import '../hr/user_model.dart';
import '../quality_control/action_model.dart';
import '../system_node_model.dart';
import 'delivery_model.dart';
import 'sale_unit_model.dart';
import 'sku_model.dart';
import 'stock_model.dart';
import 'supplier_model.dart';
import 'receipt_payment_method_entry_model.dart';

class BillEntryModel {
  BillEntryModel({
    required this.skuModel,
    required this.quantity,
    required this.total,
    required this.tax,
    required this.note,
    required this.freeQuantity,
    required this.disc,
    required this.deliveryPrice,
    required this.saleunit,
    required this.containSize,
    required this.expierDate,
  });

  SKUModel skuModel;
  double deliveryPrice;
  double quantity;
  double total;
  double freeQuantity;
  double disc;
  String expierDate;
  SaleUnitModel saleunit;
  double tax;
  double? containSize;
  String note;

  Map<String, dynamic> toMap() => {
        'skuModel': skuModel.toMap(),
        'quantity': quantity,
        'total': total,
        'tax': tax,
        'freeQuantity': freeQuantity,
        'deliveryPrice': deliveryPrice,
        'disc': disc,
        'note': note,
        'expierDate': expierDate,
        'saleunit': saleunit.toMap(),
        'containSize': containSize,
      };

  static BillEntryModel fromMap(Map<String, dynamic> data) {
    return BillEntryModel(
      skuModel: SKUModel.fromMap(data['skuModel']),
      quantity: data['quantity'],
      total: data['total'],
      tax: data['tax'],
      note: data['note'],
      disc: data['disc'],
      expierDate: data['expierDate'],
      freeQuantity: data['freeQuantity'],
      deliveryPrice: data['deliveryPrice'],
      saleunit: SaleUnitModel.fromMap(data['saleunit']),
      containSize: data['containSize'],
    );
  }
}

class BillModel {
  BillModel(
    this.id, {
    this.note,
    required this.billType,
    required this.total,
    required this.payed,
    required this.wanted,
    required this.quantity,
    required this.userModel,
    required this.createDate,
    required this.incomingDate,
    this.expierDate,
    this.returnDate,
    this.cancelDate,
    this.wasImported,
    this.deliveryModel,
    required this.stockModel,
    required this.systemNodeModel,
    required this.billState,
    required this.supplierModel,
    required this.billEntries,
    required this.billPaymentMethods,
  });

  late int id;
  String? note;
  BillType? billType;
  double total;
  double payed;
  double wanted;
  double quantity;
  late UserModel userModel;
  late DateTime createDate;
  late DateTime incomingDate;
  late DateTime? expierDate;
  late DateTime? returnDate;
  late DateTime? cancelDate;
  late StockModel stockModel;
  late DeliveryModel? deliveryModel;
  late bool? wasImported;
  late SystemNodeModel systemNodeModel;
  BillState billState = BillState.onWait;
  late Map<String, BillEntryModel> billEntries;
  late List<BillPaymentMethodEntryModel> billPaymentMethods;
  late SupplierModel supplierModel;

  static BillModel fromMap(Map<String, dynamic> data) {
    // SystemMDBService.db.collection('bills').drop();
    var bill = BillModel(
      data['id'],
      note: data['note'],
      billType: getNativeType(data['billType']),
      total: data['total'],
      payed: data['payed'],
      quantity: data['quantity'],
      wanted: data['wanted'],
      createDate: data['createDate'],
      expierDate: data['expierDate'],
      incomingDate: data['incomingDate'],
      returnDate: data['returnDate'],
      cancelDate: data['cancelDate'],
      wasImported: data['wasImported'],
      userModel: UserModel.fromMap(data['userModel']),
      stockModel: StockModel.fromMap(data['stockModel']),
      deliveryModel: data['deliveryModel'] == null
          ? null
          : DeliveryModel.fromMap(data['deliveryModel']),
      systemNodeModel: SystemNodeModel.fromMap(data['systemNodeModel']),
      billPaymentMethods: (data['billPaymentMethods'])
          .map<BillPaymentMethodEntryModel>(
            (element) => BillPaymentMethodEntryModel.fromMap(element),
          )
          .toList(),
      billEntries: (data['billEntries']).map<String, BillEntryModel>(
        (key, value) => MapEntry<String, BillEntryModel>(
          key,
          BillEntryModel.fromMap(value),
        ),
      ),
      billState: getBillState(data['billState'])!,
      supplierModel: SupplierModel.fromMap(data['supplierModel']),
    );
    return bill;
  }

  Map<String, dynamic> toMap() {
    var userData = userModel.toMap();
    userData['accessLevelModel'] = null;
    var stockData = stockModel.toMap();
    Map<String, Map<String, dynamic>> billEntries0 =
        billEntries.map<String, Map<String, dynamic>>(
      (key, value) => MapEntry<String, Map<String, dynamic>>(
        key,
        value.toMap(),
      ),
    );
    return {
      'id': id,
      'note': note,
      'billType': billType.toString(),
      'total': total,
      'payed': payed,
      'wanted': wanted,
      'quantity': quantity,
      'createDate': createDate,
      'expierDate': expierDate,
      'incomingDate': incomingDate,
      'returnDate': returnDate,
      'cancelDate': cancelDate,
      'wasImported': wasImported,
      'userModel': userData,
      'stockModel': stockData,
      'deliveryModel': deliveryModel?.toMap(),
      'systemNodeModel': systemNodeModel.toMap(),
      'billPaymentMethods': billPaymentMethods
          .map<Map<String, dynamic>>(
            (method) => method.toMap(),
          )
          .toList(),
      'billEntries': billEntries0,
      'supplierModel': supplierModel.toMap(),
      'billState': billState.toString(),
    };
  }

  String toJson() => json.encode(toMap());

  static BillModel fromJson(String jsn) {
    return fromMap(json.decode(jsn));
  }

  static Future<List<BillModel>> getAll() async {
    List<BillModel> result = [];
    return SystemMDBService.db
        .collection('bills')
        .find()
        .transform<BillModel>(
          StreamTransformer.fromHandlers(
            handleData: (data, sink) {
              sink.add(BillModel.fromMap(data));
            },
          ),
        )
        .listen((saleUnit) {
          result.add(saleUnit);
        })
        .asFuture()
        .then((value) => result);
  }

  static Stream<BillModel> stream() {
    return SystemMDBService.db.collection('bills').find().transform(
          StreamTransformer.fromHandlers(
            handleData: (data, sink) {
              sink.add(BillModel.fromMap(data));
            },
            handleDone: (sink) {
              sink.close();
            },
          ),
        );
  }

  Future<BillModel?> aggregate(List<dynamic> pipeline) async {
    var d = await SystemMDBService.db.collection('bills').aggregate(pipeline);

    return BillModel.fromMap(d);
  }

  static Future<BillModel?> get(int id, [billType]) async {
    var d = await SystemMDBService.db.collection('bills').findOne(
          billType != null
              ? where.eq('id', id).eq(
                    'billType',
                    billType.toString(),
                  )
              : where.eq('id', id),
        );
    if (d == null) {
      return null;
    }
    return BillModel.fromMap(d);
  }

  Future<BillModel?> findByName(String name) async {
    var d = await SystemMDBService.db
        .collection('bills')
        .findOne(where.eq('id', id));
    if (d == null) {
      return null;
    }
    return BillModel.fromMap(d);
  }

  Future<BillModel> edit([Map<String, BillEntryModel>? newBillEntries]) async {
    var r = await SystemMDBService.db.collection('bills').update(
          where.eq('id', id).eq('billType', billType.toString()),
          toMap(),
        );

    // if (newBillEntries != null) {
    //   var expectedBill = await get(id);
    //   if (expectedBill != null && expectedBill.billType == billType) {
    //     expectedBill.billEntries = newBillEntries;
    //     await SystemMDBService.db.collection('bills').insert(
    //           expectedBill.toMap(),
    //         );
    //   }
    // }
    await ActionModel.updatedBill(this, id);
    print(r);
    return this;
  }

  Future<BillModel> add() async {
    // for (var entry in billEntries.entries) {
    //   var sku = entry.value.skuModel;
    //   sku.quantity -= entry.value.quantity;
    //   await sku.edit();
    // }
    // var expectedBill = await get(id);
    // if (expectedBill != null && expectedBill.billType == billType) {}
    var r = await SystemMDBService.db.collection('bills').insert(
          toMap(),
        );
    await ActionModel.createdBill(this, id);
    print(r);
    return this;
  }

  static Stream<BillModel> collectOfTime(DateTime from, DateTime to) {
    var modelssStream = stream();
    var musfaStream = modelssStream.transform<BillModel>(
        StreamTransformer.fromHandlers(handleData: (model, sink) {
      var r1 = model.createDate.compareTo(from);
      var r2 = model.createDate.compareTo(to);
      if (!(r1 == 1 && r2 == -1)) {
        return;
      }
      sink.add(model);
    }));
    return musfaStream;
  }
}
