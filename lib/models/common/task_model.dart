import 'dart:async';
import 'dart:convert';

import 'package:businet_models/utils/enums.dart';
import 'package:mongo_dart/mongo_dart.dart';

import '../../utils/system_db.dart';

class TaskModel {
  TaskModel(
    this.id, {
    required this.from,
    required this.to,
    required this.title,
    required this.content,
    required this.createTime,
    required this.taskState,
    this.readTime,
    this.recieveTime,
  });
  dynamic id;
  late String title;
  late String from;
  late String to;
  late String content;
  late TaskState taskState;
  late DateTime createTime;
  DateTime? readTime;
  DateTime? recieveTime;

  static const String collectionName = 'tasks';

  static TaskModel fromMap(Map<String, dynamic> data) {
    TaskModel model = TaskModel(
      data['id'],
      from: data['from'],
      to: data['to'],
      title: data['title'],
      content: data['content'],
      createTime: data['createTime'],
      taskState: data['taskState'],
      readTime: data['readTime'],
      recieveTime: data['recieveTime'],
    );
    return model;
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'from': from,
        'to': to,
        'title': title,
        'content': content,
        'createTime': createTime,
        'taskState': taskState,
        'readTime': readTime,
        'recieveTime': recieveTime,
      };

  String toJson() => json.encode(toMap());

  static TaskModel fromJson(String jsn) {
    return fromMap(json.decode(jsn));
  }

  static Future<List<TaskModel>> getAll() {
    List<TaskModel> catgs = [];
    return SystemMDBService.db
        .collection(collectionName)
        .find()
        .transform<TaskModel>(
          StreamTransformer.fromHandlers(
            handleData: (data, sink) {
              sink.add(TaskModel.fromMap(data));
            },
          ),
        )
        .listen((subCatg) {
          catgs.add(subCatg);
        })
        .asFuture()
        .then((value) => catgs);
  }

  Stream<TaskModel>? stream() {
    return SystemMDBService.db.collection(collectionName).find().transform(
      StreamTransformer.fromHandlers(
        handleData: (data, sink) {
          sink.add(TaskModel.fromMap(data));
        },
      ),
    );
  }

  Future<TaskModel?> aggregate(List<dynamic> pipeline) async {
    var d = await SystemMDBService.db
        .collection(collectionName)
        .aggregate(pipeline);

    return TaskModel.fromMap(d);
  }

  static Future<TaskModel?> get(dynamic id) async {
    var d = await SystemMDBService.db
        .collection(collectionName)
        .findOne(where.eq('id', id));
    if (d == null) {
      return null;
    }
    return TaskModel.fromMap(d);
  }

  static Future<TaskModel?> findById(dynamic id) async {
    var d = await SystemMDBService.db
        .collection(collectionName)
        .findOne(where.eq('id', id));
    if (d == null) {
      return null;
    }
    return TaskModel.fromMap(d);
  }

  Future<TaskModel?> edit() async {
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
