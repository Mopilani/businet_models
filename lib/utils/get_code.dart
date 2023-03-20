// import '../../models/system_node_model.dart';
// import 'esc_pos_utils.dart';
// // import 'package:pdf/widgets.dart' as pw;

// // import 'package:flutter/services.dart';

// Future<List<int>> sendDesign(String path) async {
//   final profile = await CapabilityProfile.load();
//   final generator = Generator(PaperSize.mm80, profile);
//   List<int> bytes = [];

//   bytes += generator.text('0RECEIPTDESIGN:$path');
//   return bytes;
// }

// Future<List<int>> sendPath(String path) async {
//   final profile = await CapabilityProfile.load();
//   final generator = Generator(PaperSize.mm80, profile);
//   List<int> bytes = [];

//   bytes += generator.text('0FILEPATH:$path');
//   return bytes;
// }

// Future<List<int>> getInitCode() async {
//   final profile = await CapabilityProfile.load();
//   final generator = Generator(PaperSize.mm80, profile);
//   List<int> bytes = [];

//   bytes += generator.text('INITSBUILDER');
//   return bytes;
// }

// Future<List<int>> getEndCode() async {
//   final profile = await CapabilityProfile.load();
//   final generator = Generator(PaperSize.mm80, profile);
//   List<int> bytes = [];
//   bytes += generator.text('STOPSBUILDER');
//   return bytes;
// }

// table(List<List<String>> raws, PosAlign align) {
//   var charsPerLine = 42;
//   var columnCharsSize = charsPerLine ~/ raws.first.length;
//   String text = '';
//   var currentColumnIndex = 0;
//   for (var raw in raws) {
//     String newLine = ' ' * charsPerLine;
//     currentColumnIndex = 0;
//     for (var field in raw) {
//       int  wordLength = field.length;
//       String formated;
//       switch (align) {
//         case PosAlign.left:
//           newLine = newLine.replaceRange(
//             (columnCharsSize * currentColumnIndex).toInt(),
//             (columnCharsSize * currentColumnIndex).toInt() + columnCharsSize,
//             formate(field, align, null, columnCharsSize),
//           );
//           break;
//         case PosAlign.center:
//           newLine = newLine.replaceRange(
//             (columnCharsSize * currentColumnIndex).toInt(),
//             (columnCharsSize * currentColumnIndex).toInt() + wordLength,
//             formate(field, align, null, columnCharsSize),
//           );
//           break;
//         case PosAlign.right:
//           formated = formate(field, align, null, columnCharsSize);
//           // print('/////////////////////////////////');
//           // print(formate(field, align, null, columnCharsSize));
//           // print(charsPerLine - formated.length.toInt());
//           // print(charsPerLine -
//           //     (columnCharsSize * currentColumnIndex + 1).toInt());
//           // print('/////////////////////////////////');
//           newLine = newLine.replaceRange(
//               (charsPerLine -
//                       formated.length -
//                       columnCharsSize * (currentColumnIndex))
//                   .round(),
//               charsPerLine - (columnCharsSize * (currentColumnIndex)),
//               formated);
//           break;
//       }
//       currentColumnIndex++;
//     }
//     // print(newLine);
//     text += newLine;
//   }
//   return text;
// }

// String formate(String textAddition, PosAlign align,
//     [String? line, int? charsPerLineWanted]) {
//   var charsPerLine = charsPerLineWanted ?? 42;
//   String text;
//   if (line == null) {
//     text = ' ' * charsPerLine;
//   } else {
//     text = line;
//   }
//   // print(text.length);
//   switch (align) {
//     case PosAlign.left:
//       int wordLength = textAddition.length;
//       text = text.replaceRange(0, wordLength, textAddition);
//       break;
//     case PosAlign.center:
//       var wordCenter = textAddition.length / 2;
//       var lineCenter = charsPerLine / 2;
//       text = text.replaceRange(
//         (lineCenter - wordCenter).toInt(),
//         (lineCenter + wordCenter).toInt(),
//         textAddition,
//       );
//       break;
//     case PosAlign.right:
//       int wordLength = textAddition.length;
//       int lineLength = charsPerLine;
//       print('TextAddition: $textAddition');
//       text =
//           text.replaceRange(lineLength - wordLength, lineLength, textAddition);
//       break;
//   }
//   return (text);
// }

// Future<List<int>> getCode() async {
//   final profile = await CapabilityProfile.load();
//   final generator = Generator(PaperSize.mm80, profile);
//   List<int> bytes = [];

//   bytes += generator.text(
//     formate('تقرير المبيعات', PosAlign.center),
//     styles: const PosStyles(
//       bold: true,
//     ),
//   );
//   var line = formate('', PosAlign.left);
//   line = formate(SystemNodeModel.stored!.placeName!, PosAlign.right, line);
//   bytes += generator.text(line);
//   // throw '';
//   // bytes += generator.text('Special 1: àÀ èÈ éÉ ûÛ üÜ çÇ ôÔ',
//   //     styles: PosStyles(codeTable: 'CP1252'));
//   // bytes += generator.text('Special 2: blåbærgrød',
//   //     styles: PosStyles(codeTable: 'CP1252'));

//   // bytes += generator.text('Bold text', styles: PosStyles(bold: true));
//   // bytes += generator.text('Reverse text', styles: PosStyles(reverse: true));
//   // bytes += generator.text('Underlined text',
//   //     styles: PosStyles(underline: true), linesAfter: 1);
//   // bytes +=
//   //     generator.text('Align left', styles: PosStyles(align: PosAlign.left));
//   // bytes +=
//   //     generator.text('Align center', styles: PosStyles(align: PosAlign.center));
//   // bytes += generator.text('Align right',
//   //     styles: PosStyles(align: PosAlign.right), linesAfter: 1);

//   // bytes += generator.row([
//   //   PosColumn(
//   //     text: 'col3',
//   //     width: 3,
//   //     styles: PosStyles(align: PosAlign.center, underline: true),
//   //   ),
//   //   PosColumn(
//   //     text: 'col6',
//   //     width: 6,
//   //     styles: PosStyles(align: PosAlign.center, underline: true),
//   //   ),
//   //   PosColumn(
//   //     text: 'col3',
//   //     width: 3,
//   //     styles: PosStyles(align: PosAlign.center, underline: true),
//   //   ),
//   // ]);

//   // bytes += generator.text('Text size 200%',
//   //     styles: PosStyles(
//   //       height: PosTextSize.size2,
//   //       width: PosTextSize.size2,
//   //     ));
//   // final pdf = pw.Document();
//   // PdfPageFormat pageFormat = PdfPageFormat.roll80;

//   // Future<pw.PageTheme> pageTheme() async {
//   //   final arialFont = await rootBundle.load("assets/fonts/ARIAL.TTF");
//   //   final arialFontTTF = pw.Font.ttf(arialFont);

//   //   return pw.PageTheme(
//   //     pageFormat: pageFormat,
//   //     theme: pw.ThemeData.withFont(
//   //       icons: arialFontTTF,
//   //       fontFallback: [pw.Font.ttf(arialFont)],
//   //     ),
//   //   );
//   // }

//   // // Print image:
//   // // final Uint8List imgBytes = Uint8List.fromList(
//   // //     await File('C:/Users/Mopilani/Pictures/Untitled.png').readAsBytes());
//   // buildPages([pw.Context? context]) {
//   //   return [
//   //     pw.Column(
//   //       mainAxisAlignment: pw.MainAxisAlignment.start,
//   //       children: [
//   //         // pw.Image(
//   //         //   pw.RawImage(bytes: pngBytes, width: 100, height: 40),
//   //         // ),
//   //         pw.Text(
//   //             convert("تقرير الايصالات والفواتير")
//   //                 .split(' ')
//   //                 .reversed
//   //                 .join(' '),
//   //             style: pw.TextStyle(
//   //               fontSize: 12,
//   //               fontWeight: pw.FontWeight.bold,
//   //             )),
//   //         pw.SizedBox(height: 16),
//   //         pw.Row(
//   //             mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
//   //             children: [
//   //               pw.Text(
//   //                   convert(PointOfSaleModel.stored!.placeName!)
//   //                       .split(' ')
//   //                       .reversed
//   //                       .join(' '),
//   //                   style: pw.TextStyle(
//   //                     fontSize: 14,
//   //                     fontWeight: pw.FontWeight.bold,
//   //                   )),
//   //               pw.Text(
//   //                 convert('${"dayDate".tr()}: ${(ProcessesModel.stored!.businessDayString())} ')
//   //                     .split(' ')
//   //                     .reversed
//   //                     .join(' '),
//   //               ),
//   //             ]),
//   //         pw.SizedBox(height: 8),
//   //         pw.Divider(),
//   //         pw.SizedBox(height: 8),
//   //         // () {
//   //         // if (accordingToShift) {
//   //         //   double totalValue = 0.0;
//   //         //   double totalPayouts = 0.0;
//   //         //   int itemIndex = 0;
//   //         //   return pw.Column(
//   //         //     children: [
//   //         //       pw.Row(
//   //         //         mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
//   //         //         children: [
//   //         //           pw.Text(convert('الرقم'),
//   //         //               style: pw.TextStyle(
//   //         //                 fontSize: 12,
//   //         //                 fontWeight: pw.FontWeight.bold,
//   //         //               )),
//   //         //           pw.VerticalDivider(),
//   //         //           pw.Text(convert('السعر'),
//   //         //               style: pw.TextStyle(
//   //         //                 fontSize: 12,
//   //         //                 fontWeight: pw.FontWeight.bold,
//   //         //               )),
//   //         //           pw.VerticalDivider(),
//   //         //           pw.Text(convert('الزمن'),
//   //         //               style: pw.TextStyle(
//   //         //                 fontSize: 12,
//   //         //                 fontWeight: pw.FontWeight.bold,
//   //         //               )),
//   //         //         ],
//   //         //       ),
//   //         //       ...accordingToShiftFound.entries.map<pw.Widget>((entry) {
//   //         //         itemIndex++;
//   //         //         return pw.Column(
//   //         //           // mainAxisAlignment: pw.MainAxisAlignment.start,
//   //         //           children: [
//   //         //             pw.Text(entry.key.toString() +
//   //         //                 convert('الوردية: ').split(' ').reversed.join(' ')),
//   //         //             ...() {
//   //         //               List<pw.Widget> wids = [];
//   //         //               for (var receipt in entry.value) {
//   //         //                 wids.add(pw.Row(children: [
//   //         //                   pw.Text(convert(receipt.id.toString()),
//   //         //                       style: pw.TextStyle(
//   //         //                         fontSize: 12,
//   //         //                         fontWeight: pw.FontWeight.bold,
//   //         //                       )),
//   //         //                   pw.VerticalDivider(),
//   //         //                   pw.Text(convert(receipt.total.toString()),
//   //         //                       style: pw.TextStyle(
//   //         //                         fontSize: 12,
//   //         //                         fontWeight: pw.FontWeight.bold,
//   //         //                       )),
//   //         //                   pw.VerticalDivider(),
//   //         //                   pw.Text(
//   //         //                     convert(
//   //         //                         '${receipt.createDate.hour}:${receipt.createDate.minute}'),
//   //         //                     style: pw.TextStyle(
//   //         //                       fontSize: 12,
//   //         //                       fontWeight: pw.FontWeight.bold,
//   //         //                     ),
//   //         //                   ),
//   //         //                 ]));
//   //         //               }

//   //         //               return wids;
//   //         //             }()
//   //         //           ],
//   //         //         );
//   //         //       }).toList(),
//   //         //       pw.SizedBox(height: 4),
//   //         //     ],
//   //         //   );
//   //         // } else {
//   //         //   return pw.SizedBox();
//   //         // }
//   //         // }(),
//   //         pw.SizedBox(height: 8),
//   //         pw.Divider(),
//   //       ],
//   //     ),
//   //   ];
//   // }

//   // pdf.addPage(
//   //   pw.Page(
//   //     pageTheme: await pageTheme(),
//   //     build: (context) => pw.Column(
//   //       children: buildPages(context),
//   //     ),
//   //   ),
//   // );
//   // var pdfBytes = await (pdf.save());
//   // var page = await (await x.PdfDocument.openData(pdfBytes)).getPage(1);
//   // var pageImage = await page.render(
//   //   width: page.width * 2,
//   //   height: page.height * 2,
//   //   format: x.PdfPageImageFormat.png,
//   //   backgroundColor: '#ffffff',
//   //   forPrint: true,
//   // );
//   // var file = File('C:/Users/Mopilani/Pictures/IMG_20220511_121533_049.jpg');
//   // await file.writeAsBytes(pageImage!.bytes);
//   // throw '';

//   // final Image image = decodeImage(ascii.encode(utf8.decode(
//   //   pageImage!.bytes,
//   //   allowMalformed: true,
//   // ), ))!;
//   // final Image image = decodeImage(await file.readAsBytes())!;
//   // bytes += generator.image(image);
//   // Print image using an alternative (obsolette) command
//   // bytes += generator.imageRaster(image);

//   // Print barcode
//   // final List<int> barData = [1, 2, 3, 4, 5, 6, 7, 8, 9, 0, 4];
//   // bytes += generator.barcode(Barcode.upcA(barData));

//   // Print mixed (chinese + latin) text. Only for printers supporting Kanji mode
//   // ticket.text(
//   //   'hello ! 中文字 # world @ éphémère &',
//   //   styles: PosStyles(codeTable: PosCodeTable.westEur),
//   //   containsChinese: true,
//   // );

//   bytes += generator.feed(1);
//   bytes += generator.cut();
//   print(bytes);
//   return bytes;
// }
