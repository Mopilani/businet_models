import 'dart:io';
import 'dart:convert';

import 'package:businet_models/businet_models.dart';


import 'package:http/http.dart' as http;
import 'package:mongo_dart/mongo_dart.dart';
// import 'package:overlay_support/overlay_support.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';
import 'package:shelf_router/shelf_router.dart' as shelf_router;

SyncService? _cache;

List<bool> bNodesStates = [
  false,
  false,
  false,
  false,
  false,
  false,
  false,
  false,
  false,
  false,
  false,
  false,
  false,
  false,
  false,
  false,
];

String? id;

// BackupState backedOpsBackupState = BackupState.stopped;
BackupState syncOperationsState = BackupState.stopped;
BackupState dataSyncState = BackupState.stopped;
DeviceOnNetType deviceOnNetType = DeviceOnNetType.master;

enum BackupState {
  running,
  stopped,
  done,
}

enum DeviceOnNetType {
  master,
  slaveMaster,
  slave,
}

DeviceOnNetType deviceOnNetTypeFromString(String onNetTypeStr) =>
    DeviceOnNetType.values
        .where((element) => onNetTypeStr == element.toString())
        .first;

BackupState backupStateTypeFromString(String onNetTypeStr) => BackupState.values
    .where((element) => onNetTypeStr == element.toString())
    .first;

class BackupDevice {
  BackupDevice(
    this.id, {
    required this.deviceOnNetType,
    required this.ip,
  });
  String id;
  String ip;
  DeviceOnNetType deviceOnNetType;

  Map<String, dynamic> toMap() => {
        'id': id,
        'ip': ip,
        'deviceOnNetType': deviceOnNetType.toString(),
      };

  static BackupDevice fromMap(Map dryData) {
    return BackupDevice(
      dryData['id'],
      ip: dryData['ip'],
      deviceOnNetType: deviceOnNetTypeFromString(dryData['deviceOnNetType']),
    );
  }
}

Map<String, BackupDevice> backupDevicesMap = {};

class SyncService {
  factory SyncService() {
    _cache ??= SyncService.init();
    return _cache!;
  }

  SyncService.init() {
    // _cache ??= SearchServiceViewModel.init();
  }

  late HttpServer server;
  String? peerAddress;
  late String archivePath;
  late InternetAddress remoteAddress;
  late bool serverStarted = false;
  int port = 4227;
  Map<String, dynamic> backedOperationsFileNames = {};
  Map<String, dynamic> operationsFolders = {};

  final router = shelf_router.Router();
  final ip = '0.0.0.0';

  Future<void> startServer() async {
    router.get('/action', _actionHandler);
    router.get('/index', _indexHandler);
    router.get('/start', _startSending);
    router.post('/update', _updateHandler);
    router.get('/fetch', (Request req) {
      print('Headers: ${req.headers}');
      final HttpConnectionInfo connectionInfo =
          req.context['shelf.io.connection_info'] as HttpConnectionInfo;
      print(
          'Remote Address ${connectionInfo.remoteAddress.host} : Length: ${connectionInfo.remoteAddress.host.length}');
      print(
          'Request Host ${req.headers['host']!.split(':').first} : Length: ${req.headers['host']!.split(':').first.length}');
      print(
          'CON.REM.ADR != REQ.URL.HST: ${connectionInfo.remoteAddress.host != req.headers['host']!.split(':').first}');
      if (req.headers['todo'] == 'inead' &&
          connectionInfo.remoteAddress.host !=
              req.headers['host']!.split(':').first) {
        remoteAddress = connectionInfo.remoteAddress;
        peerAddress = 'http://${remoteAddress.host}:$port';
        print('Some one Neads Update');

        try {
          Future.delayed(const Duration(seconds: 5), () {
            // ElegantNotification.success(
            //   title: const Text("عثر على احد الاجهزة في الشبكة"),
            //   description: const Text('تم العثور على جهاز في الشبكة'),
            // ).show(currentContext!);
          });
        } catch (e) {
          //
        }
      } else {
        return Response.seeOther(
          '',
          body: json.encode({
            'msg': 'Hello ${req.requestedUri.host} - $peerAddress - ${req.url}'
          }),
        );
      }
      return Response.ok(
        json.encode({
          'msg': 'Hello ${req.requestedUri.host} - $peerAddress - ${req.url}',
          'id': id,
          'ip': peerAddress,
          'deviceOnNetType': deviceOnNetType.toString(),
        }),
      );
    });

    // Configure a pipeline that logs requests.
    final handler =
        const Pipeline().addMiddleware(logRequests()).addHandler(router);
    stdout.writeln('Businet Backend Server - Running...');
    server = await serve(handler, ip, port);
    serverStarted = true;
    stdout.writeln('BCBSVC Server listening on port ${server.port}');
  }

  Future startTask(String contents, String collectionName) async {
    // final box = await Hive.openBox('data');
    // final lastUpdateIndex = box.get('lastUpdateIndex');
    final wantedContentsList = json.decode(contents);

    // late Uint8List bytes;
    for (final value in wantedContentsList) {
      var r = await SystemMDBService.db.collection(collectionName).findOne(
            where.eq('id', value),
          );
      if (r != null) {
        // Do some thing
      }
    }
  }

  Map<String, dynamic> mongoYaMongo = {
    'accessLevels': 'id',
    'users': 'id',
    SubscriperModel.collectionName: 'id',
    SubscriptionModel.collectionName: 'id',
    RankModel.collectionName: 'description',
    BatchModel.collectionName: 'description',
    DepartmentModel.collectionName: 'description',
  };

  Future<Response> _actionHandler(Request req) async {
    try {
      List<int> bytes = [];
      await req.read().listen((chunk) {
        bytes.addAll(chunk);
      }).asFuture<List<int>>(bytes);
      var jsonStr = utf8.decode(bytes);
      var data = json.decode(jsonStr);
      var actionModel = ActionDataModel.fromMap(data);
      var modelData = actionModel.metaData![actionModel.action];
      var collName = actionModel.metaData!['cn'];

      switch (actionModel.action) {
        case ActionDataModel.createdSubscriper:
          var model = SubscriperModel.fromMap(modelData);
          await model.addToCol(collName, true);
          break;
        case ActionDataModel.updatedSubscriper:
          var model = SubscriperModel.fromMap(modelData);
          await model.editToCol(collName, true);
          break;
        case ActionDataModel.deletedSubscriper:
          var model = SubscriperModel.fromMap(modelData);
          await model.delete(true);
          break;

        case ActionDataModel.createdSubscription:
          var model = SubscriptionModel.fromMap(modelData);
          await model.add(true);
          break;
        case ActionDataModel.updatedSubscription:
          var model = SubscriptionModel.fromMap(modelData);
          await model.edit(true);
          break;
        case ActionDataModel.deletedSubscription:
          var model = SubscriptionModel.fromMap(modelData);
          await model.delete(true);
          break;

        case ActionDataModel.createdBatch:
          var model = BatchModel.fromMap(modelData);
          await model.add(true);
          break;
        case ActionDataModel.updatedBatch:
          var model = BatchModel.fromMap(modelData);
          await model.edit(true);
          break;
        case ActionDataModel.deletedBatch:
          var model = BatchModel.fromMap(modelData);
          await (await BatchModel.findBydescription(model.description))
              ?.deleteWithMID(true);
          break;

        case ActionDataModel.createdRank:
          var model = RankModel.fromMap(modelData);
          await model.add(true);
          break;
        case ActionDataModel.updatedRank:
          var model = RankModel.fromMap(modelData);
          await model.edit(true);
          break;
        case ActionDataModel.deletedRank:
          var model = RankModel.fromMap(modelData);
          await (await RankModel.findBydescription(model.description))
              ?.deleteWithMID(true);
          break;

        case ActionDataModel.createdDepartment:
          var model = DepartmentModel.fromMap(modelData);
          await model.add(true);
          break;
        case ActionDataModel.updatedDepartment:
          var model = DepartmentModel.fromMap(modelData);
          await model.edit(true);
          break;
        case ActionDataModel.deletedDepartment:
          var model = DepartmentModel.fromMap(modelData);
          await (await DepartmentModel.findBydescription(model.description))
              ?.deleteWithMID(true);
          break;

        case ActionDataModel.createdUser:
          var model = UserModel.fromMap(modelData);
          await model.add(true);
          break;
        case ActionDataModel.updatedUser:
          var model = UserModel.fromMap(modelData);
          await model.edit(true);
          break;
        case ActionDataModel.deletedUser:
          var model = UserModel.fromMap(modelData);
          await model.delete(true);
          break;

        // case ActionDataModel.deletedSubscriper:
        //   var subsc = SubscriperModel.fromMap(modelData);
        //   await subsc.deleteFromColl(collName);
        //   break;
        default:
          print('Unkown Action ${actionModel.action}');
      }

      await ActionModel.addData(actionModel);
      return Response.ok(json.encode({
        'msg': 'OK',
      }));
    } catch (e) {
      print(e);
      return Response.internalServerError(
        body: json.encode({
          'msg': 'حدث خطأ ما اثناء كتابة الملف',
          'err': e.toString(),
        }),
      );
    }
  }

  static const String wantToBeSentCollectionName = 'wantToBeSent';
  Future<void> _addWTBS(String actionId) async {
    var col = SystemMDBService.db.collection(wantToBeSentCollectionName);
    await col.insert({actionId: DateTime.now()});
  }

  Future<void> _removeWTBS(String actionId) async {
    var col = SystemMDBService.db.collection(wantToBeSentCollectionName);
    await col.remove({actionId: DateTime.now()});
  }

  Future sendAction(ActionDataModel action) async {
    await _addWTBS(action.id);
    print('Getting Operations $dataSyncState');
    dataSyncState = BackupState.running;
    // SystemConfig.stored!.syncOperationsState = syncOperationsState;
    for (var node in backupDevicesMap.entries) {
      print('${node.value.ip} - ${node.value.deviceOnNetType}');
      http.Response res = await http.post(
        Uri.parse('${node.value.ip}/action'),
        headers: {
          // Device Name
          // Device Id
        },
        body: action.toMap(),
      );
      dynamic body;
      List<String> wantedContents = [];
      if (res.statusCode == 200) {
        body = json.decode(res.body);
        print(body['msg']);
      } else {
        return false;
      }
      res = await http.get(
        Uri.parse('${node.value.ip}/start'),
        headers: {
          'ctnts': json.encode(wantedContents),
        },
      );
      print('Response: ${res.body}');
      if (res.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    }
    await _removeWTBS(action.id);
  }

  Future<Response> _indexHandler(Request req) async {
    try {
      final indexContents = [];
      for (var entry in mongoYaMongo.entries) {
        String collectionName = entry.key;
        SystemMDBService.db.collection(collectionName).find().listen((data) {
          indexContents.add(data[entry.value]);
        });
      }
      return Response.ok(
        json.encode({
          'msg': 'Hello',
          'host': '${req.headers['host']}',
          'index': indexContents,
        }),
      );
    } catch (e) {
      print(e);
      return Response.internalServerError(
        body: json.encode({
          'msg': 'حدث خطأ ما اثناء كتابة الملف',
          'err': e.toString(),
        }),
      );
    }
  }

  Future<Response> _startSending(Request req) async {
    // ElegantNotification.success(
    //   title: const Text("سيتم البدء بإرسال التحديثات"),
    //   description: const Text(''),
    // ).show(currentContext!);
    // if (req.headers['ctnts'] != null) {
    if (req.headers['ctnts'] != null) {
      startTask(req.headers['ctnts']!, req.headers['collName']!);
      return Response.ok(
        json.encode({
          'msg': 'سيتم البدء بإرسال التحديثات في الحال',
          // 'host': '${req.headers['host']}',
        }),
      );
    } else {
      return Response.badRequest(
        body: json.encode({
          'msg': 'Contents must provided',
        }),
      );
    }
    // } else {
    //   return Response.badRequest(
    //     body: json.encode({
    //       'msg': 'Host must provided',
    //     }),
    //   );
    // }
  }

  Future<Response> _updateHandler(Request req) async {
    // if (req.headers['path'] == null) {
    //   return Response.badRequest(
    //     body: json.encode({
    //       'msg': 'Path must provided',
    //     }),
    //   );
    // }
    final List<int> bytes = [];

    int index = 0;
    String? filePath;
    await req.read().listen((chunk) {
      if (index == 0) {
        final filePathSectorBytes = chunk.sublist(0, 1024);
        filePathSectorBytes;
        filePath = utf8.decode(filePathSectorBytes);
        print('Received File: $filePath');
        stdout.writeln(chunk.sublist(1024).length);
        bytes.addAll(chunk.sublist(1024));
      } else {
        stdout.writeln(chunk.length);
        bytes.addAll(chunk);
      }
      index++;
    }).asFuture<List<int>>(bytes);
    if (filePath == null) {
      return Response.internalServerError(
        body: json.encode({
          'msg': 'ليم يتم تزويد مسار الملف: الرجاء الاتصال بالمطور',
        }),
      );
    }
    // print('Received File: ${req.headers['path']}');

    // final additionPath = req.headers['path'];

    final file = File('$archivePath/${filePath!}');
    print('File Full Path: ${file.path}, File Bytes Length: ${bytes.length}');
    // toast('جاري استلام الملف: ${file.path}');
    // ElegantNotification.success(
    //   description: Text(),
    // ).show(currentContext!);
    await file.create(recursive: true);
    print('File Created');

    try {
      print('Writing To File>>> ${bytes.length}');
      await file.writeAsBytes(bytes);
      print('Writing Done.');
      return Response.ok(
        json.encode({
          'msg': 'شكرا',
        }),
      );
    } catch (e, s) {
      stdout.writeln(e);
      stdout.writeln(s);
      return Response.internalServerError(
        body: json.encode({
          'msg': 'حدث خطأ ما اثناء كتابة الملف',
          'err': e.toString(),
        }),
      );
    }
  }

  Future<void> stop() async {
    stdout.writeln('Closing');
    await server.close(force: true);
    stdout.writeln('Closed');
    serverStarted = false;
  }

  // Future getBackedOperationsUpdates() async {
  //   print('Getting Backuped Operations $backupDevicesMap');
  //   for (var node in backupDevicesMap.entries) {
  //     print('${node.value.ip} - ${node.value.deviceOnNetType}');
  //     if (node.value.deviceOnNetType == DeviceOnNetType.master) {
  //       http.Response res = await http.get(
  //         Uri.parse('${node.value.ip}/bopsindex'),
  //         headers: {},
  //       );
  //       dynamic body;
  //       List<String> wantedContents = [];
  //       if (res.statusCode == 200) {
  //         body = json.decode(res.body);
  //         print(body['msg']);
  //         final fetchedContents = json.decode(body['index']);
  //         fetchedContents.forEach((key, value) {
  //           if (backedOperationsFileNames.containsKey(key)) {
  //           } else {
  //             wantedContents.add(key);
  //           }
  //         });
  //       } else {
  //         return false;
  //       }
  //       print('====================');
  //       print(wantedContents);
  //       final box = await Hive.openBox('data');
  //       archivePath = box.get('archivePath');
  //       // print(archivePath);
  //       var ens = Directory(archivePath).listSync();
  //       print('=============0======');
  //       for (var element in ens) {
  //         print(element.path);
  //       }
  //       print('=============0======');
  //       res = await http.get(
  //         Uri.parse('${node.value.ip}/start'),
  //         headers: {
  //           'ctnts': json.encode(wantedContents),
  //         },
  //       );
  //       print('Response: ${res.body}');
  //       if (res.statusCode == 200) {
  //         return true;
  //       } else {
  //         return false;
  //       }
  //     }
  //   }
  // }

  Future syncOperations() async {
    syncOperationsState = BackupState.running;
    SystemConfig.stored!.syncOperationsState = syncOperationsState;
    for (var node in backupDevicesMap.entries) {
      print('${node.value.ip} - ${node.value.deviceOnNetType}');
      if (node.value.deviceOnNetType == DeviceOnNetType.master) {
        http.Response res = await http.get(
          Uri.parse('${node.value.ip}/index'),
          headers: {},
        );
        dynamic body;
        List<String> wantedContents = [];
        if (res.statusCode == 200) {
          body = json.decode(res.body);
          print(body['msg']);
          final fetchedContents = json.decode(body['index']);
          final collName = json.decode(body['collName']);
          fetchedContents.forEach((key, value) {
            if (backedOperationsFileNames.containsKey(key)) {
              try {
                if (SystemMDBService.db.collection(collName).findOne(
                          where.eq('id', id),
                        ) ==
                    value['dm']) {
                } else {
                  wantedContents.add(key);
                }
              } catch (e) {
                //
              }
            } else {
              wantedContents.add(key);
            }
          });
        } else {
          return false;
        }
        res = await http.get(
          Uri.parse('${node.value.ip}/start'),
          headers: {
            'ctnts': json.encode(wantedContents),
          },
        );
        print('Response: ${res.body}');
        if (res.statusCode == 200) {
          return true;
        } else {
          return false;
        }
      }
    }
  }

  Future syncActions() async {
    print('Getting Operations $dataSyncState');
    dataSyncState = BackupState.running;
    // SystemConfig.stored!.syncOperationsState = syncOperationsState;
    for (var node in backupDevicesMap.entries) {
      print('${node.value.ip} - ${node.value.deviceOnNetType}');
      if (node.value.deviceOnNetType == DeviceOnNetType.master) {
        http.Response res = await http.get(
          Uri.parse('${node.value.ip}/sync'),
          headers: {},
        );
        dynamic body;
        List<String> wantedContents = [];
        if (res.statusCode == 200) {
          body = json.decode(res.body);
          print(body['msg']);
          final fetchedContents = json.decode(body['index']);
          final collName = json.decode(body['collName']);
          fetchedContents.forEach((key, value) {
            if (backedOperationsFileNames.containsKey(key)) {
              try {
                if (SystemMDBService.db.collection(collName).findOne(
                          where.eq('id', id),
                        ) ==
                    value['dm']) {
                } else {
                  wantedContents.add(key);
                }
              } catch (e) {
                //
              }
            } else {
              wantedContents.add(key);
            }
          });
        } else {
          return false;
        }
        print('====================');
        print(wantedContents);
        print('         ++==++ ');
        print('=======| 0    0 |=====');
        print('       |' '__' '|     ');
        print('        ' '__' '      ');
        res = await http.get(
          Uri.parse('${node.value.ip}/start'),
          headers: {
            'ctnts': json.encode(wantedContents),
          },
        );
        print('Response: ${res.body}');
        if (res.statusCode == 200) {
          return true;
        } else {
          return false;
        }
      }
    }
  }

  Future<SyncService?> fetchServers() async {
    List<String> svnamas = [];
    if (SystemConfig.stored!.svnamas != null) {
      svnamas = SystemConfig.stored!.svnamas!;
    }
    List<String> peersList = [];
    for (var value in svnamas) {
      peersList.add('http://$value:4227');
    }

    print('1 $peersList');
    int bNodeINdex = 0;
    for (final address in peersList) {
      try {
        final res = await http.get(
          Uri.parse('$address/fetch'),
          headers: {'todo': 'inead'},
        );
        print('2 - ${res.statusCode}');
        if (res.statusCode == 200) {
          bNodesStates[bNodeINdex] = (true);
          var bd = json.decode(res.body);
          print('bd: $bd');
          if (bd['id'] != null) {
            backupDevicesMap.addAll({
              bd['id']: BackupDevice.fromMap(bd),
            });
            print('3 - ${res.statusCode}');
          }
        }
      } catch (e) {
        stdout.write(e);
      }
      bNodeINdex++;
    }
    return this;
  }
}
