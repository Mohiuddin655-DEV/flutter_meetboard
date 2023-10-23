import 'package:flutter/material.dart';

import 'draggable.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text("Draggable Example"),
        ),
        body: DraggableView(
          draggingAnimTime: 0,
          type: DraggingMode.bottomCenterTopAnywhere,
          object: DraggableObject.circle(
            size: 100,
            child: Container(color: Colors.red),
          ),
          child: const SizedBox(
            width: double.infinity,
            height: double.infinity,
          ),
        ),
      ),
    );
  }
}
