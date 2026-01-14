import 'package:lablens_ar/screens/model_viewer_screen.dart';
import 'package:lablens_ar/services/model.dart';
import 'package:lablens_ar/utils/ar.dart';
import 'package:lablens_ar/widgets/qr_scanner_overlay.dart';
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

  Future<void> _showViewOptionsDialog(BuildContext context, Model model) async {
    final String? actionChoice = await showDialog<String>(
      context: context,
      barrierDismissible: true,
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
            TextButton(
              child: const Text('CANCEL'),
              onPressed: () {
                Navigator.of(dialogContext).pop('cancel'); 
              },
            ),
            
            TextButton(
              child: const Text('3D VIEWER'),
              onPressed: () {
                Navigator.of(dialogContext).pop('viewer'); 
              },
            ),
            
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

    if (actionChoice == 'ar') {
      showARView(context, model, _restartScanner);
    } else if (actionChoice == 'viewer') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ModelViewerScreen(
            equipment: model.detail!, 
          ),
        ),
      ).then((_) => _restartScanner());
    } else {
      _restartScanner();
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.sizeOf(context).height;
    const double verticalShiftRatio = -0.10;
    
    final double verticalOffset = screenHeight * verticalShiftRatio;

    final Rect scanArea = Rect.fromCenter(
      center: MediaQuery.sizeOf(context).center(Offset(0, verticalOffset)),
      width: 300,
      height: 300,
    );

    return MobileScanner(
      controller: _controller,
      scanWindow: scanArea,
      overlayBuilder: (context, constraints) {
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