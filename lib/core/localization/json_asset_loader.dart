import 'dart:convert';

import 'package:flutter/services.dart';

import '../constants/app_assets.dart';

class JsonAssetLoader {
  Future<Map<String, dynamic>> load(String locale) async {
    final data = await rootBundle.loadString(
      '${AppAssets.i18nPath}$locale.json',
    );
    return json.decode(data) as Map<String, dynamic>;
  }
}
