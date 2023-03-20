import 'dart:async';
import 'dart:convert';

import 'package:mongo_dart/mongo_dart.dart';

import '../utils/system_db.dart';

class AddressModel {
  String? town;
  String? area;
  String? state;
  String? country;

  static AddressModel fromMap(Map<String, dynamic> data) {
    AddressModel model = AddressModel();
    model.town = data['town'];
    model.area = data['area'];
    model.state = data['state'];
    model.country = data['country'];
    return model;
  }

  Map<String, dynamic> toMap() => {
        'town': town,
        'area': area,
        'state': state,
        'country': country,
      };

  String toJson() => json.encode(toMap());

  static AddressModel fromJson(String jsn) {
    return fromMap(json.decode(jsn));
  }

  Stream<AddressModel>? stream() {
    return SystemMDBService.db.collection('addresses').find().transform(
      StreamTransformer.fromHandlers(
        handleData: (data, sink) {
          sink.add(AddressModel.fromMap(data));
        },
      ),
    );
  }

  Future<AddressModel?> aggregate(List<dynamic> pipeline) async {
    var d = await SystemMDBService.db.collection('addresses').aggregate(pipeline);

    return AddressModel.fromMap(d);
  }

  Future<AddressModel?> get(String id) async {
    var d =
        await SystemMDBService.db.collection('addresses').findOne(where.eq('id', id));
    if (d == null) {
      return null;
    }
    return AddressModel.fromMap(d);
  }

  Future<AddressModel?> findByName(String name, String id) async {
    var d =
        await SystemMDBService.db.collection('addresses').findOne(where.eq('id', id));
    if (d == null) {
      return null;
    }
    return AddressModel.fromMap(d);
  }

  Future<AddressModel?> edit(String id, Map<String, dynamic> document) async {
    var r = await SystemMDBService.db.collection('addresses').update(
          where.eq('id', id),
          document,
        );
    print(r);
    return AddressModel.fromMap(r);
  }

  Future<int> delete(String id) async {
    var r = await SystemMDBService.db.collection('addresses').remove(
          where.eq('id', id),
        );
    print(r);
    return 1;
  }

  Future<int> add(AddressModel product) async {
    var r = await SystemMDBService.db.collection('addresses').insert(
          product.toMap(),
        );
    print(r);
    return 1;
  }
}
