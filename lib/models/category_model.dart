import 'dart:async';
import 'dart:convert';

import 'package:mongo_dart/mongo_dart.dart';

import '../utils/system_db.dart';
import 'sales/sku_model.dart';

class CategoryModel {
  CategoryModel._();
  CategoryModel(this.id, this.catgoryName, this.catgoryDescription);
  dynamic id;
  late String catgoryName;
  late String catgoryDescription;

  static const String collectionName = 'categories';

  static CategoryModel fromMap(Map<String, dynamic> data) {
    CategoryModel model = CategoryModel._();
    model.id = data['id'];
    model.catgoryName = data['catgoryName'];
    model.catgoryDescription = data['catgoryDescription'];
    return model;
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'catgoryName': catgoryName,
        'catgoryDescription': catgoryDescription,
      };

  String toJson() => json.encode(toMap());

  static CategoryModel fromJson(String jsn) {
    return fromMap(json.decode(jsn));
  }

  static Future<List<CategoryModel>> getAll() {
    List<CategoryModel> catgs = [];
    return SystemMDBService.db
        .collection(collectionName)
        .find()
        .transform<CategoryModel>(
          StreamTransformer.fromHandlers(
            handleData: (data, sink) {
              sink.add(CategoryModel.fromMap(data));
            },
          ),
        )
        .listen((subCatg) {
          catgs.add(subCatg);
        })
        .asFuture()
        .then((value) => catgs);
  }

  Stream<CategoryModel>? stream() {
    return SystemMDBService.db.collection(collectionName).find().transform(
      StreamTransformer.fromHandlers(
        handleData: (data, sink) {
          sink.add(CategoryModel.fromMap(data));
        },
      ),
    );
  }

  Future<CategoryModel?> aggregate(List<dynamic> pipeline) async {
    var d =
        await SystemMDBService.db.collection(collectionName).aggregate(pipeline);

    return CategoryModel.fromMap(d);
  }

  static Future<CategoryModel?> get(int id) async {
    var d = await SystemMDBService.db
        .collection(collectionName)
        .findOne(where.eq('id', id));
    if (d == null) {
      return null;
    }
    return CategoryModel.fromMap(d);
  }

  static Future<CategoryModel?> findById(int id) async {
    var d = await SystemMDBService.db
        .collection(collectionName)
        .findOne(where.eq('id', id));
    if (d == null) {
      return null;
    }
    return CategoryModel.fromMap(d);
  }

  Future<CategoryModel?> edit() async {
    var r = await SystemMDBService.db.collection(collectionName).update(
          where.eq('id', id),
          toMap(),
        );
    print(r);
    return this;
  }

  Future<int> delete() async {
    var skuStream = SKUModel.stream();
    bool canBeDeleted = true;
    skuStream.listen((sku) {
      if (sku.categoryModel!.catgoryName == catgoryName) {
        canBeDeleted = false;
      }
    });
    if (!canBeDeleted) {
      return -1;
    }
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
}
