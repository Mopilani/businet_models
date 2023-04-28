import 'dart:async';
import 'dart:convert';

import 'package:mongo_dart/mongo_dart.dart';

import '../../utils/system_db.dart';
import 'bill_model.dart';
import 'expier_controller.dart';
import 'receipt_entry_model.dart';
import 'receipt_model.dart';
import 'sku_model.dart';

class StockModel {
  StockModel._();

  static const String collectionName = 'stocks';

  StockModel(
    this.id, {
    required this.title,
    required this.totalValue,
    required this.totalProducts,
    // this.products = const <String, SKUModel>{},
    this.description,
    this.phoneNumber,
    this.town,
    this.area,
    this.state,
    this.country,
  });
  late int id;
  late String title;
  late double totalValue;
  late double totalProducts;
  // late Map<String, SKUModel> products;
  String? description;
  String? phoneNumber;
  String? town;
  String? area;
  String? state;
  String? country;

  Future<Map> pullBill(BillModel bill) async {
    Map recordingToStockResult = {
      'not_found_skus': <int>[],
      'description_conflict_skus': <int>[],
    };
    for (var entry in bill.billEntries.entries) {
      totalProducts -= (entry.value.quantity + entry.value.freeQuantity);
      totalValue -= entry.value.total;
      var id = entry.value.skuModel.id;
      var sku = await SKUModel.get(id);
      if (sku == null) {
        recordingToStockResult['not_found_skus'].add(id);
      } else {
        var totalQuantity = entry.value.quantity + entry.value.freeQuantity;
        sku.quantity -= totalQuantity;
        if (sku.description != entry.value.skuModel.description) {
          recordingToStockResult['description_conflict_skus'].add(id);
        }
        await sku.edit();
        String expierId = '${bill.createDate}-${sku.id}-${bill.expierDate}';
        ExpierControllerModel? model =
            await ExpierControllerModel.get(expierId);
        if (model != null) {
          await model.delete(expierId);
        }
      }
    }
    return recordingToStockResult;
  }

  Future<Map> pushBill(BillModel bill) async {
    Map recordingToStockResult = {
      'not_found_skus': <int>[],
      'description_conflict_skus': <int>[],
    };
    for (var entry in bill.billEntries.entries) {
      totalProducts += (entry.value.quantity + entry.value.freeQuantity);
      totalValue += entry.value.total;
      var id = entry.value.skuModel.id;
      var sku = await SKUModel.get(id);
      if (sku == null) {
        recordingToStockResult['not_found_skus'].add(id);
      } else {
        var totalQuantity = entry.value.quantity + entry.value.freeQuantity;
        // print('totalQuantity pushBill(): $totalQuantity');
        sku.quantity += totalQuantity;
        if (sku.description != entry.value.skuModel.description) {
          recordingToStockResult['description_conflict_skus'].add(id);
        }
        var expierDateSegs = entry.value.expierDate.split('-');
        var expierYear =
            int.tryParse(expierDateSegs.last) ?? (DateTime.now().year + 1);
        var expierMonth = int.tryParse(expierDateSegs.first) ?? 1;
        await sku.edit();
        var model = ExpierControllerModel(
          expierDate: DateTime(expierYear, expierMonth),
          expiered: false,
          sku: sku,
          billCreateTime: bill.createDate,
        );
        await model.add();
      }
    }
    return recordingToStockResult;
  }

  Future<StockModel> recordReceipt(ReceiptModel receipt) async {
    for (var receiptEntry in receipt.receiptEntries.entries) {
      totalProducts -= receiptEntry.value.quantity;
      totalValue -= receiptEntry.value.total;
    }
    return await edit();
  }

  Future<StockModel> recordReturnedReceipt(
    ReceiptModel receipt,
    Map<String, ReceiptEntryModel> returnedEnteries,
  ) async {
    for (var receiptEntry in returnedEnteries.entries) {
      totalProducts += receiptEntry.value.quantity;
      totalValue += receiptEntry.value.total;
    }
    for (var receiptEntry in receipt.receiptEntries.entries) {
      totalProducts -= receiptEntry.value.quantity;
      totalValue -= receiptEntry.value.total;
    }
    return await edit();
  }

  static StockModel fromMap(Map<String, dynamic> data) {
    StockModel model = StockModel._();
    model.id = data['id'];
    model.title = data['title'];
    model.description = data['description'];
    model.phoneNumber = data['phoneNumber'];
    model.totalValue = data['totalValue'];
    model.totalProducts = data['totalProducts'];
    // model.products = data['products'];
    model.town = data['town'];
    model.area = data['area'];
    model.state = data['state'];
    model.country = data['country'];
    return model;
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'description': description,
        'phoneNumber': phoneNumber,
        'totalValue': totalValue,
        'totalProducts': totalProducts,
        // 'products': products,
        'town': town,
        'area': area,
        'state': state,
        'country': country,
      };

  String toJson() => json.encode(toMap());

  static StockModel fromJson(String jsn) {
    return fromMap(json.decode(jsn));
  }

  static Future<List<StockModel>> getAll() async {
    List<StockModel> result = [];
    return SystemMDBService.db
        .collection(collectionName)
        .find()
        .transform<StockModel>(
          StreamTransformer.fromHandlers(
            handleData: (data, sink) {
              sink.add(StockModel.fromMap(data));
            },
          ),
        )
        .listen((saleUnit) {
          result.add(saleUnit);
        })
        .asFuture()
        .then((value) => result);
  }

  Stream<StockModel>? stream() {
    return SystemMDBService.db.collection(collectionName).find().transform(
      StreamTransformer.fromHandlers(
        handleData: (data, sink) {
          sink.add(StockModel.fromMap(data));
        },
      ),
    );
  }

  Future<StockModel?> aggregate(List<dynamic> pipeline) async {
    var d = await SystemMDBService.db.collection(collectionName).aggregate(pipeline);

    return StockModel.fromMap(d);
  }

  static Future<StockModel?> get(int id) async {
    var d = await SystemMDBService.db
        .collection(collectionName)
        .findOne(where.eq('id', id));
    if (d == null) {
      return null;
    }
    return StockModel.fromMap(d);
  }

  static Future<StockModel?> findByTitle(String title) async {
    var d = await SystemMDBService.db
        .collection(collectionName)
        .findOne(where.eq('title', title));
    if (d == null) {
      return null;
    }
    return StockModel.fromMap(d);
  }

  static Future<StockModel?> findById(int id) async {
    var d = await SystemMDBService.db
        .collection(collectionName)
        .findOne(where.eq('id', id));
    if (d == null) {
      return null;
    }
    return StockModel.fromMap(d);
  }

  Future<StockModel> edit() async {
    var r = await SystemMDBService.db.collection(collectionName).update(
          where.eq('id', id),
          toMap(),
        );
    print(r);
    return this;
  }

  Future<int> delete(int id) async {
    var r = await SystemMDBService.db.collection(collectionName).remove(
          where.eq('id', id),
        );
    print(r);
    return 1;
  }

  Future<int> add() async {
    var r = await SystemMDBService.db.collection(collectionName).insert(
          toMap(),
        );
    print(r);
    return 1;
  }

  // static Future<int> addd(StockModel model) async {
  //   var r = await SystemMDBService.db.collection(collectionName).insert(
  //         model.toMap(),
  //       );
  //   print(r);
  //   return 1;
  // }
}
