import 'dart:async';
import 'dart:convert';

import 'package:mongo_dart/mongo_dart.dart';

import '../../utils/system_db.dart';
import 'sku_model.dart';


class ExpierControllerModel {
  ExpierControllerModel({
    required this.sku,
    required this.expierDate,
    required this.expiered,
    required billCreateTime,
  }) {
    id = '$billCreateTime-${sku.id}-$expierDate';
    // id = '${dateTimeToString(DateTime.now())}-${sku.id}-$expierDate';
    createDate = DateTime.now();
  }

  dynamic id;
  late DateTime expierDate;
  late DateTime createDate;
  // late DateTime billCreateTime;
  late SKUModel sku;
  late bool expiered;

  static ExpierControllerModel fromMap(Map<String, dynamic> data) {
    // print('================');
    // print(data);
    ExpierControllerModel model = ExpierControllerModel(
      sku: SKUModel.fromMap(data['sku']),
      expierDate: data['expierDate'],
      expiered: data['expiered'],
      billCreateTime: null,
    );
    model.id = data['id'];
    model.createDate =
        data['createDate'] ?? DateTime.now(); // Fix just for debuging
    return model;
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'sku': sku.toMap(),
        'expierDate': expierDate,
        'expiered': expiered,
        'createDate': createDate,
      };

  String toJson() => json.encode(toMap());

  static ExpierControllerModel fromJson(String jsn) {
    return fromMap(json.decode(jsn));
  }

  static init() {
    ExpierControllerModel.stream().listen(
      (model) async {
        if (model.expiered) {
          // Pass
        } else {
          var r = DateTime.now().compareTo(model.expierDate);
          if (r == 1) {
            model.expiered = true;
            await model.edit();
          } else if (r == -1) {
          } else if (r == 0) {
            model.expiered = true;
            await model.edit();
          }
        }
      },
    );
  }

  static Future<List<ExpierControllerModel>> getAll() {
    List<ExpierControllerModel> catgs = [];
    return SystemMDBService.db
        .collection('expiers')
        .find()
        .transform<ExpierControllerModel>(
          StreamTransformer.fromHandlers(
            handleData: (data, sink) {
              sink.add(ExpierControllerModel.fromMap(data));
            },
          ),
        )
        .listen((subCatg) {
          catgs.add(subCatg);
        })
        .asFuture()
        .then((value) => catgs);
  }

  static Stream<ExpierControllerModel> stream() {
    return SystemMDBService.db.collection('expiers').find().transform(
      StreamTransformer.fromHandlers(
        handleData: (data, sink) {
          sink.add(ExpierControllerModel.fromMap(data));
        },
      ),
    );
  }

  Future<ExpierControllerModel?> aggregate(List<dynamic> pipeline) async {
    var d = await SystemMDBService.db.collection('expiers').aggregate(pipeline);

    return ExpierControllerModel.fromMap(d);
  }

  static Future<ExpierControllerModel?> get(String id) async {
    var d = await SystemMDBService.db
        .collection('expiers')
        .findOne(where.eq('id', id));
    if (d == null) {
      return null;
    }
    return ExpierControllerModel.fromMap(d);
  }

  static Future<ExpierControllerModel?> findByLevelNumber(
      int levelNumber) async {
    var d = await SystemMDBService.db
        .collection('expiers')
        .findOne(where.eq('levelNumber', levelNumber));
    if (d == null) {
      return null;
    }
    print(d);
    return ExpierControllerModel.fromMap(d);
  }

  Future<ExpierControllerModel?> edit() async {
    var r = await SystemMDBService.db.collection('expiers').update(
          where.eq('id', id),
          toMap(),
        );
    print(r);
    return this;
  }

  Future<int> delete(String id) async {
    var r = await SystemMDBService.db.collection('expiers').remove(
          where.eq('id', id),
        );
    print(r);
    return 1;
  }

  Future<ExpierControllerModel> add() async {
    var r = await SystemMDBService.db.collection('expiers').insert(
          toMap(),
        );
    print(r);
    return this;
  }
}
