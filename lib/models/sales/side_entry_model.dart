import 'dart:async';
import 'dart:convert';

import 'package:businet_models/businet_models.dart';

import 'package:mongo_dart/mongo_dart.dart';

class SideEntryModel {
  SideEntryModel(this.id, this.title, this.number);
  final int id;
  final String title;
  final String number;

  static SideEntryModel fromMap(Map<String, dynamic> data) =>
      SideEntryModel(data['id'], data['title'], data['number']);

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'number': number,
      };

  String toJson() => json.encode(toMap());

  static SideEntryModel fromJson(String jsn) {
    return fromMap(json.decode(jsn));
  }

  static Future<List<SideEntryModel>> getAll() async {
    List<SideEntryModel> result = [];
    return SystemMDBService.db
        .collection('sentries')
        .find()
        .transform<SideEntryModel>(
          StreamTransformer.fromHandlers(
            handleData: (data, sink) {
              sink.add(SideEntryModel.fromMap(data));
            },
          ),
        )
        .listen((saleUnit) {
          result.add(saleUnit);
        })
        .asFuture()
        .then((value) => result);
  }

  Stream<SideEntryModel>? stream() {
    return SystemMDBService.db.collection('sentries').find().transform(
      StreamTransformer.fromHandlers(
        handleData: (data, sink) {
          sink.add(SideEntryModel.fromMap(data));
        },
      ),
    );
  }

  Future<SideEntryModel?> aggregate(List<dynamic> pipeline) async {
    var d =
        await SystemMDBService.db.collection('sentries').aggregate(pipeline);

    return SideEntryModel.fromMap(d);
  }

  static Future<SideEntryModel?> get(int id) async {
    var d = await SystemMDBService.db
        .collection('sentries')
        .findOne(where.eq('id', id));
    if (d == null) {
      return null;
    }
    return SideEntryModel.fromMap(d);
  }

  static Future<SideEntryModel?> findByTitle(String title) async {
    var d = await SystemMDBService.db
        .collection('sentries')
        .findOne(where.eq('title', title));
    if (d == null) {
      return null;
    }
    return SideEntryModel.fromMap(d);
  }

  static Future<SideEntryModel?> findById(int id) async {
    var d = await SystemMDBService.db
        .collection('sentries')
        .findOne(where.eq('id', id));
    if (d == null) {
      return null;
    }
    return SideEntryModel.fromMap(d);
  }

  Future<SideEntryModel> edit() async {
    var r = await SystemMDBService.db.collection('sentries').update(
          where.eq('id', id),
          toMap(),
        );
    print(r);
    return this;
  }

  Future<int> delete() async {
    var r = await SystemMDBService.db.collection('sentries').remove(
          where.eq('id', id),
        );
    print(r);
    return 1;
  }

  Future<int> add() async {
    var r = await SystemMDBService.db.collection('sentries').insert(
          toMap(),
        );
    print(r);
    return 1;
  }
}
