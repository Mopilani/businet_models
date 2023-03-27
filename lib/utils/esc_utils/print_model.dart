import 'dart:convert';
import 'dart:io';

import 'package:businet_models/utils/esc_pos_utils/get_code.dart';

import '../../models/system_config.dart';


PrintServiceModel? _printModel;

class PrintServiceModel {
  factory PrintServiceModel() {
    if (_printModel == null) {
      throw 'Initialize the print model by calling PrintModel.init()';
    } else {
      return _printModel!;
    }
  }

  PrintServiceModel._();

  static Future<PrintServiceModel?> init(String printerName) async {
    _printModel = PrintServiceModel._();
    var file = File('C:/Program Files/Besmar/rph.exe');
    if (await file.exists()) {
      _printModel!.process = await Process.start(
        // 'C:/Users/Mopilani/source/repos/raw_print_helper/raw_print_helper/bin/Release/net6.0/raw_print_helper.exe',
        'printing/rph/raw_print_helper.exe',
        // 'C:/Program Files/Besmar/rph.exe',
        // 'C:/H/NexaPros_Flutter/cashier_p/windows/raw_printer_helper/raw_print_helper.exe',
        [printerName],
      );
      _printModel!.activeListener();
      return _printModel!;
    }
    return null;
  }

  bool isReady = false;

  activeListener() {
    process.stdout.listen((event) {
      print(utf8.decode(event, allowMalformed: true));
      if (utf8.decode(event, allowMalformed: true) == 'READY') {
        isReady = true;
      }
    });
  }

  void sendImage(String imageFilePath) {
    process.stdin.write('IMAGE:$imageFilePath');
  }

  late Process process;

  void end() {
    process.kill();
  }

  Future<void> sendDesignToPrinter(String data) async {
    print(data);
    // if (SystemConfig().printer == null) {
    //   throw 'You must select a printer first.';
    // }
    var r = await Process.run(
      'C:/Users/Mopilani/source/repos/raw_print_helper/raw_print_helper/bin/Release/net6.0/raw_print_helper.exe',
      // 'C:/Program Files/Besmar/rph.exe',
      // 'C:/H/NexaPros_Flutter/cashier_p/windows/raw_printer_helper/raw_print_helper.exe',
      ['receipt80', data, SystemConfig().printer!],
    );
    print(r.stdout);
    print(r.stderr);
    // process.stdin.write(
    //   utf8.decode(
    //     await sendDesign(data),
    //     allowMalformed: true,
    //   ),
    // );
  }

  Future<void> sendToPrinter(List<int> data, rootBundle) async {
    await File('C:/CLaB/NF/prnt2').writeAsBytes(data).then(
          (value) async => process.stdin.write(utf8.decode(
            await sendPath(value.path, rootBundle),
            allowMalformed: true,
          )),
        );
    // process.stdin.write(
    //   utf8.decode(await getEndCode()),
    // );

    // final Uint8List imgBytes = Uint8List.fromList(
    // await File('C:/Users/Mopilani/Pictures/Untitled.png').readAsBytes());
    // process = await Process.start(
    //   'C:/Users/Mopilani/source/repos/raw_print_helper/raw_print_helper/bin/Debug/net6.0/raw_print_helper.exe',
    //   // 'C:/H/NexaPros_Flutter/cashier_p/windows/raw_printer_helper/raw_print_helper.exe',
    //   [
    //     printerName,
    //   ],
    //   // [
    //   //   printerName,
    //   //   data,
    //   //   'Businet Reports',
    //   // ],
    // );
    // process.stdout.listen((event) {
    //   print(utf8.decode(event));
    //   if (utf8.decode(event) == 'READY') {}
    // });
  }
}
