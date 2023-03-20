import 'dart:async';
import 'dart:convert';

import 'package:mongo_dart/mongo_dart.dart';

import '../../utils/system_db.dart';
import 'delivery_driver_model.dart';

class DeliveryModel {
  dynamic id;
  late DeliveryDriverModel deliveryDriverModel;
  late String fromAddress;
  late String toAddress;
  late String fromPoint;
  late String toPoint;

  static DeliveryModel fromMap(Map<String, dynamic> data) {
    DeliveryModel model = DeliveryModel();
    model.id = data['id'];
    model.deliveryDriverModel = DeliveryDriverModel.fromMap(data['deliveryDriverModel']);
    model.fromAddress = data['fromAddress'];
    model.toAddress = data['toAddress'];
    model.fromPoint = data['fromPoint'];
    model.toPoint = data['toPoint'];
    return model;
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'deliveryDriverModel': deliveryDriverModel.toMap(),
        'fromAddress': fromAddress,
        'toAddress': toAddress,
        'fromPoint': fromPoint,
        'toPoint': toPoint,
      };

  String toJson() => json.encode(toMap());

  static DeliveryModel fromJson(String jsn) {
    return fromMap(json.decode(jsn));
  }

  
  Stream<DeliveryModel>? stream() {
    return SystemMDBService.db.collection('deliveryOrders').find().transform(
      StreamTransformer.fromHandlers(
        handleData: (data, sink) {
          sink.add(DeliveryModel.fromMap(data));
        },
      ),
    );
  }

  Future<DeliveryModel?> aggregate(List<dynamic> pipeline) async {
    var d = await SystemMDBService.db.collection('deliveryOrders').aggregate(pipeline);

    return DeliveryModel.fromMap(d);
  }

  Future<DeliveryModel?> get(String id) async {
    var d =
        await SystemMDBService.db.collection('deliveryOrders').findOne(where.eq('id', id));
    if (d == null) {
      return null;
    }
    return DeliveryModel.fromMap(d);
  }

  Future<DeliveryModel?> findByName(String name, String id) async {
    var d =
        await SystemMDBService.db.collection('deliveryOrders').findOne(where.eq('id', id));
    if (d == null) {
      return null;
    }
    return DeliveryModel.fromMap(d);
  }

  Future<DeliveryModel?> edit(
      String id, Map<String, dynamic> document) async {
    var r = await SystemMDBService.db.collection('deliveryOrders').update(
          where.eq('id', id),
          document,
        );
    print(r);
    return DeliveryModel.fromMap(r);
  }

  Future<int> delete(String id) async {
    var r = await SystemMDBService.db.collection('deliveryOrders').remove(
          where.eq('id', id),
        );
    print(r);
    return 1;
  }

  Future<int> add(DeliveryModel product) async {
    var r = await SystemMDBService.db.collection('deliveryOrders').insert(
          product.toMap(),
        );
    print(r);
    return 1;
  }
}
