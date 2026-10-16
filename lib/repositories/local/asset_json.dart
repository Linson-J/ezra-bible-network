import 'dart:convert';

import 'package:flutter/services.dart';

/// Loads and decodes a JSON file from assets/data/.
Future<dynamic> loadAssetJson(String name, {AssetBundle? bundle}) async {
  final raw = await (bundle ?? rootBundle).loadString('assets/data/$name');
  return jsonDecode(raw);
}
