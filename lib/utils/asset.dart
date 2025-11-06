import 'package:flutter/services.dart';

/// Checks if an asset exists at the given [assetPath].
Future<bool> assetExists(String assetPath) async {
  try {
    // Attempt to load the asset's binary data
    final ByteData data = await rootBundle.load(assetPath);
    
    // Check if the data is not null and not empty
    return data.lengthInBytes > 0;
  } catch (e) {
    // An exception is thrown if the asset cannot be found
    return false;
  }
}