import 'package:mongo_dart/mongo_dart.dart';

import '../utils/sync_service.dart';
import '../utils/system_db.dart';

SystemConfig? _runtimeStoredInstance;

class InterfaceType {
  static const String administration = 'administration';
  static const String reception = 'reception';
  static const String pharmacy = 'pharmacy';
  static const String lab = 'lab';
  static const String mall = 'mall';
  static const String resturant = 'resturant';
  static const String wholeSales = 'wholeSales';
}

class SystemConfig {
  factory SystemConfig() {
    if (_runtimeStoredInstance == null) {
      _runtimeStoredInstance = SystemConfig.init();
      return _runtimeStoredInstance!;
    }
    return _runtimeStoredInstance!;
  }

  SystemConfig.init([SystemConfig? $with]) {
    if ($with != null) {
      id = $with.id;
      _printer = $with.printer;
      _theme = $with.theme;
      _invoicesSaveDirectoryPath = $with.invoicesSaveDirectoryPath;
      _pageRoute = $with.pageRoute;
      _animations = $with.animations;
      _runSyncService = $with.runSyncService;
      _deviceOnNetType = $with.deviceOnNetType;
      _salesType = $with.salesType;
      _svnamas = $with.svnamas;
      _syncOperationsState = $with.syncOperationsState;
      _firstStart = $with.firstStart;
    }
  }

  static Map<String, dynamic> systemConfig = <String, dynamic>{};

  static SystemConfig? stored = _runtimeStoredInstance;

  int id = 0;
  String get invoicesSaveDirectoryPath => _invoicesSaveDirectoryPath!;
  String get pageRoute => _pageRoute ?? 'CupertinoPageRoute';
  String get theme => _theme!;
  String get salesType => _salesType!;
  bool get animations => _animations;
  bool get runSyncService => _runSyncService;
  DeviceOnNetType get deviceOnNetType => _deviceOnNetType;
  BackupState get syncOperationsState => _syncOperationsState;
  bool get firstStart => _firstStart;
  List<String>? get svnamas => _svnamas;
  String? get printer => _printer;

  static bool notUpdate = false;

  set invoicesSaveDirectoryPath(String? v) {
    _invoicesSaveDirectoryPath = v;
    if (!notUpdate) {
      edit().asStream();
    }
  }

  set addSv(String v) {
    _svnamas!.add(v);
    if (!notUpdate) {
      edit().asStream();
    }
  }

  set removeSv(int index) {
    _svnamas!.removeAt(index);
    if (!notUpdate) {
      edit().asStream();
    }
  }

  set svnamas(List<String>? v) {
    _svnamas = v;
    if (!notUpdate) {
      edit().asStream();
    }
  }

  set pageRoute(String? v) {
    _pageRoute = v;
    if (!notUpdate) {
      edit().asStream();
    }
  }

  set printer(String? v) {
    _printer = v;
    if (!notUpdate) {
      edit().asStream();
    }
  }

  set theme(String? v) {
    _theme = v;
    if (!notUpdate) {
      edit().asStream();
    }
  }

  set salesType(String? v) {
    _salesType = v;
    if (!notUpdate) {
      edit().asStream();
    }
  }

  set animations(bool v) {
    _animations = v;
    if (!notUpdate) {
      edit().asStream();
    }
  }

  set runSyncService(bool v) {
    _runSyncService = v;
    if (!notUpdate) {
      edit().asStream();
    }
  }

  set deviceOnNetType(DeviceOnNetType v) {
    _deviceOnNetType = v;
    if (!notUpdate) {
      edit().asStream();
    }
  }

  set syncOperationsState(BackupState v) {
    _syncOperationsState = v;
    if (!notUpdate) {
      edit().asStream();
    }
  }

  set firstStart(bool v) {
    _firstStart = v;
    // edit().asStream();
  }

  static Future<SystemConfig?> get() async {
    var r = await SystemMDBService.db
        .collection('sysconfig')
        .findOne(where.eq('id', 0));
    // var v = await SystemMDBService.db.collection('sysconfig').find().toList();

    // print(v);
    // v.listen((event) {
      print('-----------------');
      print(r);
      print('-----------------');
    // });
    if (r == null) {
      return null;
    }
    var model = SystemConfig.fromMap(r);
    return model;
  }

  Future<void> edit() async {
    await SystemMDBService.db.collection('sysconfig').update(
          where.eq('id', 0),
          asMap(),
        );

    print('============');
    print(asMap());
    print('============');

    var r = await SystemMDBService.db
        .collection('sysconfig')
        .findOne(where.eq('id', 0));

    print(fromMap(r!).asMap());

    // var r = await get();
    // print(r);
    // SystemConfig.init(r);
  }

  // Future<void> add() async {
  //   await SystemMDBService.db.collection('sysconfig').insert(
  //         asMap(),
  //       );
  // }

  asMap() => {
        'id': id,
        'invoicesSaveDirectoryPath': invoicesSaveDirectoryPath,
        'printer': printer,
        'salesType': salesType,
        'theme': theme,
        'animations': animations,
        'runSyncService': runSyncService,
        'svnamas': svnamas,
        'firstStart': firstStart,
        'deviceOnNetType': deviceOnNetType.toString(),
        'syncOperationsState': syncOperationsState.toString(),
      };

  static SystemConfig fromMap(Map<String, dynamic> sysconfigData) {
    var model = SystemConfig.init();
    print('+_________++++++');
    print(sysconfigData);

    notUpdate = true;
    model.invoicesSaveDirectoryPath =
        sysconfigData['invoicesSaveDirectoryPath'];
    model.printer = sysconfigData['printer'];
    model.theme = sysconfigData['theme'];
    model.salesType = sysconfigData['salesType'];
    model.animations = sysconfigData['animations'] ?? true;
    model.runSyncService = sysconfigData['runSyncService'] ?? true;
    model.firstStart = sysconfigData['firstStart'];
    model.svnamas =
        sysconfigData['svnamas'] == null ? null : [...sysconfigData['svnamas']];
    model.deviceOnNetType = sysconfigData['deviceOnNetType'] != null
        ? deviceOnNetTypeFromString(sysconfigData['deviceOnNetType'])
        : DeviceOnNetType.master;
    model.syncOperationsState = sysconfigData['syncOperationsState'] != null
        ? backupStateTypeFromString(sysconfigData['syncOperationsState'])
        : BackupState.stopped;

    notUpdate = false;
    print(model.asMap());
    return model;
  }

  // Future<String?> getUserDirPath() async {
  //   String currentUserName = await getCurrentUserName();
  //   var currentUserDirPath = 'C:/Users/$currentUserName';
  //   // currentUserName == null ? currentUserDirPath = currentUserName : null;
  //   if (await chkdir(currentUserDirPath)) {
  //     return currentUserDirPath;
  //   }
  //   return null;
  // }

  // Future<String?> getUserDocumentsPath() async {
  //   String currentUserName = await getCurrentUserName();
  //   var currentUserDirPath = 'C:/Users/$currentUserName/Documents';
  //   // currentUserName == null ? currentUserDirPath = currentUserName : null;
  //   if (await chkdir(currentUserDirPath)) {
  //     return currentUserDirPath;
  //   }
  //   return null;
  // }

  // Future<String?> getUserPicturesPath() async {
  //   String currentUserName = await getCurrentUserName();
  //   var currentUserDirPath = 'C:/Users/$currentUserName/Pictures';
  //   // currentUserName == null ? currentUserDirPath = currentUserName : null;
  //   if (await chkdir(currentUserDirPath)) {
  //     return currentUserDirPath;
  //   }
  //   return null;
  // }

  // Future<String?> getUserAppDataDirPath() async {
  //   String currentUserName = await getCurrentUserName();
  //   var currentUserDirPath = 'C:/Users/$currentUserName/AppData';
  //   // currentUserName == null ? currentUserDirPath = currentUserName : null;
  //   if (await chkdir(currentUserDirPath)) {
  //     return currentUserDirPath;
  //   }
  //   return null;
  // }
}

String? _invoicesSaveDirectoryPath;
List<String>? _svnamas;
String? _pageRoute;
String? _printer;
String? _theme = 'light';
String? _salesType = 'mall';
bool _animations = true;
bool _runSyncService = true;
DeviceOnNetType _deviceOnNetType = DeviceOnNetType.master;
BackupState _syncOperationsState = BackupState.running;
bool _firstStart = false;
