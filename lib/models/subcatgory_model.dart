import 'dart:async';
import 'dart:convert';

import 'package:mongo_dart/mongo_dart.dart';

import '../utils/system_db.dart';
import 'category_model.dart';

class SubCatgModel {
  SubCatgModel(
    this.id,
    this.subcatgoryName,
    this.subcatgoryDescription,
    this.category, {
    this.imageUrl,
  });

  SubCatgModel._();

  dynamic id;
  late String subcatgoryName;
  late String subcatgoryDescription;
  late CategoryModel category;
  String? imageUrl;

  static const String collectionName = 'subcatgs';

  static SubCatgModel fromMap(Map<String, dynamic> data) {
    SubCatgModel model = SubCatgModel._();
    model.id = data['id'];
    model.subcatgoryName = data['subcatgoryName'];
    model.subcatgoryDescription = data['subcatgoryDescription'];
    model.imageUrl = data['imageUrl'];
    data['category'] == null
        ? null
        : model.category = CategoryModel.fromMap({...data['category']});
    return model;
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'subcatgoryName': subcatgoryName,
        'subcatgoryDescription': subcatgoryDescription,
        'imageUrl': imageUrl,
        'category': () {
          try {
            return category.toMap();
          } catch (e) {
            return null;
          }
        }(),
      };

  String toJson() => json.encode(toMap());

  static SubCatgModel fromJson(String jsn) {
    return fromMap(json.decode(jsn));
  }

  static Future<List<SubCatgModel>> getAll() {
    List<SubCatgModel> models = [];
    return SystemMDBService.db
        .collection(collectionName)
        .find()
        .transform<SubCatgModel>(
          StreamTransformer.fromHandlers(
            handleData: (data, sink) {
              sink.add(SubCatgModel.fromMap(data));
            },
          ),
        )
        .listen((subCatg) {
          models.add(subCatg);
        })
        .asFuture()
        .then((value) => models);
  }

  Stream<SubCatgModel>? stream() {
    return SystemMDBService.db.collection(collectionName).find().transform(
      StreamTransformer.fromHandlers(
        handleData: (data, sink) {
          sink.add(SubCatgModel.fromMap(data));
        },
      ),
    );
  }

  Future<SubCatgModel?> aggregate(List<dynamic> pipeline) async {
    var d = await SystemMDBService.db
        .collection(collectionName)
        .aggregate(pipeline);

    return SubCatgModel.fromMap(d);
  }

  static Future<SubCatgModel?> get(int id) async {
    var d = await SystemMDBService.db
        .collection(collectionName)
        .findOne(where.eq('id', id));
    if (d == null) {
      return null;
    }
    return SubCatgModel.fromMap(d);
  }

  static Future<SubCatgModel?> findById(int id) async {
    var d = await SystemMDBService.db
        .collection(collectionName)
        .findOne(where.eq('id', id));
    if (d == null) {
      return null;
    }
    return SubCatgModel.fromMap(d);
  }

  Future<SubCatgModel?> edit() async {
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
}
