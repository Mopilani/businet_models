import 'dart:async';
import 'dart:convert';

import 'package:mongo_dart/mongo_dart.dart';

import '../../utils/enums.dart';
import '../../utils/system_db.dart';
import '../hr/user_model.dart';
// import 'tree_main_account_model.dart';
import 'tree_sub_account_model.dart';
import 'user_lite_model.dart';

class CreditModel {
  CreditModel(
    this.id, {
    required this.creditType,
    // required this.bill,
    // required this.worker,
    required this.credit,
    required this.debit,
    required this.notice,
    // required this.mainAccount,
    // required this.subAccount,
    required this.fromAccount,
    required this.toAccount,
    required this.creditDate,
    required this.user,
  }) {
    createDate = DateTime.now();
    // switch (creditType) {
    //   case CreditType.credit:
    //     break;
    //   case CreditType.slfia:
    //     assert(worker != null);
    //     break;
    //   case CreditType.purchasesInvoice:
    //     assert(bill != null);
    //     break;
    //   case CreditType.workerSalary:
    //     assert(worker != null);
    //     break;
    //   default:
    // }
  }

  dynamic id;
  late CreditType creditType;
  late DateTime createDate;
  late DateTime creditDate;
  late String notice;
  late UserLiteModel user;
  // BillModel? bill;
  // WorkerModel? worker;
  double credit;
  double debit;
  // TreeMainAccountModel mainAccount;
  // TreeSubAccountModel subAccount;
  TreeSubAccountModel fromAccount;
  TreeSubAccountModel toAccount;

  static const String collectionName = 'credits';

  static CreditModel fromMap(Map<String, dynamic> data) {
    CreditModel model = CreditModel(
      data['id'],
      creditType: getCreditType(data['creditType'])!,
      notice: data['notice'],
      // bill: data['bill'],
      // worker: data['worker'],
      credit: data['credit'],
      debit: data['debit'],
      user: UserLiteModel.fromMap({...data['user']}),
      // mainAccount: TreeMainAccountModel.fromMap(data['mainAccount']),
      // subAccount: TreeSubAccountModel.fromMap(data['subAccount']),
      fromAccount: TreeSubAccountModel.fromMap({...data['fromAccount']}),
      toAccount: TreeSubAccountModel.fromMap({...data['toAccount']}),
      creditDate: data['creditDate'],
    );
    model.createDate =
        data['createDate'] ?? DateTime.now(); // Fix just for debuging
    return model;
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'creditType': creditType.toString(),
        'notice': notice,
        // 'bill': bill,
        // 'worker': worker,
        'credit': credit,
        'debit': debit,
        // 'mainAccount': mainAccount.toMap(),
        // 'subAccount': subAccount.toMap(),
        'fromAccount': fromAccount.toMap(),
        'toAccount': toAccount.toMap(),
        'user': user.toMap(),
        'createDate': createDate,
        'creditDate': creditDate,
      };

  String toJson() => json.encode(toMap());

  static CreditModel fromJson(String jsn) {
    return fromMap(json.decode(jsn));
  }

  static Future<List<CreditModel>> getAll() {
    List<CreditModel> catgs = [];
    return SystemMDBService.db
        .collection(collectionName)
        .find()
        .transform<CreditModel>(
          StreamTransformer.fromHandlers(
            handleData: (data, sink) {
              sink.add(CreditModel.fromMap(data));
            },
          ),
        )
        .listen((subCatg) {
          catgs.add(subCatg);
        })
        .asFuture()
        .then((value) => catgs);
  }

  static Future<List<CreditModel>> getOf(String collectionName) {
    List<CreditModel> catgs = [];
    return SystemMDBService.db
        .collection(collectionName)
        .find()
        .transform<CreditModel>(
          StreamTransformer.fromHandlers(
            handleData: (data, sink) {
              sink.add(CreditModel.fromMap(data));
            },
          ),
        )
        .listen((subCatg) {
          catgs.add(subCatg);
        })
        .asFuture()
        .then((value) => catgs);
  }

  static Stream<CreditModel> streamOf(String collectionName) {
    return SystemMDBService.db.collection(collectionName).find().transform(
      StreamTransformer.fromHandlers(
        handleData: (data, sink) {
          sink.add(CreditModel.fromMap(data));
        },
      ),
    );
  }

  static Stream<CreditModel> stream() {
    return SystemMDBService.db.collection(collectionName).find().transform(
      StreamTransformer.fromHandlers(
        handleData: (data, sink) {
          sink.add(CreditModel.fromMap(data));
        },
      ),
    );
  }

  Future<CreditModel?> aggregate(List<dynamic> pipeline) async {
    var d = await SystemMDBService.db
        .collection(collectionName)
        .aggregate(pipeline);

    return CreditModel.fromMap(d);
  }

  static Future<CreditModel?> get(dynamic id) async {
    var d = await SystemMDBService.db
        .collection(collectionName)
        .findOne(where.eq('id', id));
    if (d == null) {
      return null;
    }
    return CreditModel.fromMap(d);
  }

  Future<CreditModel?> edit() async {
    var r = await SystemMDBService.db.collection(collectionName).update(
          where.eq('id', id),
          toMap(),
        );
    print(r);
    return this;
  }

  Future<int> delete([int? id]) async {
    var r = await SystemMDBService.db.collection(collectionName).remove(
          where.eq('id', id ?? id),
        );
    print(r);
    return 1;
  }

  static Future<int> deleteOf(String collectionName) async {
    var r = await SystemMDBService.db.collection(collectionName).drop();
    print(r);
    return 1;
  }

  Future<CreditModel> add() async {
    var r = await SystemMDBService.db.collection(collectionName).insert(
          toMap(),
        );
    print(r);
    return this;
  }

  Future<CreditModel> addTo(String collectionName) async {
    var r = await SystemMDBService.db.collection(collectionName).insert(
          toMap(),
        );
    print(r);
    return this;
  }
}
