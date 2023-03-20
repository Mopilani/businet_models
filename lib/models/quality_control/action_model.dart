import 'dart:async';

import 'package:businet_models/businet_models.dart';import 'package:mongo_dart/mongo_dart.dart';

/// Actions table used to log user actions like
///   Signin
///   Signout
///   System Manipulation like
///   Adding catgories, suppliers, and so additions
///   So deletions, and modifications
class ActionModel {
  ActionModel(
    this.line, {
    this.id,
  }) {
    id = const Uuid().v4();
    createDate = DateTime.now();
    user = UserModel.stored!;
  }

  static SyncService? syncSvc;

  static set registerSync(SyncService service) {
    syncSvc = service;
    // service.modelOfCollection('collName').listen;
  }

  // ActionModel.add() {
  //   id = const Uuid().v4();
  //   createDate = DateTime.now();
  //   user = UserModel.stored!;
  // }

  dynamic id;
  late String line;
  late DateTime createDate;
  UserModel? user;

  // static ActionModel fromMap(Map<String, dynamic> data) {
  //   ActionModel action = ActionModel._();
  //   action.id = data['id'];
  //   action.line = data['line'];
  //   action.createDate = DateTime.parse(data['createDate']);
  //   // action.user = UserModel.fromMap(data['user']);
  //   return action;
  // }

  // Map<String, dynamic> toMap() => {
  //       'id': id,
  //       'line': line,
  //       'createDate': createDate.toString(),
  //       // 'userModel': user?.toMap(),
  //     };

  // String toJson() => json.encode(toMap());

  // static ActionModel fromJson(String jsn) {
  //   return fromMap(json.decode(jsn));
  // }

  static Future<List<ActionDataModel>> getAll() async {
    List<ActionDataModel> result = [];
    return SystemMDBService.db
        .collection('actions')
        .find()
        .transform<ActionDataModel>(
          StreamTransformer.fromHandlers(
            handleData: (data, sink) {
              sink.add(ActionDataModel.fromMap(data));
            },
          ),
        )
        .listen((model) {
          result.add(model);
        })
        .asFuture()
        .then((value) => result);
  }

  static Stream<ActionDataModel> stream() {
    return SystemMDBService.db.collection('actions').find().transform(
      StreamTransformer.fromHandlers(
        handleData: (data, sink) {
          // print(data);
          sink.add(ActionDataModel.fromMap(data));
        },
      ),
    );
  }

  Future<ActionDataModel?> aggregate(List<dynamic> pipeline) async {
    var d = await SystemMDBService.db.collection('actions').aggregate(pipeline);

    return ActionDataModel.fromMap(d);
  }

  Future<ActionDataModel?> get(String id) async {
    var d = await SystemMDBService.db
        .collection('actions')
        .findOne(where.eq('id', id));
    if (d == null) {
      return null;
    }
    return ActionDataModel.fromMap(d);
  }

  static Stream<ActionDataModel> collectOfTime(DateTime from, DateTime to) {
    var receiptsStream = stream();
    var musfaStream = receiptsStream.transform<ActionDataModel>(
        StreamTransformer.fromHandlers(handleData: (model, sink) {
      var r1 = model.time.compareTo(from);
      var r2 = model.time.compareTo(to);
      if (!(r1 == 1 && r2 == -1)) {
        return;
      }
      sink.add(model);
    }));
    return musfaStream;
  }
  // Future<ActionModel?> findByName(String name, String id) async {
  //   var d = await SystemMDBService.db
  //       .collection('actions')
  //       .findOne(where.eq('id', id));
  //   if (d == null) {
  //     return null;
  //   }
  //   return ActionModel.fromMap(d);
  // }

  // Future<ActionModel?> edit(String id, Map<String, dynamic> document) async {
  //   var r = await SystemMDBService.db.collection('actions').update(
  //         where.eq('id', id),
  //         document,
  //       );
  //   print(r);
  //   return ActionModel.fromMap(r);
  // }

  // Future<int> delete(String id) async {
  //   var r = await SystemMDBService.db.collection('actions').remove(
  //         where.eq('id', id),
  //       );
  //   print(r);
  //   return 1;
  // }

  // Future<int> add() async {
  //   var r = await SystemMDBService.db.collection('actions').insert(
  //         toMap(),
  //       );
  //   print(r);
  //   return 1;
  // }

  static Future<int> addData(ActionDataModel actionData) async {
    var r = await SystemMDBService.db.collection('actions').insert(
          actionData.toMap(),
        );
    print(r);
    return 1;
  }

  static Future<int> updatedSubscriper(
    SubscriperModel model,
    String collName,
  ) async {
    return await _ac(
      <String, dynamic>{
        ActionDataModel.updatedSubscriper: model.toMap(),
        'cn': collName,
      },
      ActionDataModel.updatedSubscriper,
    );
  }

  static Future<int> deletedSubscriper(
    SubscriperModel model,
    String collName,
  ) async {
    return await _ac(
      <String, dynamic>{
        ActionDataModel.deletedSubscriper: model.toMap(),
        'cn': collName,
      },
      ActionDataModel.deletedSubscriper,
    );
  }

  static Future<int> createSubscriper(
    SubscriperModel model,
    String collName,
  ) async {
    return await _ac(
      <String, dynamic>{
        ActionDataModel.createdSubscriper: model.toMap(),
        'cn': collName,
      },
      ActionDataModel.createdSubscriper,
    );
  }

  static Future<int> createdBatch(
    BatchModel model,
    String collName,
  ) async {
    return await _ac(
      <String, dynamic>{
        ActionDataModel.createdBatch: model.toMap(),
        'cn': collName,
      },
      ActionDataModel.createdBatch,
    );
  }

  static Future<int> updatedBatch(
    BatchModel model,
    String collName,
  ) async {
    return await _ac(
      <String, dynamic>{
        ActionDataModel.updatedBatch: model.toMap(),
        'cn': collName,
      },
      ActionDataModel.updatedBatch,
    );
  }

  static Future<int> deletedBatch(
    BatchModel model,
    String collName,
  ) async {
    return await _ac(
      <String, dynamic>{
        ActionDataModel.deletedBatch: model.toMap(),
        'cn': collName,
      },
      ActionDataModel.deletedBatch,
    );
  }

  static Future<int> createdDepartment(
    DepartmentModel model,
    String collName,
  ) async {
    return await _ac(
      <String, dynamic>{
        ActionDataModel.createdDepartment: model.toMap(),
        'cn': collName,
      },
      ActionDataModel.createdDepartment,
    );
  }

  static Future<int> updatedDepartment(
    DepartmentModel model,
    String collName,
  ) async {
    return await _ac(
      <String, dynamic>{
        ActionDataModel.updatedDepartment: model.toMap(),
        'cn': collName,
      },
      ActionDataModel.updatedDepartment,
    );
  }

  static Future<int> deletedDepartment(
    DepartmentModel model,
    String collName,
  ) async {
    return await _ac(
      <String, dynamic>{
        ActionDataModel.deletedDepartment: model.toMap(),
        'cn': collName,
      },
      ActionDataModel.deletedDepartment,
    );
  }

  static Future<int> createdSubscription(
    SubscriptionModel model,
    String collName,
  ) async {
    return await _ac(
      <String, dynamic>{
        ActionDataModel.createdSubscription: model.toMap(),
        'cn': collName,
      },
      ActionDataModel.createdSubscription,
    );
  }

  static Future<int> updatedSubscription(
    SubscriptionModel model,
    String collName,
  ) async {
    return await _ac(
      <String, dynamic>{
        ActionDataModel.updatedSubscription: model.toMap(),
        'cn': collName,
      },
      ActionDataModel.updatedSubscription,
    );
  }

  static Future<int> deletedSubscription(
    SubscriptionModel model,
    String collName,
  ) async {
    return await _ac(
      <String, dynamic>{
        ActionDataModel.deletedSubscription: model.toMap(),
        'cn': collName,
      },
      ActionDataModel.deletedSubscription,
    );
  }

  static Future<int> createdRank(
    RankModel model,
    String collName,
  ) async {
    return await _ac(
      <String, dynamic>{
        ActionDataModel.createdRank: model.toMap(),
        'cn': collName,
      },
      ActionDataModel.createdRank,
    );
  }

  static Future<int> updatedRank(
    RankModel model,
    String collName,
  ) async {
    return await _ac(
      <String, dynamic>{
        ActionDataModel.updatedRank: model.toMap(),
        'cn': collName,
      },
      ActionDataModel.updatedRank,
    );
  }

  static Future<int> deletedRank(
    RankModel model,
    String collName,
  ) async {
    return await _ac(
      <String, dynamic>{
        ActionDataModel.deletedRank: model.toMap(),
        'cn': collName,
      },
      ActionDataModel.deletedRank,
    );
  }

  static Future<int> createdCurrency(
    CurrencyModel model,
    String collName,
  ) async {
    return await _ac(
      <String, dynamic>{
        ActionDataModel.createdCurrency: model.toMap(),
        'cn': collName,
      },
      ActionDataModel.createdCurrency,
    );
  }

  static Future<int> updatedCurrency(
    CurrencyModel model,
    String collName,
  ) async {
    return await _ac(
      <String, dynamic>{
        ActionDataModel.updatedCurrency: model.toMap(),
        'cn': collName,
      },
      ActionDataModel.updatedCurrency,
    );
  }

  static Future<int> deletedCurrency(
    CurrencyModel model,
    String collName,
  ) async {
    return await _ac(
      <String, dynamic>{
        ActionDataModel.deletedCurrency: model.toMap(),
        'cn': collName,
      },
      ActionDataModel.deletedCurrency,
    );
  }

  static Future<int> createdTreeMainAccount(
    TreeMainAccountModel model,
    String collName,
  ) async {
    return await _ac(
      <String, dynamic>{
        ActionDataModel.createdTreeMainAccount: model.toMap(),
        'cn': collName,
      },
      ActionDataModel.createdTreeMainAccount,
    );
  }

  static Future<int> updatedTreeMainAccount(
    TreeMainAccountModel model,
    String collName,
  ) async {
    return await _ac(
      <String, dynamic>{
        ActionDataModel.updatedTreeMainAccount: model.toMap(),
        'cn': collName,
      },
      ActionDataModel.updatedTreeMainAccount,
    );
  }

  static Future<int> deletedTreeMainAccount(
    TreeMainAccountModel model,
    String collName,
  ) async {
    return await _ac(
      <String, dynamic>{
        ActionDataModel.deletedTreeMainAccount: model.toMap(),
        'cn': collName,
      },
      ActionDataModel.deletedTreeMainAccount,
    );
  }

  static Future<int> createdTreeSubAccount(
    TreeSubAccountModel model,
    String collName,
  ) async {
    return await _ac(
      <String, dynamic>{
        ActionDataModel.createdTreeSubAccount: model.toMap(),
        'cn': collName,
      },
      ActionDataModel.createdTreeSubAccount,
    );
  }

  static Future<int> updatedTreeSubAccount(
    TreeSubAccountModel model,
    String collName,
  ) async {
    return await _ac(
      <String, dynamic>{
        ActionDataModel.updatedTreeSubAccount: model.toMap(),
        'cn': collName,
      },
      ActionDataModel.updatedTreeSubAccount,
    );
  }

  static Future<int> deletedTreeSubAccount(
    TreeSubAccountModel model,
    String collName,
  ) async {
    return await _ac(
      <String, dynamic>{
        ActionDataModel.deletedTreeSubAccount: model.toMap(),
        'cn': collName,
      },
      ActionDataModel.deletedTreeSubAccount,
    );
  }

  static Future<int> createdUser(
    UserModel model,
    String collName,
  ) async {
    return await _ac(
      <String, dynamic>{
        ActionDataModel.createdUser: model.toMap(),
        'cn': collName,
      },
      ActionDataModel.createdUser,
    );
  }

  static Future<int> updatedUser(
    UserModel model,
    String collName,
  ) async {
    return await _ac(
      <String, dynamic>{
        ActionDataModel.updatedUser: model.toMap(),
        'cn': collName,
      },
      ActionDataModel.updatedUser,
    );
  }

  static Future<int> deletedUser(
    UserModel model,
    String collName,
  ) async {
    return await _ac(
      <String, dynamic>{
        ActionDataModel.deletedUser: model.toMap(),
        'cn': collName,
      },
      ActionDataModel.deletedUser,
    );
  }

  // cb = create bill | db = deleted bill = | rb = reprinted bill
  // cnb = canceld bill |
  static Future<int> createdBill(BillModel model, int billNumber) async {
    return await _ac(
      <String, dynamic>{
        ActionDataModel.createdABill: model.toMap(),
        'bno': billNumber,
      },
      ActionDataModel.createdABill,
    );
  }

  static Future<int> updatedBill(BillModel model, int billNumber) async {
    return await _ac(
      <String, dynamic>{
        ActionDataModel.updatedABill: model.toMap(),
        'bno': billNumber,
      },
      ActionDataModel.updatedABill,
    );
  }

  static Future<int> returnedBill(BillModel model, int billNumber) async {
    return await _ac(
      <String, dynamic>{
        ActionDataModel.returnedABill: model.toMap(),
        'bno': billNumber,
      },
      ActionDataModel.returnedABill,
    );
  }

  static Future<int> canceledBill(BillModel model, int billNumber) async {
    return await _ac(
      <String, dynamic>{
        ActionDataModel.canceledABill: model.toMap(),
        'bno': billNumber,
      },
      ActionDataModel.canceledABill,
    );
  }

  static Future<int> printedBill(BillModel model, int billNumber) async {
    return await _ac(
      <String, dynamic>{
        ActionDataModel.printedABill: model.toMap(),
        'bno': billNumber,
      },
      ActionDataModel.printedABill,
    );
  }

  static Future<int> createReceipt(
      ReceiptModel model, int receiptNumber) async {
    return await _ac(
      <String, dynamic>{
        ActionDataModel.createdAReceipt: model.toMap(),
        'rcptno': receiptNumber,
      },
      ActionDataModel.createdAReceipt,
    );
  }

  static Future<int> canceledReceipt(
      ReceiptModel model, int receiptNumber) async {
    return await _ac(
      <String, dynamic>{
        ActionDataModel.canceledAReceipt: model.toMap(),
        'rcptno': receiptNumber,
      },
      ActionDataModel.canceledAReceipt,
    );
  }

  static Future<int> updatedReceipt(
      ReceiptModel model, int receiptNumber) async {
    return await _ac(
      <String, dynamic>{
        ActionDataModel.updatedAReceipt: model.toMap(),
        'rcptno': receiptNumber,
      },
      ActionDataModel.updatedAReceipt,
    );
  }

  static Future<int> returnedReceipt(
      ReceiptModel model, int receiptNumber) async {
    return await _ac(
      <String, dynamic>{
        ActionDataModel.returnedAReceipt: model.toMap(),
        'rcptno': receiptNumber,
      },
      ActionDataModel.returnedAReceipt,
    );
  }

  static Future<int> printedReceipt(
      ReceiptModel model, int receiptNumber) async {
    return await _ac(
      <String, dynamic>{
        ActionDataModel.printedAReceipt: model.toMap(),
        'rcptno': receiptNumber,
      },
      ActionDataModel.printedAReceipt,
    );
  }

  static Future<int> signin() async {
    var user = UserModel.stored!;
    return await _ac(
      <String, dynamic>{
        ActionDataModel.signin: user.toMap(),
      },
      ActionDataModel.signin,
    );
  }

  static Future<int> signout() async {
    var user = UserModel.stored!;
    return await _ac(
      <String, dynamic>{
        ActionDataModel.signout: user.toMap(),
      },
      ActionDataModel.signout,
    );
  }

  static Future<int> startedDay(DateTime day) async {
    return await _ac(
      <String, dynamic>{
        'dy': day,
      },
      ActionDataModel.startedADay,
    );
  }

  static Future<int> endedTheDay(DateTime day) async {
    return await _ac(
      <String, dynamic>{
        'dy': day,
      },
      ActionDataModel.endedADay,
    );
  }

  static Future<int> startedNewShift(ShiftModel model, int number) async {
    return await _ac(
      <String, dynamic>{
        ActionDataModel.startedAShift: model.toMap(),
        'no': number,
      },
      ActionDataModel.startedAShift,
    );
  }

  static Future<int> endedTheShift(ShiftModel model, int number) async {
    return await _ac(
      <String, dynamic>{
        ActionDataModel.endedAShift: model.toMap(),
        'no': number,
      },
      ActionDataModel.endedAShift,
    );
  }

  static Future<int> _ac(Map<String, dynamic> metaData, String action) async {
    var user = UserModel.stored;
    var nId = ProcessesModel.stored!.requestActionId();
    var actionId =
        '${DateTime.now().year}-${DateTime.now().month}.${SystemNodeModel.stored!.deviceId}-$nId';
    var actionData = ActionDataModel(
      actionId,
      action: action,
      firstname: '${user?.firstname}',
      lastname: '${user?.lastname}',
      metaData: metaData,
      time: DateTime.now(),
    );
    var r = await SystemMDBService.db.collection('actions').insert(
          actionData.toMap(),
        );
    await syncSvc?.sendAction(actionData);
    print(r);
    return 1;
  }
}
