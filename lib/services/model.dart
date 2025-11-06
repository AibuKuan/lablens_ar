import 'package:ar_app/utils/asset.dart';

class Model {
  String name;
  String path = "assets/models/";

  Model(this.name) {
    path += "$name.glb";
  }

  Future<bool> exists() async {
    return await assetExists(path);
  }
}