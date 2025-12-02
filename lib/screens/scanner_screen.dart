import 'package:ar_app/screens/model_viewer_screen.dart';
import 'package:ar_app/services/model.dart';
import 'package:ar_app/utils/ar.dart';
import 'package:ar_app/widgets/qr_scanner_overlay.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';


class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> with WidgetsBindingObserver {
  final MobileScannerController _controller = MobileScannerController(autoStart: false);
  bool _isStarting = true;
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _controller.start().whenComplete(() => _isStarting = false);
  }

  @override
  void dispose() {
    _controller.stop();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!mounted) return;

    if (state == AppLifecycleState.paused) {
      if (_isStarting) return;
      _controller.stop();
    } else if (state == AppLifecycleState.resumed) {
      if (_isStarting) return;
      _controller.start().whenComplete(() => _isStarting = false);
    }
  }

  // Helper method to restart the scanner
  void _restartScanner() {
    if (_isStarting) return;

    _isStarting = true;
    _controller.start().whenComplete(() => _isStarting = false);
  }

  // The return type is changed to Future<String?> to handle the possible outcomes
  Future<void> _showViewOptionsDialog(BuildContext context, Model model) async {
    // We expect one of three results: 'ar', 'viewer', or null (if canceled/dismissed)
    final String? actionChoice = await showDialog<String>(
      context: context,
      barrierDismissible: true, // Allow user to dismiss by tapping outside
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('View Model Options'),
          content: RichText(
            text: TextSpan(
              style: TextStyle(
                fontSize: 14.0,
                color: Theme.of(dialogContext).textTheme.bodyLarge?.color,
              ),
              children: <TextSpan>[
                const TextSpan(text: 'How do you want to view the model: '),
                TextSpan(
                  text: model.detail?.name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const TextSpan(text: '?'),
              ],
            ),
          ),
          actions: <Widget>[
            // 1. CANCEL Button (Restarts scanner)
            TextButton(
              child: const Text('CANCEL'),
              onPressed: () {
                Navigator.of(dialogContext).pop('cancel'); 
              },
            ),
            
            // 2. MODEL VIEWER Button
            TextButton(
              child: const Text('3D VIEWER'),
              onPressed: () {
                Navigator.of(dialogContext).pop('viewer'); 
              },
            ),
            
            // 3. AR VIEW Button
            TextButton(
              child: const Text('AR VIEW'),
              onPressed: () {
                Navigator.of(dialogContext).pop('ar'); 
              },
            ),
          ],
        );
      },
    );

    // --- ACT BASED ON THE DIALOG RESULT ---
    if (actionChoice == 'ar') {
      // Open AR View
      showARView(context, model, _restartScanner);
    } else if (actionChoice == 'viewer') {
      // Open 2D Model Viewer
      // NOTE: I'm replacing widget.equipment with 'model' assuming that 'model' 
      // contains the necessary data you pass to ModelViewerScreen.
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ModelViewerScreen(
            // Pass the necessary data (e.g., the scanned model)
            equipment: model.detail!, 
          ),
        ),
      ).then((_) => _restartScanner()); // Restart scanner when viewer is closed
    } else {
      // If canceled or dismissed, restart the scanner
      _restartScanner();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get the total height of the widget (usually the screen height)
    final double screenHeight = MediaQuery.sizeOf(context).height;
    
    // Define the desired vertical shift as a fraction of the screen height.
    // Example: Shift up by 10% of the screen height.
    // 0.10 means 10% of the screen height. Use negative to shift up.
    const double verticalShiftRatio = -0.10; // Change this value (e.g., -0.05 for a smaller shift)
    
    // Calculate the fixed pixel offset based on the ratio
    final double verticalOffset = screenHeight * verticalShiftRatio;

    final Rect scanArea = Rect.fromCenter(
      // The center() method calculates the center of the screen size.
      // We then apply our calculated proportional vertical offset.
      center: MediaQuery.sizeOf(context).center(Offset(0, verticalOffset)),
      width: 300,
      height: 300,
    );

    return MobileScanner(
      controller: _controller,
      scanWindow: scanArea,
      overlayBuilder: (context, constraints) {
        // The constraints argument provides the size of the MobileScanner widget.
        // This is passed directly into the QrScannerOverlay.
        return QRScannerOverlay(
          scanWindow: scanArea,
        );
      },
      onDetect: (capture) async {
        final barcode = capture.barcodes.first;
        final String? code = barcode.rawValue;
        if (code != null) {
          _controller.stop();
          final model = await Model.create(name: code);
          model.exists().then((value) {
            if (!value) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Model not found'),
                  backgroundColor: Colors.red,
                ),
              );
              _restartScanner();
            } else {
              _showViewOptionsDialog(context, model);
            }
          });
        }
      }
    );   
  }
}