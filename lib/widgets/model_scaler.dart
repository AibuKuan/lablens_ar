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
    return Container(
      child: Column(
        mainAxisSize: MainAxisSize.min, 
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          IconButton(
            icon: const Icon(Icons.add, size: 24),
            onPressed: _increment,
            color: Colors.white,
            disabledColor: Colors.white30,
            tooltip: 'Increase Scale',
          ),

          RotatedBox(
            quarterTurns: -1,
            child: SizedBox(
              width: 300, 
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