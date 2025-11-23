import 'package:ar_app/services/model.dart';
import 'package:ar_app/utils/ar.dart';
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

  @override
  Widget build(BuildContext context) {
    return MobileScanner(
      controller: _controller,
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
            } else {
              showARView(context, model, () {
                _controller.start().whenComplete(() => _isStarting = false);
              });
            }
          });
        }
      }
    );   
  }
}