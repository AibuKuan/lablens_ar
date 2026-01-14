import 'dart:convert';

import 'package:flutter/services.dart';

Future<bool> assetExists(String assetPath) async {
  try {
    final ByteData data = await rootBundle.load(assetPath);
    
    return data.lengthInBytes > 0;
  } catch (e) {
    return false;
  }
}


// load json asset
Future<Map<String, dynamic>> loadJsonAsset(String assetPath) async {
  final String jsonString = await rootBundle.loadString(assetPath);
  return jsonDecode(jsonString);
}


// function that calculates the file size of a given file path
Future<Map<String, dynamic>> getFileSize(String assetPath) async {
  try {
    final data = await rootBundle.load(assetPath);
    final sizeInBytes = data.lengthInBytes;

    const units = ['B', 'KB', 'MB', 'GB', 'TB'];
    int unitIndex = 0;
    double size = sizeInBytes.toDouble();

    while (size >= 1024 && unitIndex < units.length - 1) {
      size /= 1024;
      unitIndex++;
    }

    return {
      'size': double.parse(size.toStringAsFixed(2)),
      'unit': units[unitIndex],
    };
  } catch (e) {
    // If asset cannot be found or any error occurs, return size 0 B
    return {
      'size': 0,
      'unit': 'B',
    };
  }
}