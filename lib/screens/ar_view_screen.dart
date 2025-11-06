import 'package:ar_app/widgets/equipment_detail.dart';
import 'package:ar_flutter_plugin_2/ar_flutter_plugin.dart';
import 'package:ar_flutter_plugin_2/datatypes/config_planedetection.dart';
import 'package:ar_flutter_plugin_2/datatypes/hittest_result_types.dart';
import 'package:ar_flutter_plugin_2/datatypes/node_types.dart';
import 'package:ar_flutter_plugin_2/managers/ar_anchor_manager.dart';
import 'package:ar_flutter_plugin_2/managers/ar_location_manager.dart';
import 'package:ar_flutter_plugin_2/managers/ar_object_manager.dart';
import 'package:ar_flutter_plugin_2/managers/ar_session_manager.dart';
import 'package:ar_flutter_plugin_2/models/ar_anchor.dart';
import 'package:ar_flutter_plugin_2/models/ar_hittest_result.dart'; 
import 'package:ar_flutter_plugin_2/models/ar_node.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vector_math/vector_math_64.dart' as vector;

import '../services/model.dart';

class ARViewScreen extends StatefulWidget {
  final Model model;

  const ARViewScreen({super.key, required this.model});
  
  @override
  State<ARViewScreen> createState() => _ARViewScreenState();
}

class _ARViewScreenState extends State<ARViewScreen> {
  // AR Managers
  late ARSessionManager arSessionManager;
  late ARObjectManager arObjectManager;
  late ARAnchorManager arAnchorManager;
  late ARLocationManager arLocationManager;

  // State for the anchored object
  ARNode? placedNode;
  ARPlaneAnchor? currentAnchor;

  @override
  void initState() {
    super.initState();
    // Hide system UI for immersive experience
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  @override
  void dispose() {
    // Clean up managers and restore system UI
    arSessionManager.dispose();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          placedNode == null ? 'Tap a Surface to Place Model' : 'Model Placed - Tap to Move', 
          style: const TextStyle(fontSize: 16),
        ),
        backgroundColor: Colors.black54,
      ),
      body: GestureDetector(
        onVerticalDragEnd: (details) {
          if (details.primaryVelocity! < -500) {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              builder: (context) {
                return DraggableScrollableSheet(
                  initialChildSize: 0.5,
                  minChildSize: 0.5,
                  maxChildSize: 0.9,
                  expand: false,
                  builder: (context, controller) {
                    return Container(
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(16.0),
                          topRight: Radius.circular(16.0),
                        )
                      ),

                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                              width: 40,
                              height: 5,
                              decoration: BoxDecoration(
                                color: Colors.grey,
                                borderRadius: BorderRadius.circular(10),
                              )
                            )
                          ),

                          Expanded(
                            child: ListView(
                              controller: controller,
                              children: [
                                EquipmentDetail(),
                              ]
                            )
                          )
                        ]
                      )
                    );
                  },
                );
              },
            );
          }
        },
      child: ARView(
          onARViewCreated: _onARViewCreated,
          // Enable both horizontal and vertical plane detection
          planeDetectionConfig: PlaneDetectionConfig.horizontalAndVertical,
        ),
      )
    //   body: Stack(
    //     children: [
    //       ARView(
    //         onARViewCreated: _onARViewCreated,
    //         // Enable both horizontal and vertical plane detection
    //         planeDetectionConfig: PlaneDetectionConfig.horizontalAndVertical,
    //       ),

    //       Positioned(
    //         bottom: 20,
    //         right: 20,
    //         child: ElevatedButton(
    //           onPressed: () {
    //             showModalBottomSheet(
    //               context: context,
    //               isScrollControlled: true,
    //               builder: (context) {
    //                 return DraggableScrollableSheet(
    //                   initialChildSize: 0.5,
    //                   minChildSize: 0.5,
    //                   maxChildSize: 0.9,
    //                   expand: false,
    //                   builder: (context, controller) {
    //                     return EquipmentDetail();
    //                   },
    //                 );
    //               },
    //             );
    //           },
    //           child: const Text('View Detail'),
    //         ),
    //       )
    //     ]
    //   ),
    );
  }

  void _onARViewCreated(
    ARSessionManager sessionManager, 
    ARObjectManager objectManager, 
    ARAnchorManager anchorManager, 
    ARLocationManager locationManager,
  ) {
    arSessionManager = sessionManager;
    arObjectManager = objectManager;
    arAnchorManager = anchorManager;
    arLocationManager = locationManager;

    // 1. Session Initialization
    arSessionManager.onInitialize(
      showFeaturePoints: false,
      showPlanes: true, // Show planes to guide user taps
      showWorldOrigin: false,
      handleTaps: true, // Enable tap handling for placement
    );
    
    // 2. Set Callbacks
    arSessionManager.onPlaneOrPointTap = _onPlaneOrPointTapped;
    
    // 3. Object Manager Initialization & Gestures
    arObjectManager.onInitialize();
    
    // Handlers only take the nodeName as argument
    arObjectManager.onPanChange = _onPanChange;
    arObjectManager.onRotationChange = _onRotationChange;
    
    // Note: The onNodeScale handler is not explicitly available.
  }

  // --- Gesture Handlers (for fine-tuning movement, rotation) ---
  // Signature now only accepts String nodeName
  void _onPanChange(String nodeName) {
    // This function is triggered when the user drags the model (Pan gesture).
    debugPrint('Node $nodeName panned.');
    // The plugin handles the underlying anchor movement automatically.
  }

  // Signature now only accepts String nodeName
  void _onRotationChange(String nodeName) {
    // This function is triggered when the user rotates the model (Rotation gesture).
    debugPrint('Node $nodeName rotated.');
  }

  // --- Core Re-Anchoring Logic (for moving the model to a new tap location) ---
  Future<void> _onPlaneOrPointTapped(List<ARHitTestResult> hitTestResults) async {
    ARHitTestResult? hit;

    // 1. Find a valid hit result (plane is preferred for stability)
    for (var r in hitTestResults) {
      if (r.type == ARHitTestResultType.plane) {
        hit = r;
        break;
      }
    }
    // Fallback to point if no plane was hit
    if (hit == null) {
        for (var r in hitTestResults) {
            // ARHitTestResultType is 'point'
            if (r.type == ARHitTestResultType.point) {
                hit = r;
                break;
            }
        }
    }

    if (hit == null) {
      // No suitable surface was hit
      return;
    }

    // 2. Remove the previous anchor and node if they exist (to simulate a move)
    if (currentAnchor != null) {
      await arAnchorManager.removeAnchor(currentAnchor!);
      currentAnchor = null;
    }
    if (placedNode != null) {
        await arObjectManager.removeNode(placedNode!);
        placedNode = null;
    }
    
    // 3. Create and add a new anchor at the hit location
    // The constructor requires 'type' and 'transformation'.
    final newAnchor = ARPlaneAnchor(
      transformation: hit.worldTransform
    );
    final didAddAnchor = await arAnchorManager.addAnchor(newAnchor);

    if (didAddAnchor == true) {
      currentAnchor = newAnchor;

      // 4. Create the node and attach it to the new anchor
      placedNode = ARNode(
        type: NodeType.localGLTF2,
        uri: widget.model.path,
        // Set an appropriate default scale
        scale: vector.Vector3(0.2, 0.2, 0.2), 
        // transformation: hit.worldTransform,
      );

      await arObjectManager.addNode(placedNode!, planeAnchor: currentAnchor);
      
      // Update UI state to show the model is placed
      setState(() {
        // Triggers a rebuild to update the AppBar text
      });
    }
  }
}
