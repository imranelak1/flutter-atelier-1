import 'package:flutter/material.dart';
import 'src/app.dart';

void main() {
  const configured = String.fromEnvironment('EXERCISE', defaultValue: 'd');
  final name = Uri.base.queryParameters['exercise'] ?? configured;
  final exercise = Exercise.values.firstWhere(
    (value) => value.name == name,
    orElse: () => Exercise.d,
  );
  runApp(MyApp(exercise: exercise));
}
