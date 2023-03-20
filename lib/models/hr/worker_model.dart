import 'dart:async';
import 'dart:convert';

import 'package:mongo_dart/mongo_dart.dart';

import '../../utils/system_db.dart';

enum Period {
  monthly,
  yearly,
  hourly,
  daily,
}

Map<Period, String> periodsTranslations = {
  Period.hourly: 'بالساعة',
  Period.daily: 'يومي',
  Period.monthly: 'شهري',
  Period.yearly: 'سنوي',
};

Period getPeriodFromString(String period) {
  switch (period) {
    case 'Period.hourly':
      return Period.hourly;
    case 'Period.daily':
      return Period.daily;
    case 'Period.monthly':
      return Period.monthly;
    case 'Period.yearly':
      return Period.yearly;
    default:
      throw 'There is no match for period name: $period';
  }
}

// Credit types
class WorkerModel {
  WorkerModel(
    this.id, {
    required this.firstName,
    required this.lastName,
    required this.phoneNumber,
    required this.email,
    required this.totalWanted,
    required this.salary,
    required this.debtCeiling,
    required this.salaryPeriod,
    required this.createDate,
  });

  int id;
  String firstName;
  String lastName;
  String phoneNumber;
  String email;
  double totalWanted;
  double salary;
  double debtCeiling;
  Period salaryPeriod;
  late DateTime createDate;

  static WorkerModel fromMap(Map<String, dynamic> data) {
    WorkerModel model = WorkerModel(
      data['id'],
      email: data['email'],
      salary: data['salary'],
      lastName: data['lastName'],
      firstName: data['firstName'],
      phoneNumber: data['phoneNumber'],
      totalWanted: data['totalWanted'],
      debtCeiling: data['debtCeiling'],
      salaryPeriod: getPeriodFromString(data['salaryPeriod']),
      createDate: data['createDate'],
    );
    return model;
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'email': email,
        'salary': salary,
        'lastName': lastName,
        'firstName': firstName,
        'createDate': createDate,
        'phoneNumber': phoneNumber,
        'totalWanted': totalWanted,
        'debtCeiling': debtCeiling,
        'salaryPeriod': salaryPeriod.toString(),
      };

  String toJson() => json.encode(toMap());

  static WorkerModel fromJson(String jsn) {
    return fromMap(json.decode(jsn));
  }

  static Future<List<WorkerModel>> getAll() {
    List<WorkerModel> catgs = [];
    return SystemMDBService.db
        .collection('workers')
        .find()
        .transform<WorkerModel>(
          StreamTransformer.fromHandlers(
            handleData: (data, sink) {
              sink.add(WorkerModel.fromMap(data));
            },
          ),
        )
        .listen((subCatg) {
          catgs.add(subCatg);
        })
        .asFuture()
        .then((value) => catgs);
  }

  static Stream<WorkerModel> stream() {
    return SystemMDBService.db.collection('workers').find().transform(
      StreamTransformer.fromHandlers(
        handleData: (data, sink) {
          sink.add(WorkerModel.fromMap(data));
        },
      ),
    );
  }

  Future<WorkerModel?> aggregate(List<dynamic> pipeline) async {
    var d = await SystemMDBService.db.collection('workers').aggregate(pipeline);

    return WorkerModel.fromMap(d);
  }

  static Future<WorkerModel?> get(int id) async {
    var d = await SystemMDBService.db
        .collection('workers')
        .findOne(where.eq('id', id));
    if (d == null) {
      return null;
    }
    return WorkerModel.fromMap(d);
  }

  Future<WorkerModel?> edit() async {
    var r = await SystemMDBService.db.collection('workers').update(
          where.eq('id', id),
          toMap(),
        );
    print(r);
    return this;
  }

  Future<int> delete([int? id]) async {
    var r = await SystemMDBService.db.collection('workers').remove(
          where.eq('id', id),
        );
    print(r);
    return 1;
  }

  Future<WorkerModel> add() async {
    var r = await SystemMDBService.db.collection('workers').insert(
          toMap(),
        );
    print(r);
    return this;
  }
}
