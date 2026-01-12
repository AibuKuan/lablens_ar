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

  // Helper method to play a specific animation
  void _playAnimation(String animationName) {
    _controller.playAnimation(animationName: animationName, loopCount: 1);
    debugPrint('Playing animation: $animationName');
  }

  // Helper method to reset the animation/model state
  void _resetModel() {
    _controller.stopAnimation();
    debugPrint('Model reset.');
  }

  /// Plays the animation and displays a semi-transparent description dialog 
  /// that automatically dismisses after a short time.
  void _playAnimationWithDescription(
      BuildContext context,
      String animationName,
      String description,
    ) {
    
    // 1. Start the animation immediately
    _playAnimation(animationName);

    // 2. Show the transient dialog
    showDialog(
      context: context,
      barrierDismissible: true,
      useSafeArea: false, // Allows dialog to cover entire screen if needed
      builder: (BuildContext dialogContext) {
        // Use a custom barrier color for semi-transparency
        return Material(
          type: MaterialType.transparency,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Container(
                padding: const EdgeInsets.all(20.0),
                // Use a dark, semi-transparent background
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7), 
                  borderRadius: BorderRadius.circular(15.0),
                ),
                child: Text(
                  description,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18.0,
                    fontWeight: FontWeight.w500,
                    decoration: TextDecoration.none, // Ensure text is clean
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );

    // 3. Set a timer to automatically dismiss the dialog after 3 seconds
    // Note: Adjust the duration as needed (e.g., 3000 milliseconds)
    Future.delayed(const Duration(seconds: 30), () {
      // Check if the dialog is still visible before trying to pop it
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop(); 
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Check if animations are available
    final Map<String, dynamic> animations = (widget.equipment.animations as Map?)
    ?.cast<String, dynamic>() ?? {};
    debugPrint('${widget.equipment.name} Animations: ${widget.equipment.animations}');

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.equipment.name} 3D View'),
        backgroundColor: Colors.blueGrey,
      ),
      body: Stack(
        children: <Widget>[
          Container(
            color: Colors.grey[200],
            child: Flutter3DViewer(
              controller: _controller,
              src: widget.equipment.modelPath,
              onLoad: (value) {
                debugPrint('3D model loaded: ${widget.equipment.name}');
              },
            ),
          ),

          // 2. Overlay Buttons (Aligned to the bottom)
          if (animations.isNotEmpty) // Only show the bar if animations exist
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 20.0, left: 16.0, right: 16.0),
                child: Container(
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Reset Button (Always a good idea)
                        _buildActionButton(
                          icon: Icons.refresh,
                          label: 'Reset',
                          onPressed: _resetModel,
                        ),
                        
                        const SizedBox(width: 8.0),

                        // Dynamically build animation buttons
                        ...animations.entries.map((entry) {
                          final String label = entry.key; // e.g., "Bell"
                          final String animationName = entry.value['animationName']; // e.g., "bellModel"
                          final String description = entry.value['description'];

                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4.0),
                            child: _buildActionButton(
                              icon: Icons.play_arrow,
                              label: label,
                              onPressed: () => _playAnimationWithDescription(
                                context, 
                                animationName, 
                                description,
                              ),
                            ),
                          );
                        }).toList(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      )
    );
  }

  // Reusable widget for cleaner button creation
  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      icon: Icon(icon, size: 18),
      label: Text(label),
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: Colors.blueGrey,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
      ),
    );
  }
}

