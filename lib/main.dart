import 'package:flutter/material.dart';
import './home.dart';

void main() => runApp(Spook());

class Spook extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Spook',
      theme: ThemeData(brightness: Brightness.dark),
      home: Home()
    );
  }
}
