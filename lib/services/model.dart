import 'package:lablens_ar/models/equipment.dart';
import 'package:lablens_ar/services/description.dart';
import 'package:lablens_ar/utils/asset.dart';
import 'package:ar_flutter_plugin_2/datatypes/node_types.dart';
import 'package:ar_flutter_plugin_2/managers/ar_object_manager.dart';
import 'package:ar_flutter_plugin_2/models/ar_anchor.dart';
import 'package:ar_flutter_plugin_2/models/ar_node.dart';
import 'package:vector_math/vector_math_64.dart' as vector;


class Model {
  final double initialScale = 0.2;
  String modelPath = "assets/models/";

  late String modelName;
  ARNode? arNode;
  ARObjectManager? objectManager;
  ARPlaneAnchor? currentAnchor;
  Equipment? detail;

  static Future<Model> create({String? name, Equipment? detail}) async {
    if (name == null && detail == null) {
      throw ArgumentError('Either "name" (for asset lookup) or "detail" (for direct URL/path) must be provided.');
    }

    final model = Model._internal(name, detail);
    if (detail == null) {
      model._loadDescription();
    } else {
      model.detail = detail;
    }
    model._createARNode();
    return model;
  }
  
  Model._internal(String? name, Equipment? detail) {
    if (detail != null) {
      modelName = detail.modelName;
      modelPath = detail.modelPath;
      this.detail = detail;
    } else if (name != null) {
      modelName = name;
      modelPath += "$name.glb";
    }
  }

  void _loadDescription() async {
    if (detail != null) {
      return;
    }
    detail = EquipmentManager().getEquipmentByModel(modelName);
  }

  void _createARNode() {
    arNode = ARNode(
      type: NodeType.localGLTF2,
      uri: modelPath,
      scale: vector.Vector3(initialScale, initialScale, initialScale),
    );
  }

  Future<bool> exists() async {
    return await assetExists(modelPath); 
  }

  void addObjectManager(ARObjectManager objectManager) {
    this.objectManager = objectManager;
  }
  
  void scale(scaleFactor) {
    if (arNode == null) return;
    // double scale = arNode!.scale.x;
    arNode!.scale = vector.Vector3(initialScale * scaleFactor, initialScale * scaleFactor, initialScale * scaleFactor);
    objectManager!.removeNode(arNode!);
    objectManager!.addNode(arNode!, planeAnchor: currentAnchor);
  }
}