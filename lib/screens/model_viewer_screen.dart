import 'package:flutter/material.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';

class ModelViewerScreen extends StatelessWidget {
  // 1. Define the property to hold the model source path
  final String modelSrc;

  // 2. Require the modelSrc in the constructor
  ModelViewerScreen({
    super.key,
    required this.modelSrc,
  });

  @override
  Widget build(BuildContext context) {
    // Uses a Stack and Positioned.fill to ensure the ModelViewer 
    // takes up the entire available screen space.
    return Stack(
      children: [
        Positioned.fill(
          child: ModelViewer(
            // 3. Use the dynamic model source here
            src: modelSrc, 
            autoRotate: true,
            cameraControls: true,
            backgroundColor: const Color.fromARGB(0xFF, 0xEE, 0xEE, 0xEE),
            ar: true,
          ),
        ),
      ],
    );
  }
}