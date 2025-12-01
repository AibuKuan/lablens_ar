import 'package:ar_app/models/equipment.dart';
import 'package:flutter/material.dart';
import 'package:flutter_3d_controller/flutter_3d_controller.dart';


// Custom widget to display the 3D model and equipment details
class ModelViewerScreen extends StatefulWidget {
  final Equipment equipment;

  const ModelViewerScreen({
    super.key,
    required this.equipment,
  });

  @override
  State<ModelViewerScreen> createState() => _ModelViewerScreenState();
}

class _ModelViewerScreenState extends State<ModelViewerScreen> {
  final Flutter3DController _controller = Flutter3DController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.equipment.name} 3D View'),
        backgroundColor: Colors.blueGrey,
      ),
      body: Container(
        color: Colors.grey[200],
        child: Flutter3DViewer(
          controller: _controller,
          // Replace with your actual model path handling
          src: widget.equipment.modelPath,
          // Optional: Listen for load events
          onLoad: (value) {
            debugPrint('3D model loaded: ${widget.equipment.name}');
            _controller.playAnimation(animationName: "bellModel");
            _controller.playAnimation(animationName: "bellDialog");
          },
        ),
      ),
    );
  }
}