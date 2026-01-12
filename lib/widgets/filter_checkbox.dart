import 'package:flutter/material.dart';

class FilterCheckbox extends StatefulWidget {
  final bool value;
  final String label;
  final ValueChanged<bool?> onChanged;

  const FilterCheckbox({
    super.key,
    required this.value,
    required this.label,
    required this.onChanged,
  });

  @override
  State<FilterCheckbox> createState() => _FilterCheckboxState();
}

class _FilterCheckboxState extends State<FilterCheckbox> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black12,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
      child: Row(
        mainAxisSize: MainAxisSize.min, 
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Checkbox(
            value: widget.value,
            onChanged: (bool? value) {
              widget.onChanged(value);
              setState(() {});
            },
          ),
          // const SizedBox(height: 10),
          Text(widget.label),
        ],
      ),
    );
  }
}