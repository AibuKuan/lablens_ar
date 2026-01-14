import 'package:lablens_ar/screens/ar_view_screen.dart';
import 'package:lablens_ar/services/model.dart';
import 'package:flutter/material.dart';

void showARView(BuildContext context, Model model, VoidCallback callback) {
  Navigator.of(context).push(
    MaterialPageRoute(builder: (context) => ARViewScreen(model: model)),
  ).then((_) => callback());
}