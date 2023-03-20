import 'package:hive/hive.dart';
import 'package:mongo_dart/mongo_dart.dart';

import 'hdb.dart';

class HDb<E> extends Db {
  late String hiveDatabasePath;
  HDb(this.hiveDatabasePath) : super('');

  static Future<HDb> create(String hiveDatabasePath,
      [String? debugInfo]) async {
    var hdb = HDb(hiveDatabasePath);
    return hdb;
  }

  @override
  HDbCollection collection(String collectionName) {
    // var hDbC = HDbCollection(this, collectionName);
    // if (hDbC.isOpen) { return hDbC; } else { return await hDbC.open(); }
    return HDbCollection(this, collectionName);
  }

  @override
  Future<void> open(
      {WriteConcern writeConcern = WriteConcern.acknowledged,
      bool secure = false,
      bool tlsAllowInvalidCertificates = false,
      String? tlsCAFile,
      String? tlsCertificateKeyFile,
      String? tlsCertificateKeyFilePassword}) async {
    Hive.init(hiveDatabasePath);
  }

  @override
  Future<void> drop() async {
    await Hive.deleteFromDisk();
  }

  @override
  Future<Map<String, dynamic>> removeFromCollection(String collectionName,
      [Map<String, dynamic> selector = const {}, WriteConcern? writeConcern]) {
    throw UnimplementedError();
  }

  @override
  Future<Map<String, dynamic>> getLastError(
      [WriteConcern? writeConcern]) async {
    throw UnimplementedError();
  }

  @override
  Future<Map<String, dynamic>> isMaster({Connection? connection}) =>
      throw UnimplementedError();

  @override
  Future<void> close() async {}

  @override
  Future<List> listDatabases() async {
    throw UnimplementedError();
  }

  @override
  Future<List<String?>> getCollectionNames(
      [Map<String, dynamic> filter = const {}]) {
    throw UnimplementedError();
  }

  @override
  Future<bool> authenticate(String userName, String password,
      {Connection? connection}) async {
    throw UnimplementedError();
  }

  @override
  Future<Map<String, dynamic>> createIndex(String collectionName,
      {String? key,
      Map<String, dynamic>? keys,
      bool? unique,
      bool? sparse,
      bool? background,
      bool? dropDups,
      Map<String, dynamic>? partialFilterExpression,
      String? name}) {
    throw UnimplementedError();
  }

  @override
  Future<Map<String, Object?>> serverStatus(
      {Map<String, Object>? options}) async {
    throw UnimplementedError();
  }

  @override
  // ignore: avoid_renaming_method_parameters
  Future<Map<String, Object?>> createCollection(String collectionName,
      {CreateCollectionOptions? createCollectionOptions,
      Map<String, Object>? rawOptions}) async {
    HDbCollection(this, collectionName);
    return {};
  }

  @override
  Future<Map<String, Object?>> createView(
      String view, String source, List pipeline,
      {CreateViewOptions? createViewOptions,
      Map<String, Object>? rawOptions}) async {
    throw UnimplementedError();
  }

  @override
  Stream<Map<String, dynamic>> aggregate(List<Map<String, Object>> pipeline,
      {bool? explain,
      Map<String, Object>? cursor,
      String? hint,
      Map<String, Object>? hintDocument,
      AggregateOptions? aggregateOptions,
      Map<String, Object>? rawOptions}) {
    throw UnimplementedError();
  }
}
