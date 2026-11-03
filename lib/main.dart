import 'package:flutter/material.dart';

void main() => runApp(const FeatureLabApp());

class FeatureLabApp extends StatelessWidget {
  const FeatureLabApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Flutter Feature Lab',
    theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.teal),
    home: const Scaffold(body: Center(child: Text('Flutter Feature Lab'))),
  );
}
