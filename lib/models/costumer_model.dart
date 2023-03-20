import 'dart:async';
import 'dart:convert';

import 'package:mongo_dart/mongo_dart.dart';

import '../utils/system_cache.dart';
import '../utils/system_db.dart';
import 'quality_control/action_model.dart';
import 'sales/receipt_model.dart';


class CostumerModel {
  CostumerModel(
    this.id, {
    // required this.levelNumber,
    required this.firstname,
    required this.lastname,
    required this.phoneNumber,
    this.email,
    this.note,
    required this.debtCeiling,
    required this.totalWanted,
    required this.totalPayed,
    required this.receiptsArchive,
  });

  int id;
  // late int levelNumber;
  late String firstname;
  late String lastname;
  late String phoneNumber;
  late String? email;
  String? bonus;
  String? note;
  late double debtCeiling;
  late double totalWanted;
  late double totalPayed;
  late List<String> receiptsArchive;

  static const String collectionName = 'costumers';

  static CostumerModel? get stored => SystemCache.get(collectionName);

  void setUser(CostumerModel costumer) =>
      SystemCache.set(collectionName, costumer);
  // static void _setUser(CostumerModel? costumer) =>
  //     SystemCache.set(collectionName, costumer);

  static void _deleteUser() => SystemCache.remove(collectionName);

  static CostumerModel fromMap(Map<String, dynamic> data) {
    CostumerModel user = CostumerModel(
      data['id'],
      // levelNumber: data['levelNumber'],
      firstname: data['firstname'],
      lastname: data['lastname'],
      phoneNumber: data['phoneNumber'],
      email: data['email'],
      note: data['note'],
      debtCeiling: data['debtCeiling'],
      totalWanted: data['totalWanted'],
      totalPayed: data['totalPayed'] ?? 0,
      receiptsArchive: [...data['receiptsArchive']],
    );
    return user;
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'firstname': firstname,
        'lastname': lastname,
        'phoneNumber': phoneNumber,
        'email': email,
        'note': note,
        'debtCeiling': debtCeiling,
        'totalWanted': totalWanted,
        'totalPayed': totalPayed,
        'receiptsArchive': receiptsArchive,
      };

  String toJson() => json.encode(toMap());

  static CostumerModel fromJson(String jsn) {
    return fromMap(json.decode(jsn));
  }

  static Future<void> signout() async {
    // CostumerModel? user = CostumerModel.stored;
    await ActionModel.signout();
    _deleteUser();
  }

  static Stream<CostumerModel> stream() {
    return SystemMDBService.db.collection(collectionName).find().transform(
      StreamTransformer.fromHandlers(
        handleData: (data, sink) {
          sink.add(CostumerModel.fromMap(data));
        },
      ),
    );
  }

  Future<CostumerModel?> aggregate(List<dynamic> pipeline) async {
    var d =
        await SystemMDBService.db.collection(collectionName).aggregate(pipeline);

    return CostumerModel.fromMap(d);
  }

  static Future<CostumerModel?> get(int id) async {
    var d = await SystemMDBService.db
        .collection(collectionName)
        .findOne(where.eq('id', id));
    if (d == null) {
      return null;
    }
    return CostumerModel.fromMap(d);
  }

  static Future<CostumerModel?> findByUsername(String username) async {
    var r = await SystemMDBService.db
        .collection(collectionName)
        .findOne(where.eq('username', username));
    // var s = SystemMDBService.db.collection(collectionName).find();
    // print(await s.first);
    print(r);
    if (r == null) {
      return null;
    }
    return CostumerModel.fromMap(r);
  }

  Future<CostumerModel?> edit() async {
    var r = await SystemMDBService.db.collection(collectionName).update(
          where.eq('id', id),
          toMap(),
        );
    print('User Update: $r');
    return this;
  }

  Future<int> delete(String id) async {
    var r = await SystemMDBService.db.collection(collectionName).remove(
          where.eq('id', id),
        );
    print(r);
    return 1;
  }

  Future<CostumerModel> add() async {
    var r = await SystemMDBService.db.collection(collectionName).insert(
          toMap(),
        );
    print(r);
    // toast(r['ok'].toString()jyhf);
    return this;
    //   toast(r['ok']);
    // if (r['ok'] == '1.0') {
    // } else {
    // }
  }

  Future<int> recordReceipt(ReceiptModel receiptForm) async {
    if (receiptForm.receiptState == ReceiptState.returned) {
      totalWanted -= receiptForm.debitWanted;
      totalPayed -= receiptForm.payed;
      receiptsArchive.remove(
          '${receiptForm.id} - ${receiptForm.receiptState} - المدفوع: ${receiptForm.realPayed} - الاجل: ${receiptForm.debitWanted}');
    } else {
      totalWanted += receiptForm.debitWanted;
      totalPayed += receiptForm.payed;
      receiptsArchive.add(
          '${receiptForm.id} - ${receiptForm.receiptState} - المدفوع: ${receiptForm.realPayed} - الاجل: ${receiptForm.debitWanted}');
    }
    print(
        '${receiptForm.receiptState}: ${receiptForm.wanted} - ${receiptForm.payed}');
    print('totalWanted: $totalWanted - $totalPayed');
    await edit();
    return 1;
  }
}
