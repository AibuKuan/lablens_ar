import 'package:flutter/material.dart';

// Assuming this is your ModelScaler widget
class ModelScaler extends StatefulWidget {
  final ValueChanged<double> onChanged;
  final double min;
  final double max;
  final double initialValue;

  const ModelScaler({
    super.key,
    required this.onChanged,
    this.min = 0.5,
    this.max = 2.0,
    this.initialValue = 1.0,
  });

  @override
  State<ModelScaler> createState() => _ModelScalerState();
}

class _ModelScalerState extends State<ModelScaler> {
  late double _currentValue;

  @override
  void initState() {
    super.initState();
    _currentValue = widget.initialValue;
  }

  static const double _step = 0.1;

  void _updateValue(double newValue) {
    setState(() {
      _currentValue = newValue.clamp(widget.min, widget.max);
    });
  }

  void _resizeModel(double newScale) {
    widget.onChanged(_currentValue);
  }

  void _decrement() => _updateValue(_currentValue - _step);
  void _increment() => _updateValue(_currentValue + _step);

  @override
  Widget build(BuildContext context) {
    // 1. We use a Column to stack the controls vertically (Top to Bottom).
    return Container(
      // color: Colors.black12,
      // padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
      
      child: Column(
        // mainAxisSize: MainAxisSize.min is crucial for the Column to shrink-wrap its content
        mainAxisSize: MainAxisSize.min, 
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          // 1. PLUS Button (+) - Stays at the Top
          IconButton(
            icon: const Icon(Icons.add, size: 24),
            onPressed: _increment,
            color: Colors.white,
            disabledColor: Colors.white30,
            tooltip: 'Increase Scale',
          ),

          // Add some space between the button and the slider track
          // const SizedBox(height: 16), 

          // 2. The Slider (Rotated 90 degrees)
          // Note: The RotatedBox is now INSIDE the Column.
          RotatedBox(
            quarterTurns: -1, // Rotates the Slider 90 degrees counter-clockwise
            child: SizedBox(
              // The original width of the slider (the track length)
              width: 300, 
              // The original height (thickness) should be small
              height: 40, 
              child: SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  showValueIndicator: ShowValueIndicator.never,
                  thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6.0),
                ),
                child: Slider(
                  onChanged: _updateValue,
                  onChangeEnd: _resizeModel,
                  value: _currentValue,
                  min: widget.min,
                  max: widget.max,
                  activeColor: Colors.white,
                  inactiveColor: Colors.white30,
                ),
              ),
            ),
          ),

          // Add some space between the slider track and the button
          // const SizedBox(height: 16), 

          // 3. MINUS Button (-) - Stays at the Bottom
          IconButton(
            icon: const Icon(Icons.remove, size: 24),
            onPressed: _decrement,
            color: Colors.white,
            disabledColor: Colors.white30,
            tooltip: 'Decrease Scale',
          ),
        ],
      ),
    );
  }

}