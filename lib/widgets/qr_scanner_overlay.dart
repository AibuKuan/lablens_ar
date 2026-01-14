import 'package:flutter/material.dart';

class QRScannerOverlay extends StatefulWidget {
  final Rect scanWindow;
  final Color backgroundColor;
  final Color borderColor;
  final double borderStrokeWidth;
  final double borderRadius;
  final double cornerLength;

  const QRScannerOverlay({
    super.key,
    required this.scanWindow,
    this.backgroundColor = Colors.black45,
    this.borderColor = Colors.white,
    this.borderStrokeWidth = 3.0,
    this.borderRadius = 8.0,
    this.cornerLength = 30.0, // New property for corner length in pixels
  });


  @override
  State<QRScannerOverlay> createState() => _QRScannerOverlayState();
}

/// A custom overlay widget to draw a frame around the scan window.
class _QRScannerOverlayState extends State<QRScannerOverlay> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2), // Full cycle duration
    )..repeat(reverse: true); // Move up and down repeatedly

    _animation = Tween(begin: 0.0, end: 1.0).animate(_animationController);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // The scanWindow is assumed to be in pixel coordinates here.
        final Rect actualScanRect = Rect.fromLTWH(
          widget.scanWindow.left,
          widget.scanWindow.top,
          widget.scanWindow.width,
          widget.scanWindow.height,
        );

        return Stack(
          children: <Widget>[
            // 1. Dark Background with Hole Cutout (Uses CustomClipper)
            ClipPath(
              clipper: ScannerClipper(actualScanRect),
              child: Container(
                color: widget.backgroundColor, // Guaranteed dark background color
              ),
            ),
            
            // 2. The Stylish Corner Brackets (CustomPaint)
            Positioned.fromRect(
              rect: actualScanRect,
              child: CustomPaint(
                painter: CornerPainter(
                  borderColor: widget.borderColor,
                  borderStrokeWidth: widget.borderStrokeWidth,
                  cornerLength: widget.cornerLength,
                  borderRadius: widget.borderRadius,
                ),
              ),
            ),
          
            // 3. Animated Scanning Line
            AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                // Interpolate the line's Y position from top to bottom of the scan area
                final double lineY = actualScanRect.top + (_animation.value * actualScanRect.height);

                return Positioned(
                  left: actualScanRect.left,
                  top: lineY,
                  child: Container(
                    width: actualScanRect.width,
                    height: widget.borderStrokeWidth, // Line thickness
                    decoration: BoxDecoration(
                      color: Colors.red,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.red.withValues(alpha: 0.5),
                          blurRadius: 4.0,
                          spreadRadius: 2.0,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }
}

class ScannerClipper extends CustomClipper<Path> {
  final Rect cutoutRect;

  ScannerClipper(this.cutoutRect);

  @override
  Path getClip(Size size) {
    // 1. Create a path that covers the entire container area.
    final path = Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height));

    // 2. Subtract the area where the scan window is located.
    // Use the Rect properties directly (already in pixels).
    path.addRRect(RRect.fromRectAndRadius(cutoutRect, const Radius.circular(8.0)));
    
    // Crucial for the cutout effect: includes all area except the overlapping one
    path.fillType = PathFillType.evenOdd; 
    
    return path;
  }

  @override
  bool shouldReclip(ScannerClipper oldClipper) => oldClipper.cutoutRect != cutoutRect;
}

// --- NEW CUSTOM PAINTER CLASS ---

class CornerPainter extends CustomPainter {
  final Color borderColor;
  final double borderStrokeWidth;
  final double cornerLength;
  final double borderRadius;

  CornerPainter({
    required this.borderColor,
    required this.borderStrokeWidth,
    required this.cornerLength,
    required this.borderRadius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = borderColor
      ..strokeWidth = borderStrokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.square;

    final double halfStroke = borderStrokeWidth / 2;

    // We draw lines that start slightly inward to respect stroke width and border radius.
    // The canvas size here is exactly the size of the actualScanRect (width/height).

    // TOP LEFT CORNER
    // Horizontal line
    canvas.drawLine(
      Offset(halfStroke, halfStroke),
      Offset(halfStroke + cornerLength, halfStroke),
      paint,
    );
    // Vertical line
    canvas.drawLine(
      Offset(halfStroke, halfStroke),
      Offset(halfStroke, halfStroke + cornerLength),
      paint,
    );

    // TOP RIGHT CORNER
    // Horizontal line
    canvas.drawLine(
      Offset(size.width - halfStroke, halfStroke),
      Offset(size.width - halfStroke - cornerLength, halfStroke),
      paint,
    );
    // Vertical line: Starts at the top edge and extends down by cornerLength.
    canvas.drawLine(
      Offset(size.width - halfStroke, halfStroke),
      Offset(size.width - halfStroke, halfStroke + cornerLength),
      paint,
    );

    // BOTTOM LEFT CORNER
    // Horizontal line
    canvas.drawLine(
      Offset(halfStroke, size.height - halfStroke),
      Offset(halfStroke + cornerLength, size.height - halfStroke),
      paint,
    );
    // Vertical line: Starts at the bottom edge and extends up by cornerLength.
    canvas.drawLine(
      Offset(halfStroke, size.height - halfStroke),
      Offset(halfStroke, size.height - halfStroke - cornerLength),
      paint,
    );

    // BOTTOM RIGHT CORNER
    // Horizontal line
    canvas.drawLine(
      Offset(size.width - halfStroke, size.height - halfStroke),
      Offset(size.width - halfStroke - cornerLength, size.height - halfStroke),
      paint,
    );
    // Vertical line: Starts at the bottom edge and extends up by cornerLength.
    canvas.drawLine(
      Offset(size.width - halfStroke, size.height - halfStroke),
      Offset(size.width - halfStroke, size.height - halfStroke - cornerLength),
      paint,
    );
    
    // Note: To perfectly implement rounded corners, you would use drawArc or 
    // paths around the corners, but the linear approach above is a great 
    // simplification for a clean aesthetic.
  }

  @override
  bool shouldRepaint(covariant CornerPainter oldDelegate) {
    return oldDelegate.borderColor != borderColor ||
        oldDelegate.borderStrokeWidth != borderStrokeWidth ||
        oldDelegate.cornerLength != cornerLength;
  }
}