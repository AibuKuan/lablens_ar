import 'dart:convert';
import 'package:ar_app/utils/asset.dart';
import 'package:flutter/services.dart' show rootBundle;


class Model {
  String modelPath = "assets/models/";
  String descPath = "assets/descriptions/";

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

  Future<bool> exists() async {
    return await assetExists(modelPath); 
  }
}