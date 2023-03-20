import 'dart:async';
import 'dart:convert';

import 'package:mongo_dart/mongo_dart.dart';

import '../../utils/system_db.dart';
import '../accounting/payment_method_model.dart';
import '../patchs.dart';
import '../processes_model.dart';
import 'user_model.dart';

class ShiftModel {
  ShiftModel({
    required this.user,
    this.title,
    required this.number,
    required this.moneyInventory,
    required this.startDateTime,
    required this.saledReceiptsIds,
    this.endDateTime,
    id,
    this.payed = 0.0,
    this.wanted = 0.0,
    this.total = 0.0,
  }) {
    this.id = id ?? '${dateToString(startDateTime)}-$number';
  }

  late String id;
  String? title;
  int number;
  final UserModel user;
  final List<int> saledReceiptsIds;
  DateTime startDateTime;
  late DateTime? endDateTime;
  List<MoneyInventory> moneyInventory = [];
  double payed = 0.0;
  double wanted = 0.0;
  double total = 0.0;

  static ShiftModel fromMap(Map<String, dynamic> data) => ShiftModel(
        id: data['id'],
        user: UserModel.fromMap(data['user']),
        title: data['title'],
        number: data['number'],
        startDateTime: stringOrDateTime(data['startDateTime'])!,
        endDateTime: stringOrDateTime(data['endDateTime']),
        saledReceiptsIds: [...data['saledReceiptsIds']],
        moneyInventory: [
          ...data['moneyInventory']
              .map((e) => MoneyInventory.fromMap(e))
              .toList()
        ],
        payed: data['payed'],
        wanted: data['wanted'],
        total: data['total'],
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'user': user.toMap(),
        'title': title,
        'number': number,
        'startDateTime': startDateTime,
        'endDateTime': endDateTime,
        'saledReceiptsIds': saledReceiptsIds,
        'moneyInventory': moneyInventory.map((e) => e.toMap()).toList(),
        'payed': payed,
        'wanted': wanted,
        'total': total,
      };

  String toJson() => json.encode(toMap());

  static ShiftModel fromJson(String jsn) {
    return fromMap(json.decode(jsn));
  }

  static Future<List<ShiftModel>> getAll() async {
    List<ShiftModel> result = [];
    return SystemMDBService.db
        .collection('shifts')
        .find()
        .transform<ShiftModel>(
          StreamTransformer.fromHandlers(
            handleData: (data, sink) {
              sink.add(ShiftModel.fromMap(data));
            },
          ),
        )
        .listen((saleUnit) {
          result.add(saleUnit);
        })
        .asFuture()
        .then((value) => result);
  }

  Stream<ShiftModel>? stream() {
    return SystemMDBService.db.collection('shifts').find().transform(
      StreamTransformer.fromHandlers(
        handleData: (data, sink) {
          sink.add(ShiftModel.fromMap(data));
        },
      ),
    );
  }

  Future<ShiftModel?> aggregate(List<dynamic> pipeline) async {
    var d = await SystemMDBService.db.collection('shifts').aggregate(pipeline);

    return ShiftModel.fromMap(d);
  }

  static Future<ShiftModel?> get(String id) async {
    var d = await SystemMDBService.db
        .collection('shifts')
        .findOne(where.eq('id', id));
    if (d == null) {
      return null;
    }
    return ShiftModel.fromMap(d);
  }

  static Future<ShiftModel?> findByTitle(String title) async {
    var d = await SystemMDBService.db
        .collection('shifts')
        .findOne(where.eq('title', title));
    if (d == null) {
      return null;
    }
    return ShiftModel.fromMap(d);
  }

  static Future<ShiftModel?> findById(String id) async {
    var d = await SystemMDBService.db
        .collection('shifts')
        .findOne(where.eq('id', id));
    if (d == null) {
      return null;
    }
    return ShiftModel.fromMap(d);
  }

  Future<ShiftModel> edit() async {
    var r = await SystemMDBService.db.collection('shifts').update(
          where.eq('id', id),
          toMap(),
        );
    print(r);
    return this;
  }

  static Future<int> delete() async {
    // var r = await SystemMDBService.db.collection('shifts').remove(
    //       where.eq('id', id),
    //     );
    var r = await SystemMDBService.db.collection('shifts').drop();
    print(r);
    return 1;
  }

  Future<int> add() async {
    var r = await SystemMDBService.db.collection('shifts').insert(
          toMap(),
        );
    print(r);
    return 1;
  }
}

class MoneyInventory {
  MoneyInventory({
    required this.id,
    required this.paymentMethod,
    required this.value,
  });
  final int id;
  final PaymentMethodModel paymentMethod;
  double value;

  static MoneyInventory fromMap(Map<String, dynamic> data) => MoneyInventory(
        id: data['id'],
        paymentMethod: PaymentMethodModel.fromMap(data['paymentMethod']),
        value: data['value'],
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'paymentMethod': paymentMethod.toMap(),
        'value': value,
      };

  String toJson() => json.encode(toMap());

  static MoneyInventory fromJson(String jsn) {
    return fromMap(json.decode(jsn));
  }
}
