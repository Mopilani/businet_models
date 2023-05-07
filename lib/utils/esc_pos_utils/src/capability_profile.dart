/*
 * esc_pos_utils
 * Created by Andrey U.
 * 
 * Copyright (c) 2019-2020. All rights reserved.
 * See LICENSE for distribution and usage details.
 */

import 'dart:convert';

// import 'package:flutter/services.dart' show rootBundle;

class CodePage {
  CodePage(this.id, this.name);
  int id;
  String name;
}

CapabilityProfile? _stored;

class CapabilityProfile {
  factory CapabilityProfile.stored() => _stored!;

  CapabilityProfile._internal(this.name, this.codePages);

  /// Public factory
  static Future<CapabilityProfile> load(rootBundle, {String name = 'default'}) async {
    var byteData = await rootBundle.load('assets/resources/capabilities.json');

    final content = utf8.decode(byteData.buffer.asUint8List());

    // final content = await File(
    //         'C:/Users/Mopilani/Downloads/esc_pos_utils-1.1.0/lib/resources/capabilities.json')
    //     .readAsString();
    Map capabilities = json.decode(content);

    var profile = capabilities['profiles'][name];

    if (profile == null) {
      throw Exception("The CapabilityProfile '$name' does not exist");
    }

    List<CodePage> list = [];
    profile['codePages'].forEach((k, v) {
      list.add(CodePage(int.parse(k), v));
    });

    _stored = CapabilityProfile._internal(name, list);
    // Call the private constructor
    return _stored!;
  }

  String name;
  List<CodePage> codePages;

  int getCodePageId(String? codePage) {
    if (codePages == null) {
      throw Exception("The CapabilityProfile isn't initialized");
    }

    return codePages
        .firstWhere((cp) => cp.name == codePage,
            orElse: () => throw Exception(
                "Code Page '$codePage' isn't defined for this profile"))
        .id;
  }

  static Future<List<dynamic>> getAvailableProfiles(rootBundle) async {
    var byteData = await rootBundle.load('assets/resources/capabilities.json');

    final content = utf8.decode(byteData.buffer.asUint8List());
    // final content = await File(
    //         'C:/Users/Mopilani/Downloads/esc_pos_utils-1.1.0/lib/resources/capabilities.json')
    //     .readAsString();
    Map capabilities = json.decode(content);

    var profiles = capabilities['profiles'];

    List<dynamic> res = [];

    profiles.forEach((k, v) {
      res.add({
        'key': k,
        'vendor': v['vendor'] is String ? v['vendor'] : '',
        'model': v['model'] is String ? v['model'] : '',
        'description': v['description'] is String ? v['description'] : '',
      });
    });

    return res;
  }
}
