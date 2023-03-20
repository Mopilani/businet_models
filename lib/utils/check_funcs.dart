import 'dart:io';

Future<bool> chkdir(String directoryPath) async {
  return await Directory(directoryPath).exists();
}

bool chkdirSync(String directoryPath) {
  return Directory(directoryPath).existsSync();
}
