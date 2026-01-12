import 'package:ar_app/models/equipment.dart';
import 'package:ar_app/services/description.dart';
import 'package:ar_app/widgets/equipment_row.dart';
import 'package:ar_app/widgets/search_form.dart';
import 'package:flutter/material.dart';

class LibraryScreen extends StatefulWidget {
    const LibraryScreen({super.key});

    @override
    State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
    List<Equipment> equipments = [];
    // Equipment dummy = Equipment("Dummy", "assets/models/ambu-bag.glb", "dummy", "dummy", "dummy", "dummy", "dummy", "dummy");

    @override
    void initState() {
        super.initState();
        // _loadManifest().whenComplete(() => setState(() {}));
    }

    @override
    Widget build(BuildContext context) {
        return SafeArea(
            child: ListView(
                children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Column(
                        children: [
                          Text("Library", style: TextStyle(fontSize: 20)),
                          SearchForm(
                            categories: EquipmentManager().categories, 
                            onChange: (String? query, Map? categories) {
                              EquipmentManager().searchEquipments(query);
                              EquipmentManager().searchCategories(categories);
                              if (!mounted) return;
                              setState(() {});
                            }
                          ),
                        ],
                      )
                    ),
                    for (var equipment in EquipmentManager().equipmentsFiltered)
                        EquipmentRow(equipment: equipment),
                    // EquipmentRow(equipment: ),
                ],
            )
        );
    }

  // Future<void> _loadManifest() async {
  //   final String response = await rootBundle.loadString('assets/descriptions/combined_equipment.json');
  //   final Map<String, dynamic> data = jsonDecode(response);

  //   equipments = data.entries.map((entry) {
  //     // entry.key is the "name"
  //     // entry.value is the map containing {"other": value}
  //     return Equipment.fromJson(entry.key, entry.value);
  //   }).toList();
  // }
}