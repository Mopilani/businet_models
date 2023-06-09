import 'dart:io';

import 'package:mongo_dart/mongo_dart.dart';
// import 'package:path_provider/path_provider.dart' as path_provider;

import 'global_state.dart';
import 'hcol.dart';
import 'package:hive/hive.dart';

class SMDB extends SystemMDBService {
  SMDB({
    required String hiveDBPath,
    required String mongoDBUriString,
    String username = 'businet',
    String password = 'businet',
    bool auth = true,
    bool useMongo = true,
    bool useMongoGridfs = false,
  }) : super(
          hiveDBPath: hiveDBPath,
          mongoDBUriString: mongoDBUriString,
          username: username,
          password: password,
          auth: auth,
          useMongo: useMongo,
          useMongoGridfs: useMongoGridfs,
        );

  static Future<void> useMain() async {
    await SMDB.sysMdbs.first.sysMDB
        .init()
        .then((value) => currentDb = SMDB.sysMdbs.first);
  }

  static DBMeta? currentDb;

  static List<DBMeta> sysMdbs = [];

  static void register(List<String> _collectionNames) {
    for (var collectionName in _collectionNames) {
      collectionNames.add(collectionName);
    }
  }

  static Future<void> loadBoxes() async {
    print('Collections: $collectionNames');
    for (var collectionName in collectionNames) {
      await Hive.openBox<Map>(collectionName);
    }
  }

  static List<String> collectionNames = [];
}

class SystemMDBService {
  SystemMDBService({
    required this.hiveDBPath,
    required this.mongoDBUriString,
    this.username = 'businet',
    this.password = 'businet',
    this.docDir,
    this.auth = true,
    this.useMongo = false,
    this.useMongoGridfs = false,
  });

  final String mongoDBUriString;
  final String hiveDBPath;
  final String username;
  final String password;
  final bool auth;
  final bool useMongo;
  final bool useMongoGridfs;
  final Directory? docDir;

  Db? _db;
  Db? _GFSdb;

  Future<Db?> init() async {
    if (Platform.isAndroid && !useMongo) {
      // var docDir = await path_provider.getApplicationDocumentsDirectory();
      var dbPath = docDir!.path + '/' + hiveDBPath;
      _db = HDb(dbPath);
      print('Initializing HDB $dbPath');
    } else {
      _db = Db(mongoDBUriString);
      _GFSdb = Db(mongoDBUriString + '-gfs');
      print('Initializing MDB $mongoDBUriString');
    }

    try {
      if (auth) {
        await _db!.open();
        var authState = await _db!.authenticate(username, password);

        if (useMongoGridfs) {
          await _GFSdb!.open();
          var gFSDBauthState = await _GFSdb!.authenticate(username, password);
          var collectionName = 'default-gfs-coll';
          var gridFS = GridFS(_GFSdb!, collectionName);
          print('GridFS Initialized');
          GlobalState.set('gridFS', gridFS);
        } else {
          print('DB auth state: $authState');
        }
      } else {
        await _db!.open();
        await _GFSdb!.open();

        if (useMongoGridfs) {
          var collectionName = 'default-gfs-coll';
          var gridFS = GridFS(_GFSdb!, collectionName);
          GlobalState.set('gridFS', gridFS);
          print('GridFS Initialized');
        }
      }
    } catch (e, s) {
      print(BusinetDBError(e));
      print(BusinetDBError(s));
      await _db!.open();
    }
    GlobalState.set('db2', _db);
    GlobalState.set('GFSdb', _GFSdb);

    return _db;
  }

  static Future<void> use({
    hiveDBPath,
    mongoDBUriString,
    username = 'businet',
    password = 'businet',
    auth = true,
    useMongo = false,
    useMongoGridfs = false,
  }) async {
    await SystemMDBService.db.close().then((value) async {
      await SystemMDBService(
        mongoDBUriString: hiveDBPath,
        hiveDBPath: mongoDBUriString,
        password: password,
        username: username,
        auth: auth,
        useMongo: useMongo,
        useMongoGridfs: useMongoGridfs,
      ).init();
    });
  }

  static SystemMDBService fromMap(Map data) {
    return SystemMDBService(
      hiveDBPath: data['hiveDBPath'],
      mongoDBUriString: data['mongoDBUriString'],
      auth: data['auth'],
      useMongo: data['useMongo'],
      useMongoGridfs: data['useMongoGridfs'],
      password: data['password'],
      username: data['username'],
    );
  }

  Map toMap() => {
        'hiveDBPath': hiveDBPath,
        'mongoDBUriString': mongoDBUriString,
        'auth': auth,
        'useMongo': useMongo,
        'useMongoGridfs': useMongoGridfs,
        'password': password,
        'username': username,
      };

  Future<void> resetDb() async {}

  static Db get db => () {
        return GlobalState.get('db2');
      }();

  static Db get gFSdb => () {
        return GlobalState.get('GFSdb');
      }();

  static GridFS get gridFS => () {
        return GlobalState.get('gridFS');
      }();
}

class DBMeta {
  DBMeta(
    this.name,
    this.description,
    this.sysMDB,
  );
  String name;
  String description;
  SystemMDBService sysMDB;

  static DBMeta fromJson(Map map) {
    return DBMeta(
      map['name'],
      map['description'],
      SystemMDBService.fromMap(map['sysMDB']),
    );
  }

  Map toMap() => {
        'name': name,
        'description': description,
        'sysMDB': sysMDB.toMap(),
      };
}

class BusinetDBError extends Error {
  BusinetDBError(this.msg);
  final dynamic msg;

  @override
  String toString() => 'BusinetDBError(${msg.toString()})';
}
