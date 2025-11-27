import 'package:ar_app/screens/model_viewer_screen.dart';
import 'package:ar_app/services/model.dart';
import 'package:ar_app/utils/ar.dart';
import 'package:ar_app/utils/asset.dart';
import 'package:flutter/material.dart';
import 'package:ar_app/models/equipment.dart'; // Ensure correct path to your model


class EquipmentRow extends StatefulWidget {
  final Equipment equipment;
  const EquipmentRow({super.key, required this.equipment});

  @override
  State<EquipmentRow> createState() => _EquipmentRowState();
}


class _EquipmentRowState extends State<EquipmentRow> {
  Map<String, dynamic> fileSize = {};

  @override
  void initState() {
    super.initState();
    getFileSize(widget.equipment.modelPath).then((value) {
      setState(() {
        fileSize = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    // FIX: Using LayoutBuilder and SizedBox to safely get and enforce a finite width constraint
    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth = constraints.hasBoundedWidth 
                          ? constraints.maxWidth 
                          : MediaQuery.of(context).size.width;

        return SizedBox(
          width: cardWidth, 
          child: Card(
            margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // 1. Expanded Text Content Area
                  Expanded( 
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // ROW 1: Name and File Size
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Equipment Name (Wrapped in Expanded)
                            Expanded( 
                              child: Text(
                                widget.equipment.name,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            
                            const SizedBox(width: 10), 
                            
                            // FILE SIZE
                            Text(
                              "${fileSize['size']} ${fileSize['unit']}",
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                        

                        const SizedBox(height: 6),
                        

                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary.withAlpha((0.15 * 255).toInt()),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            widget.equipment.category ?? '',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).primaryColor,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),


                        const SizedBox(width: 8),
                            

                        // Function Text (Wrapped in Expanded)
                        Flexible(
                          child: Text(
                            widget.equipment.function ?? '',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black87,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(width: 15),
                  
                  // 2. Action Buttons
                  widget.equipment.modelPath.isEmpty ?
                  IconButton(
                    onPressed: () {}, 
                    icon: Icon(
                      Icons.download,
                      size: 30,
                      color: Theme.of(context).primaryColor,
                    )
                  )
                  :
                  Column(
                    children: [
                      IconButton(
                        onPressed: () async {
                          final model = await Model.create(detail: widget.equipment);
                          model.exists().then((value) {
                            if (!value) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Model not found'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            } else {
                              showARView(context, model, () {});
                            }
                          });
                          // Model.create(path: widget.equipment.modelPath).then((model) {
                          //   model.exists().then((value) {
                          //     if (!value) {
                          //       ScaffoldMessenger.of(context).showSnackBar(
                          //         SnackBar(
                          //           content: Text('Model not found'),
                          //           backgroundColor: Colors.red,
                          //         ),
                          //       );
                          //     } else {
                          //       showARView(context, model, () {});
                          //     }
                          //   });
                          //   // showARView(context, model, () {});
                          // });
                        }, 
                        icon: Icon(
                          Icons.view_in_ar,
                          size: 30,
                          color: Theme.of(context).primaryColor,
                        )
                      ),

                      IconButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ModelViewerScreen(
                                modelSrc: widget.equipment.modelPath,
                              ),
                            ),
                          );
                        }, 
                        icon: Icon(
                          Icons.open_with_rounded,
                        )
                      )
                    ]
                  )
                  
                  
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}