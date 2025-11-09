import 'package:ar_app/services/model.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import 'ar_view_screen.dart';


class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  final MobileScannerController _controller = MobileScannerController();

  @override
  void dispose() {
    _controller.stop();
    super.dispose();
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
          final model = await Model.create(code);
          model.exists().then((value) {
            if (!value) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Model not found'),
                  backgroundColor: Colors.red,
                ),
              );
            } else {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => ARViewScreen(model: model)),
              ).then((_) => _controller.start());
            }
          });
        }
      }
    );   
  }
}