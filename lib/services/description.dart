import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:ar_app/models/equipment.dart';

class EquipmentManager {
  // Static instance for the singleton
  static final EquipmentManager _instance = EquipmentManager._internal();

  // Factory constructor returns the same instance
  factory EquipmentManager() => _instance;

  // Private constructor
  EquipmentManager._internal();

  List<Equipment> equipments = [];
  List<Equipment> equipmentsFiltered = [];
  List categories = [];
  bool isLoaded = false;

  Future<void> loadEquipments() async {
    if (isLoaded) return; // Prevent reloading if already done

    final String response = await rootBundle.loadString('assets/descriptions/descriptions.json');
    final Map<String, dynamic> data = jsonDecode(response);

    equipments = data.entries.map((entry) {
      return Equipment.fromJson(entry.key, entry.value);
    }).toList();
    equipmentsFiltered = equipments;

    getCategories();

    isLoaded = true;
  }

  Equipment? getEquipmentByModel(String modelName) {
    for (var equipment in equipments) {
      if (equipment.modelName == modelName) {
        return equipment;
      }
    }
    return null;
  }

  
  void searchEquipments(String? query) {
    if (query == null || query.isEmpty) {
      equipmentsFiltered = equipments;
      return;
    }

    equipmentsFiltered = equipments.where((equipment) {
      return equipment.name.toLowerCase().contains(query.toLowerCase());
    }).toList();
  }

  void getCategories() {
    equipments.forEach((equipment) {
      if (!categories.contains(equipment.category)) {
        categories.add(equipment.category);
      }
    });
  }

  void searchCategories(Map? categories) {
    if (categories == null) return;

    equipmentsFiltered = equipmentsFiltered.where((equipment) {
      return categories[equipment.category] ?? false;
    }).toList();
  }
}