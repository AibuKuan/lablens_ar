import 'package:flutter/material.dart';

class ModelScaler extends StatefulWidget {
  final double initialValue = 1.0;
  final double min = 0.1;
  final double max = 2.0;
  final Function(double) onChanged;

  const ModelScaler({super.key, required this.onChanged});

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

  @override
  Widget build(BuildContext context) {
    return Slider(
      onChanged: (newValue) {
        setState(() {
          _currentValue = newValue;
        });
      }, 
      onChangeEnd: (value) => widget.onChanged(value),
      value: _currentValue, 
      min: widget.min, 
      max: widget.max,
    );
  }
}