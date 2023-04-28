import 'dart:async';
import 'dart:convert';

import 'package:businet_models/businet_models.dart';
import 'package:mongo_dart/mongo_dart.dart';

class SaleUnitModel {
  SaleUnitModel._();

  SaleUnitModel(
      this.id, this.name, this.quantity, this.containsUnknownQuantity) {
    // id = const Uuid().v4();
  }

  static const String collectionName = 'saleunits';

  dynamic id;
  late String name;
  late double quantity;
  late bool? containsUnknownQuantity;

  static SaleUnitModel fromMap(Map<String, dynamic> data) {
    SaleUnitModel model = SaleUnitModel._();
    // print(data);
    model.id = data['id'];
    model.name = data['name'];
    model.quantity = data['quantity'];
    model.containsUnknownQuantity = data['containsUnknownQuantity'];
    return model;
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'quantity': quantity,
        'containsUnknownQuantity': containsUnknownQuantity,
      };

  String toJson() => json.encode(toMap());

  static SaleUnitModel fromJson(String jsn) {
    return fromMap(json.decode(jsn));
  }

  static Future<List<SaleUnitModel>> getAll() async {
    List<SaleUnitModel> result = [];
    return SystemMDBService.db
        .collection(collectionName)
        .find()
        .transform<SaleUnitModel>(
          StreamTransformer.fromHandlers(
            handleData: (data, sink) {
              sink.add(SaleUnitModel.fromMap(data));
            },
          ),
        )
        .listen((saleUnit) {
          result.add(saleUnit);
        })
        .asFuture()
        .then((value) => result);
  }

  static Stream<SaleUnitModel>? stream() {
    return SystemMDBService.db.collection(collectionName).find().transform(
      StreamTransformer.fromHandlers(
        handleData: (data, sink) {
          sink.add(SaleUnitModel.fromMap(data));
        },
      ),
    );
  }

  Future<SaleUnitModel?> aggregate(List<dynamic> pipeline) async {
    var d = await SystemMDBService.db.collection(collectionName).aggregate(pipeline);
    return SaleUnitModel.fromMap(d);
  }

  static Future<SaleUnitModel?> findById(int id) async {
    var d = await SystemMDBService.db
        .collection(collectionName)
        .findOne(where.eq('id', id));
    if (d == null) {
      return null;
    }
    return SaleUnitModel.fromMap(d);
  }

  Future<SaleUnitModel?> edit() async {
    var r = await SystemMDBService.db.collection(collectionName).update(
          where.eq('id', id),
          toMap(),
        );
    // print(r);
    return this;
  }

  Future<int> delete(String id) async {
    var r = await SystemMDBService.db.collection(collectionName).remove(
          where.eq('id', id),
        );
    // print(r);
    return 1;
  }

  Future<int> add() async {
    var r = await SystemMDBService.db.collection(collectionName).insert(
          toMap(),
        );
    // print(r);
    return 1;
  }
}
