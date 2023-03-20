import 'dart:async';
import 'dart:convert';


import 'package:mongo_dart/mongo_dart.dart';

import '../../utils/enums.dart';
import '../../utils/system_db.dart';
import 'bill_model.dart';


class SupplierModel {
  SupplierModel._();

  SupplierModel(
    this.id, {
    required this.name,
    this.phoneNumber,
    this.town,
    this.area,
    this.state,
    this.country,
    this.email,
    this.zipCode,
    this.totalWanted = 0,
    this.totalPayed = 0,
    required this.billsNo,
  });

  dynamic id;
  late String name;
  String? phoneNumber;
  String? town;
  String? area;
  String? state;
  String? country;
  String? email;
  String? zipCode;
  late List<String> billsNo;
  // List<BillModel> bills = [];
  double totalWanted = 0;
  double totalPayed = 0;
  // String faxNumber;

  static const String collectionName = 'suppliers';

  static SupplierModel fromMap(Map<String, dynamic> data) {
    SupplierModel model = SupplierModel._();
    model.id = data['id'];
    model.name = data['name'];
    model.phoneNumber = data['phoneNumber'];
    model.town = data['town'];
    model.area = data['area'];
    model.state = data['state'];
    model.country = data['country'];
    model.email = data['email'];
    model.zipCode = data['zipCode'];
    model.billsNo = [...(data['billsNo'] ?? <String>[])];
    // print(model.billsNo);
    model.totalWanted = data['totalWanted'] ?? 0;
    model.totalPayed = data['totalPayed'] ?? 0;
    return model;
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'phoneNumber': phoneNumber,
        'town': town,
        'area': area,
        'state': state,
        'country': country,
        'email': email,
        'zipCode': zipCode,
        'billsNo': billsNo,
        // 'bills': bills.map((e) => e.toMap()).toList(),
        'totalWanted': totalWanted,
        'totalPayed': totalPayed,
      };

  String toJson() => json.encode(toMap());

  static SupplierModel fromJson(String jsn) {
    return fromMap(json.decode(jsn));
  }

  static Future<List<SupplierModel>> getAll() {
    List<SupplierModel> models = [];
    return SystemMDBService.db
        .collection(collectionName)
        .find()
        .transform<SupplierModel>(
          StreamTransformer.fromHandlers(
            handleData: (data, sink) {
              sink.add(SupplierModel.fromMap(data));
            },
          ),
        )
        .listen((subCatg) {
          models.add(subCatg);
        })
        .asFuture()
        .then((value) => models);
  }

  Stream<SupplierModel> stream() {
    return SystemMDBService.db.collection(collectionName).find().transform(
      StreamTransformer.fromHandlers(
        handleData: (data, sink) {
          sink.add(SupplierModel.fromMap(data));
        },
      ),
    );
  }

  Future<SupplierModel?> aggregate(List<dynamic> pipeline) async {
    var d =
        await SystemMDBService.db.collection(collectionName).aggregate(pipeline);

    return SupplierModel.fromMap(d);
  }

  static Future<SupplierModel?> get(int id) async {
    var d = await SystemMDBService.db
        .collection(collectionName)
        .findOne(where.eq('id', id));
    if (d == null) {
      return null;
    }
    return SupplierModel.fromMap(d);
  }

  static Future<SupplierModel?> findByName(String name) async {
    var d = await SystemMDBService.db
        .collection(collectionName)
        .findOne(where.eq('name', name));
    if (d == null) {
      return null;
    }
    return SupplierModel.fromMap(d);
  }

  static Future<SupplierModel?> findById(int id) async {
    var d = await SystemMDBService.db
        .collection(collectionName)
        .findOne(where.eq('id', id));
    if (d == null) {
      return null;
    }
    return SupplierModel.fromMap(d);
  }

  Future<SupplierModel> edit() async {
    var r = await SystemMDBService.db.collection(collectionName).update(
          where.eq('id', id),
          toMap(),
        );
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

  Future<int> recordBill(BillModel billForm) async {
    if (billForm.billType == BillType.goodsReceived) {
      print('billForm.wasImported!: ${billForm.wasImported!}');
      if (!billForm.wasImported!) {
        totalWanted -= billForm.wanted;
        totalPayed -= billForm.payed;
        print(
            '${!billForm.wasImported!}: ${billForm.wanted} - ${billForm.payed}');
      } else {
        totalWanted += billForm.wanted;
        totalPayed += billForm.payed;
        print(
            '${!billForm.wasImported!}: ${billForm.wanted} - ${billForm.payed}');
      }
    }
    print('totalWanted: $totalWanted - $totalPayed');
    billsNo.add(
        '${billForm.id} - ${billForm.billType} - ${billForm.billState} - المدفوع: ${billForm.payed} - المتبقي: ${billForm.wanted}');
    await edit();
    return 1;
  }
}
