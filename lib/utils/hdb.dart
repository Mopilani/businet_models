import 'package:hive/hive.dart';
import 'package:mongo_dart/mongo_dart.dart' hide Box;

import 'hcol.dart';

class HDbCollection extends DbCollection {
  late HDb hdb;
  late Box<Map<dynamic, dynamic>> box;

  @override
  // ignore: overridden_fields
  late String collectionName;

  @override
  HDbCollection(this.hdb, this.collectionName) : super(Db(''), '') {
    // try {

    // box = Hive.box<E>(collectionName);
    // }catch (e) {
    //   if(e.toString().contains('Did you forget to call Hive.openBox()')){
    // () async {
    //   box = await Hive.box<Map<String, dynamic>>(collectionName);
    // }()
    //     .asStream()
    //     .listen(
    //   (event) {},
    //   onDone: () {
    //     print('Stream Done 1');
    //   },
    // );
    box = Hive.box<Map<dynamic, dynamic>>(collectionName);
    // print('Stream Done 2');
  }

  bool get isOpen => box.isOpen;

  // Future<HDbCollection> open() async {
  //   box = await Hive.openBox(box.name);
  //   return this;
  // }

  @override
  Future<Map<String, dynamic>> insertAll(List<Map<String, dynamic>> documents,
      {WriteConcern? writeConcern}) async {
    await box.addAll(documents);
    return <String, dynamic>{};
  }

  @override
  Future<Map<String, dynamic>> update(selector, document,
      {bool upsert = false,
      bool multiUpdate = false,
      WriteConcern? writeConcern}) async {
    var id = document['_hid'];
    await box.put(id, document);
    return document;
  }

  @override
  Stream<Map<String, dynamic>> find([selector]) async* {
    var kSelector = selector as SelectorBuilder?;
    print(kSelector?.paramLimit);
    print(kSelector?.paramSkip);
    if (selector != null) {
      MapEntry entry;
      List<Map<dynamic, dynamic>> items;
      if (kSelector!.paramLimit > 0) {
        int limit = kSelector.paramLimit;
        var count = 0;
        items = box.values.toList();
        // print('items: $items');
        for (var index = kSelector.paramSkip; index < items.length; index++) {
          var value = items[index];
          count++;
          if (count >= limit) break;
          // print(value);
          yield {...value};
        }
      } else {
        items = <Map<dynamic, dynamic>>[];
      }

      for (var element in kSelector.map.entries) {
        if (element.value is String) {
          if (!element.key.contains('comment') ||
              !element.key.contains('hint')) {
            entry = element;

            for (var i = 0; i < items.length; i++) {
              Map<dynamic, dynamic> value = items[i];
              if (value[entry.key] == entry.value) {
                yield {...value, '_hid': i};
              }
            }
            break;
          }
        }
      }
    } else {
      var valuesList = box.values.toList();
      for (var i = 0; i < valuesList.length; i++) {
        Map<dynamic, dynamic> value = valuesList[i];
        yield {...value, '_hid': i};
      }
    }
    // return Stream.fromIterable(<Map<String, dynamic>>[...box.values]);
  }

  @override
  Future<Map<String, dynamic>?> findOne([selector]) async {
    var kSelector = selector as SelectorBuilder;
    Map map;
    print('kSelector.map: ${kSelector.map}');
    for (var element in kSelector.map.entries) {
      // if (element.value is String) {
      if (element.key == '\$query') {
        // if (!element.key.contains('comment') && !element.key.contains('hint')) {

        // if ((element.value as Map).keys.contains('id')) {
        // map = element.value;
        // print('The map is: $map');
        // print('box.values: ${box.values}');
        //   for (var value in box.values) {
        //     bool checkWantedEntries() {
        //       for (var entry in (element.value as Map).entries) {
        //         if (value[entry.key] == element.value[entry.value]) {}
        //       }
        //       return true;
        //     }

        //     var r = checkWantedEntries();
        //     if(r) {

        //     }

        // var desiredSimilarityCount = map.entries.length;
        // var foundSimilarityCount = 0;
        // for (MapEntry entry in map.entries) {
        //   if (value[entry.key] == entry.value) {
        //     foundSimilarityCount++;
        //   }
        // }
        // if (foundSimilarityCount == desiredSimilarityCount) {
        //   return {...value};
        // }
        //   }
        //   break;
        // }

        // if ((element.value as Map).keys.contains('id')) {
        map = element.value;
        // print('The map is: $map');
        // print('box.values: ${box.values}');
        var valuesList = box.values.toList();
        for (var i = 0; i < valuesList.length; i++) {
          var value = valuesList[i];
          var desiredSimilarityCount = map.entries.length;
          var foundSimilarityCount = 0;
          for (MapEntry entry in map.entries) {
            if (value[entry.key] == entry.value) {
              foundSimilarityCount++;
            }
          }
          if (foundSimilarityCount == desiredSimilarityCount) {
            return {...value, '_hid': i};
          }
        }
        break;
        // }
      }
    }
    return null;
  }

  @override
  Future<Map<String, dynamic>?> findAndModify(
      {query,
      sort,
      bool? remove,
      update,
      bool? returnNew,
      fields,
      bool? upsert}) async {
    throw UnimplementedError();
  }

  @override
  Future<bool> drop() async {
    await Hive.deleteBoxFromDisk(box.name);
    return false;
  }

  @override
  Future<Map<String, dynamic>> remove(selector,
      {WriteConcern? writeConcern}) async {
    var kSelector = selector as SelectorBuilder;
    Map map;
    print('kSelector.map: ${kSelector.map}');
    for (var element in kSelector.map.entries) {
      if (element.key == '\$query') {
        map = element.value;
        var valuesList = box.values.toList();
        for (var i = 0; i < valuesList.length; i++) {
          var value = valuesList[i];
          var desiredSimilarityCount = map.entries.length;
          var foundSimilarityCount = 0;
          for (MapEntry entry in map.entries) {
            if (value[entry.key] == entry.value) {
              foundSimilarityCount++;
            }
          }
          if (foundSimilarityCount == desiredSimilarityCount) {
            box.delete(box.keyAt(i));
          }
        }
        break;
      }
    }
    return {'msg': 'Not Found'};
  }

  @override
  Future<int> count([selector]) async {
    throw UnimplementedError();
  }

  @override
  Future<Map<String, dynamic>> distinct(String field, [selector]) async {
    throw UnimplementedError();
  }

  @override
  Future<Map<String, dynamic>> legacyDistinct(String field, [selector]) async =>
      throw UnimplementedError();

  @override
  Stream<Map<String, dynamic>> aggregateToStream(
      List<Map<String, Object>> pipeline,
      {Map<String, Object> cursorOptions = const <String, Object>{},
      bool allowDiskUse = false}) {
    throw UnimplementedError();
  }

  @override
  Future<Map<String, dynamic>> insert(Map<String, dynamic> document,
      {WriteConcern? writeConcern}) async {
    await box.add(document);
    return {'state': 'OK'};
  }

  @override
  Future<Map<String, dynamic>> createIndex(
      {String? key,
      Map<String, dynamic>? keys,
      bool? unique,
      bool? sparse,
      bool? background,
      bool? dropDups,
      Map<String, dynamic>? partialFilterExpression,
      String? name,
      bool? modernReply}) async {
    throw UnimplementedError();
  }

  @override
  Future<BulkWriteResult> insertMany(List<Map<String, dynamic>> documents,
      {WriteConcern? writeConcern,
      bool? ordered,
      bool? bypassDocumentValidation}) async {
    throw UnimplementedError();
  }

  @override
  Future<WriteResult> insertOne(Map<String, dynamic> document,
      {WriteConcern? writeConcern, bool? bypassDocumentValidation}) async {
    await box.add(document);
    try {
      throw UnimplementedError('Done Worry :p');
    } catch (e) {
      if (true) if (true) if (true) if (true) if (true) if (true) rethrow;
    }
  }

  @override
  Future<WriteResult> deleteMany(selector,
      {WriteConcern? writeConcern,
      CollationOptions? collation,
      String? hint,
      Map<String, Object>? hintDocument}) async {
    throw UnimplementedError();
  }

  @override
  Future<WriteResult> deleteOne(selector,
      {WriteConcern? writeConcern,
      CollationOptions? collation,
      String? hint,
      Map<String, Object>? hintDocument}) async {
    throw UnimplementedError();
  }

  @override
  Future<WriteResult> replaceOne(selector, Map<String, dynamic> update,
      {bool? upsert,
      WriteConcern? writeConcern,
      CollationOptions? collation,
      String? hint,
      Map<String, Object>? hintDocument}) async {
    throw UnimplementedError();
  }

  @override
  Future<WriteResult> updateMany(selector, update,
      {bool? upsert,
      WriteConcern? writeConcern,
      CollationOptions? collation,
      List? arrayFilters,
      String? hint,
      Map<String, Object>? hintDocument}) {
    throw UnimplementedError();
  }

  @override
  Future<WriteResult> updateOne(selector, update,
      {bool? upsert,
      WriteConcern? writeConcern,
      CollationOptions? collation,
      List? arrayFilters,
      String? hint,
      Map<String, Object>? hintDocument}) {
    throw UnimplementedError();
  }

  @override
  Stream watch(Object pipeline,
      {int? batchSize,
      String? hint,
      Map<String, Object>? hintDocument,
      ChangeStreamOptions? changeStreamOptions,
      Map<String, Object>? rawOptions}) {
    throw UnimplementedError();
  }
}
