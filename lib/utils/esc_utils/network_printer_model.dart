// // import 'dart:io';

// import 'package:esc_pos_printer/esc_pos_printer.dart';
// import 'package:esc_pos_utils/esc_pos_utils.dart';
// // import 'package:flutter/material.dart';
// // import 'package:image/image.dart' as kImage;
//  void _testReceipt(NetworkPrinter printer, String imagePath) {
//     // File file = File(imagePath);
//     // Image image = Image.file(file);
//     // printer.image();
//     printer.text(
//         'Regular: aA bB cC dD eE fF gG hH iI jJ kK lL mM nN oO pP qQ rR sS tT uU vV wW xX yY zZ');
//     printer.text('Special 1: àÀ èÈ éÉ ûÛ üÜ çÇ ôÔ',
//         styles: const PosStyles(codeTable: 'CP1252'));
//     printer.text('Special 2: blåbærgrød',
//         styles: const PosStyles(codeTable: 'CP1252'));

//     printer.text('Bold text', styles: const PosStyles(bold: true));
//     printer.text('Reverse text', styles: const PosStyles(reverse: true));
//     printer.text('Underlined text',
//         styles: const PosStyles(underline: true), linesAfter: 1);
//     printer.text('Align left', styles: const PosStyles(align: PosAlign.left));
//     printer.text('Align center',
//         styles: const PosStyles(align: PosAlign.center));
//     printer.text('Align right',
//         styles: const PosStyles(align: PosAlign.right), linesAfter: 1);

//     printer.text(
//       'Text size 200%',
//       styles: const PosStyles(
//         height: PosTextSize.size2,
//         width: PosTextSize.size2,
//       ),
//     );
//     printer.feed(2);
//     printer.cut();
//   }

// printToNetworkPrinter() async {
//   const PaperSize paper = PaperSize.mm80;
//   final profile = await CapabilityProfile.load();
//   final printer = NetworkPrinter(paper, profile);

//   final PosPrintResult res =
//       await printer.connect('192.168.0.123', port: 9100);

//   if (res == PosPrintResult.success) {
//     _testReceipt(printer, '');
//     printer.disconnect();
//   }
// }

//   // Has
//   // Order Number
//   // Cashier Name :
//   // Client Type : Normal Client /
//   // Date
//   // Time
//   // Payment Type : Cash / Bank Transfer / Shik

//   // Total
//   // Wanted
//   // Payedout
//   // Residual
//   // Previous Depts
//   // Total Depts
