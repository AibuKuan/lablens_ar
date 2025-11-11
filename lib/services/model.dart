import 'dart:convert';
import 'package:ar_app/utils/asset.dart';
import 'package:ar_flutter_plugin_2/datatypes/node_types.dart';
import 'package:ar_flutter_plugin_2/managers/ar_object_manager.dart';
import 'package:ar_flutter_plugin_2/models/ar_anchor.dart';
import 'package:ar_flutter_plugin_2/models/ar_node.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:vector_math/vector_math_64.dart' as vector;


class Model {
  String modelPath = "assets/models/";
  String descPath = "assets/descriptions/";

  final double initialScale = 0.2;

  ARNode? arNode;
  ARObjectManager? objectManager;
  ARPlaneAnchor? currentAnchor;

  String? name;
  String? category;
  String? function;
  String? usage;
  String? specifications;
  String? maintenance;
  String? warning;

  static Future<Model> create(String name) async {
    final model = Model._internal(name);
    await model._loadDescription();
    model._createARNode();
    return model;
  }
  
  Model._internal(name) {
    modelPath += "$name.glb";
    descPath += "$name.json";
  }

  Future<void> _loadDescription() async {
    try {
      final String jsonString = await rootBundle.loadString(descPath);
      
      final Map<String, dynamic> description = jsonDecode(jsonString);

      name = description['name'];
      category = description['category'];
      function = description['function'];
      usage = description['usage'];
      specifications = description['specifications'];
      maintenance = description['maintenance'];
      warning = description['warning'];
    } catch (e) {
      print('Error loading description file $descPath: $e');
      // Set properties to null to handle missing data gracefully
    }
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