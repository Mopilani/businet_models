import 'dart:io';

import 'package:mongo_dart/mongo_dart.dart';

import 'global_state.dart';
import 'hcol.dart';

class SystemMDBService {
  SystemMDBService({
    required this.hiveDBPath,
    required this.mongoDBUriString,
    this.username = 'businet',
    this.password = 'businet',
    this.auth = true,
  });
  final String mongoDBUriString;
  final String hiveDBPath;
  final String username;
  final String password;
  final bool auth;

  Db? _db;

  Future<Db?> init() async {
    print('Initializing DB ${mongoDBUriString}');
    if (Platform.isAndroid) {
      _db = HDb(hiveDBPath);
    } else {
      _db = Db(mongoDBUriString);
    }

    try {
      if (auth) {
        var authState = await _db!.authenticate(username, password);
        if (authState) {
          await _db!.open();
        } else {
          print('DB auth state: $authState');
        }
      } else {
        await _db!.open();
      }
    } catch (e) {
      print(BusinetDBError(e));
      await _db!.open();
    }
    GlobalState.set('db2', _db);
    return _db;
  }

  static Future<void> use({
    hiveDBPath,
    mongoDBUriString,
    username = 'businet',
    password = 'businet',
    auth = true,
  }) async {
    await SystemMDBService.db.close().then((value) async {
      await SystemMDBService(
        mongoDBUriString: hiveDBPath,
        hiveDBPath: mongoDBUriString,
        password: password,
        username: username,
        auth: auth,
      ).init();
    });
  }

  Future<void> resetDb() async {}

  static Db get db => () {
        return GlobalState.get('db2');
      }();
}

class BusinetDBError extends Error {
  BusinetDBError(this.msg);
  final dynamic msg;

  @override
  String toString() => 'BusinetDBError(${msg.toString()})';
}
