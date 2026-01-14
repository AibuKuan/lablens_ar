import 'package:lablens_ar/widgets/equipment_detail.dart';
import 'package:lablens_ar/widgets/jumping_arrow_indicator.dart';
import 'package:ar_flutter_plugin_2/ar_flutter_plugin.dart';
import 'package:ar_flutter_plugin_2/datatypes/config_planedetection.dart';
import 'package:ar_flutter_plugin_2/datatypes/hittest_result_types.dart';
import 'package:ar_flutter_plugin_2/managers/ar_anchor_manager.dart';
import 'package:ar_flutter_plugin_2/managers/ar_location_manager.dart';
import 'package:ar_flutter_plugin_2/managers/ar_object_manager.dart';
import 'package:ar_flutter_plugin_2/managers/ar_session_manager.dart';
import 'package:ar_flutter_plugin_2/models/ar_anchor.dart';
import 'package:ar_flutter_plugin_2/models/ar_hittest_result.dart'; 
import 'package:ar_flutter_plugin_2/models/ar_node.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../services/model.dart';
import '../widgets/model_scaler.dart';

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
                                EquipmentDetail(detail: widget.model.detail!),
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
        child: Stack(
          children: [
            ARView(
              onARViewCreated: _onARViewCreated,
              planeDetectionConfig: PlaneDetectionConfig.horizontalAndVertical,
            ),

            Positioned(
              top: 50,
              bottom: 50,
              right: 10,
              child: ModelScaler(onChanged: widget.model.scale)
            ),

            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const JumpingArrowIndicator(),
                    const SizedBox(height: 10),
                    const SizedBox(height: 10), 
                  ],
                ),
              ),
            ),
          ]
        )
      )
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

    widget.model.addObjectManager(arObjectManager);

    arSessionManager.onInitialize(
      showFeaturePoints: false,
      showPlanes: true, // Show planes to guide user taps
      showWorldOrigin: false,
      handleTaps: true, // Enable tap handling for placement
    );
    
    arSessionManager.onPlaneOrPointTap = _onPlaneOrPointTapped;
    
    arObjectManager.onInitialize();
    
    arObjectManager.onPanChange = _onPanChange;
    arObjectManager.onRotationChange = _onRotationChange;
  }

  void _onPanChange(String nodeName) {
    debugPrint('Node $nodeName panned.');
  }

  void _onRotationChange(String nodeName) {
    debugPrint('Node $nodeName rotated.');
  }

  Future<void> _onPlaneOrPointTapped(List<ARHitTestResult> hitTestResults) async {
    ARHitTestResult? hit;

    for (var r in hitTestResults) {
      if (r.type == ARHitTestResultType.plane || r.type == ARHitTestResultType.point) {
        hit = r;
        break;
      }
    }

    if (hit == null) {
      return;
    }

    if (currentAnchor != null) {
      await arAnchorManager.removeAnchor(currentAnchor!);
      currentAnchor = null;
    }
    if (placedNode != null) {
      await arObjectManager.removeNode(placedNode!);
      placedNode = null;
    }
    
    final newAnchor = ARPlaneAnchor(
      transformation: hit.worldTransform
    );
    final didAddAnchor = await arAnchorManager.addAnchor(newAnchor);

    if (didAddAnchor == true) {
      currentAnchor = newAnchor;
      widget.model.currentAnchor = currentAnchor;

      placedNode = widget.model.arNode;

      await arObjectManager.addNode(placedNode!, planeAnchor: currentAnchor);
      
      setState(() {});
    }
  }
}
