import 'dart:async';
import 'dart:convert';

import 'package:mongo_dart/mongo_dart.dart';

import '../../utils/enums.dart';
import '../../utils/system_db.dart';
import 'transaction_model.dart';

Map<dynamic, String> accountTypeTranslations = {
  AccountType.bankAccount: 'حساب بنكي',
  AccountType.creditCard: 'بطاقة إئتمان',
  AccountType.moneyDrawer: 'درج',
  AccountType.moneySafe: 'خزنة',
};

enum AccountType {
  moneyDrawer,
  bankAccount,
  creditCard,
  moneySafe,
}

AccountType accountTypeFromString(String accountTypeStr) {
  switch (accountTypeStr) {
    case 'AccountType.bankAccount':
      return AccountType.bankAccount;
    case 'AccountType.creditCard':
      return AccountType.creditCard;
    case 'AccountType.moneySafe':
      return AccountType.moneySafe;
    case 'AccountType.moneyDrawer':
      return AccountType.moneyDrawer;
    default:
      throw 'Account Type $accountTypeStr Not Registered';
  }
}

AccountSubtype accountSubtypeFromString(String accountSubtypeStr) {
  switch (accountSubtypeStr) {
    case 'AccountSubtype.assetAccount':
      return AccountSubtype.assetAccount;
    case 'AccountSubtype.liabilitiesAccount':
      return AccountSubtype.liabilitiesAccount;
    case 'AccountSubtype.savingAccount':
      return AccountSubtype.savingAccount;
    default:
      throw 'Account Sub Type $accountSubtypeStr Not Registered';
  }
}

Map<dynamic, String> accountSubtypeTranslations = {
  AccountSubtype.assetAccount: 'حساب اصول',
  AccountSubtype.savingAccount: 'حساب ادخار',
  AccountSubtype.liabilitiesAccount: 'حساب خصوم',
};

enum AccountSubtype {
  assetAccount,
  savingAccount,
  liabilitiesAccount,
}

class MoneyAccount {
  MoneyAccount(
    this.id, {
    required this.accountName,
    required this.accountType,
    required this.accountSubtype,
    required this.money,
  });

  MoneyAccount._();

  late int id;
  late String accountName;
  late AccountType accountType;
  late AccountSubtype accountSubtype;
  late double money;

  static const String collectionName = 'moneyaccounts'; 

  /// Note: this field is
  // late List<TransactionModel>
  //     trafficLog; // formated as ; '$value:out' | '$value:in' | reason

  static MoneyAccount fromMap(Map<String, dynamic> data) {
    MoneyAccount model = MoneyAccount._();
    model.id = data['id'];
    model.accountName = data['accountName'];
    model.accountType = accountTypeFromString(data['accountType']);
    model.accountSubtype = accountSubtypeFromString(data['accountSubtype']);
    // model.accountType = AccountType.moneySafe;
    // model.accountSubtype = AccountSubtype.liabilitiesAccount;
    // model.trafficLog = (data['trafficLog']).map((v) {
    //   return TransactionModel.fromMap(v);
    // }).toList();
    model.money = data['money'];
    return model;
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'accountName': accountName,
        'accountType': accountType.toString(),
        'accountSubtype': accountSubtype.toString(),
        // 'trafficLog': trafficLog.map((e) => e.toMap()).toList(),
        'money': money,
      };

  String toJson() => json.encode(toMap());

  static MoneyAccount fromJson(String jsn) {
    return fromMap(json.decode(jsn));
  }

  static Future<List<MoneyAccount>> getAll() {
    List<MoneyAccount> models = [];
    return SystemMDBService.db
        .collection(collectionName)
        .find()
        .transform<MoneyAccount>(
          StreamTransformer.fromHandlers(
            handleData: (data, sink) {
              sink.add(MoneyAccount.fromMap(data));
            },
          ),
        )
        .listen((model) {
          models.add(model);
        })
        .asFuture()
        .then((value) => models);
  }

  Stream<MoneyAccount>? stream() {
    return SystemMDBService.db.collection(collectionName).find().transform(
      StreamTransformer.fromHandlers(
        handleData: (data, sink) {
          sink.add(MoneyAccount.fromMap(data));
        },
      ),
    );
  }

  Future<MoneyAccount?> aggregate(List<dynamic> pipeline) async {
    var d = await SystemMDBService.db
        .collection(collectionName)
        .aggregate(pipeline);

    return MoneyAccount.fromMap(d);
  }

  Future<MoneyAccount?> get(int id) async {
    var d = await SystemMDBService.db
        .collection(collectionName)
        .findOne(where.eq('id', id));
    if (d == null) {
      return null;
    }
    return MoneyAccount.fromMap(d);
  }

  static Future<MoneyAccount?> findById(int id) async {
    var d = await SystemMDBService.db
        .collection(collectionName)
        .findOne(where.eq('id', id));
    if (d == null) {
      return null;
    }
    return MoneyAccount.fromMap(d);
  }

  Future<MoneyAccount?> edit() async {
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

  Future<void> recordTransaction(TransactionModel transaction) async {
    if (transaction.type == TransactionType.income) {
      money += transaction.value;
    } else if (transaction.type == TransactionType.outcome) {
      money -= transaction.value;
    }
    transaction.account = this;
    await transaction.add();
  }
}
