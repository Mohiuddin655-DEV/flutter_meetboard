import 'package:flutter/material.dart';

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
        body: const DraggableView(),
      ),
    );
  }
}

class DraggableView extends StatefulWidget {
  const DraggableView({Key? key}) : super(key: key);

  @override
  State<DraggableView> createState() => _DraggableViewState();
}

class _DraggableViewState extends State<DraggableView> {
  double left = 0.0, top = 0.0;
  double containerWidth = 100;
  double containerHeight = 100;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return Stack(
        children: [
          Positioned(
            left: left,
            top: top,
            child: GestureDetector(
              onPanUpdate: (details) {
                double _x = left + details.delta.dx;
                double _y = top + details.delta.dy;

                if (_x < 0) {
                  _x = 0;
                }
                if (_x > constraints.maxWidth - containerWidth) {
                  _x = constraints.maxWidth - containerWidth;
                }
                if (_y < 0) {
                  _y = 0;
                }
                if (_y > constraints.maxHeight - containerHeight) {
                  _y = constraints.maxHeight - containerHeight;
                }

                // Check if the object is near the center position
                double xCenter = _x + containerWidth / 2;
                double yCenter = _y + containerHeight / 2;
                double xMid = constraints.maxWidth / 2;
                double yMid = constraints.maxHeight / 2;

                if ((xCenter - xMid).abs() < 10 && (yCenter - yMid).abs() < 10) {
                  // Do not allow the object to be in the center
                  return;
                }

                setState(() {
                  left = _x;
                  top = _y;
                });
              },
              onTap: () {},
              child: Container(
                width: containerWidth,
                height: containerHeight,
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
        ],
      );
    });
  }
}
