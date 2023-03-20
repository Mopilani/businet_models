import 'dart:async';
import 'dart:convert';

import 'package:mongo_dart/mongo_dart.dart';

import '../../utils/system_db.dart';
import '../category_model.dart';
import '../patchs.dart';
import '../subcatgory_model.dart';
import 'sale_unit_model.dart';
import 'stock_model.dart';
import 'supplier_model.dart';

/// Stock Keeping Unit Model
class SKUModel {
  SKUModel._();
  static Stream<SKUModel> stream() {
    // SystemMDBService.db.collection(collectionName).find().listen((event) {
    //   print(event);
    // });
    return SystemMDBService.db.collection(collectionName).find().transform(
      StreamTransformer.fromHandlers(
        handleData: (data, sink) {
          // print(SKUModel.fromMap(data));
          sink.add(SKUModel.fromMap(data));
        },
      ),
    );
  }

  static Stream<Map<String, dynamic>>? streamData() {
    // SystemMDBService.db.collection(collectionName).find().transform(
    //   StreamTransformer.fromHandlers(
    //     handleData: (data, sink) {
    //       // print(SKUMo del.fromMap(data));
    //       sink.add(SKUModel.fromMap(data));
    //     },
    //   ),
    // ).listen((event) {
    //   print(event);
    // });
    return SystemMDBService.db.collection(collectionName).find();
  }

  Future<SKUModel?> aggregateProducts(List<dynamic> pipeline) async {
    var d = await SystemMDBService.db
        .collection(collectionName)
        .aggregate(pipeline);

    return SKUModel.fromMap(d);
  }

  static Future<SKUModel?> get(int id) async {
    var d = await SystemMDBService.db
        .collection(collectionName)
        .findOne(where.eq('id', id));
    if (d == null) {
      d = await SystemMDBService.db
          .collection(collectionName)
          .findOne(where.eq('barcode', id.toString()));
      if (d == null) {
        return null;
      }
    }
    return SKUModel.fromMap(d);
  }

  Future<SKUModel?> findByName(String name, String id) async {
    var d = await SystemMDBService.db
        .collection(collectionName)
        .findOne(where.eq('id', id));
    if (d == null) {
      return null;
    }
    return SKUModel.fromMap(d);
  }

  Future<SKUModel?> edit() async {
    var r = await SystemMDBService.db.collection(collectionName).update(
          where.eq('id', id),
          toMap(),
        );
    // await ActionModel.create(id);
    print(r);
    return this;
  }

  Future<int> delete() async {
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

  static const String collectionName = 'skus';

  Map<String, dynamic> toMap() => {
        'id': id,
        'barcode': barcode,
        'costPrice': costPrice,
        'createDate': createDate,
        'description': description,
        'inactiveAfter': inactiveAfter,
        'expierDate': expierDate,
        'lastUpdate': lastUpdate,
        'productionDate': productionDate,
        'saleUnitModel': saleUnitModel!.toMap(),
        'stockModel': stockModel!.toMap(),
        'subCatgModel': subCatgModel!.toMap(),
        'categoryModel': categoryModel!.toMap(),
        'supplierModel': supplierModel!.toMap(),
        'disPer': disPer,
        'quantity': quantity,
        'salePrice': salePrice,
        'lowestPrice': lowestPrice,
        'highestPrice': highestPrice,
        'inactive': inactive,
        'openRate': openRate,
        'discountable': discountable,
        'salePercent': salePercent,
      };

  static SKUModel fromMap(Map<String, dynamic> data) {
    SKUModel newModel = SKUModel._();
    newModel.id = data['id'];
    newModel.barcode = data['barcode'];
    newModel.costPrice = data['costPrice'];
    newModel.createDate = stringOrDateTime(data['createDate']);
    newModel.description = data['description'];
    newModel.inactiveAfter = data['inactiveAfter'];
    newModel.expierDate = stringOrDateTime(data['expierDate']);
    newModel.lastUpdate = stringOrDateTime(data['lastUpdate']);
    newModel.productionDate = stringOrDateTime(data['productionDate']);
    newModel.saleUnitModel = SaleUnitModel.fromMap(data['saleUnitModel']);
    newModel.stockModel = StockModel.fromMap(data['stockModel']);
    newModel.subCatgModel = SubCatgModel.fromMap(data['subCatgModel']);
    newModel.categoryModel = CategoryModel.fromMap(data['categoryModel']);
    newModel.supplierModel = SupplierModel.fromMap(data['supplierModel']);
    newModel.disPer = data['disPer'];
    newModel.salePercent = data['salePercent'];
    newModel.quantity = data['quantity'];
    newModel.salePrice = data['salePrice'];
    newModel.highestPrice = data['highestPrice'];
    newModel.lowestPrice = data['lowestPrice'];
    newModel.inactive = data['inactive'];
    newModel.openRate = data['openRate'];
    newModel.discountable = data['discountable'];
    return newModel;
  }

  String toJson() => json.encode(toMap());

  static SKUModel fromJson(String jsn) {
    return fromMap(json.decode(jsn));
  }

  SKUModel(
    this.id, {
    this.barcode,
    this.costPrice,
    this.createDate,
    this.description,
    this.inactiveAfter,
    this.expierDate,
    this.lastUpdate,
    this.productionDate,
    this.saleUnitModel,
    this.stockModel,
    this.subCatgModel,
    this.categoryModel,
    this.supplierModel,
    this.salePercent = 0.0,
    this.disPer = 0.0,
    this.quantity = 0,
    this.salePrice = 0,
    this.highestPrice = 0,
    this.lowestPrice = 0,
    this.inactive = false,
    this.openRate = false,
    this.discountable = false,
  }) {
    createDate = DateTime.now();
    lastUpdate = DateTime.now();
  }

  late int id;
  String? description;
  String? barcode;
  double? costPrice = 0;
  double salePrice = 0;
  double salePercent = 0;
  double disPer = 0;
  double lowestPrice = 0;
  double? highestPrice = 0;
  double quantity = 0;
  SupplierModel? supplierModel;
  StockModel? stockModel;
  SaleUnitModel? saleUnitModel;
  SubCatgModel? subCatgModel;
  CategoryModel? categoryModel;
  bool openRate = false;
  bool inactive = false;
  bool discountable = false;
  DateTime? createDate;
  DateTime? lastUpdate;
  DateTime? productionDate;
  DateTime? expierDate;
  DateTime? inactiveAfter;
}
