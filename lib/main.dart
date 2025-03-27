import 'package:flutter/material.dart';
import 'package:kyrsach/pages/stores.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Store Network System',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: StoreListScreen(),
    );
  }
}