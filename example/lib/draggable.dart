import 'dart:math';

import 'package:flutter/material.dart';

class DraggableView extends StatefulWidget {
  final int draggingAnimTime;
  final int draggedAnimTime;
  final DraggingMode type;
  final DraggableObject object;
  final Widget child;

  const DraggableView({
    super.key,
    this.type = DraggingMode.anywhere,
    required this.object,
    required this.child,
    this.draggingAnimTime = 100,
    this.draggedAnimTime = 300,
  });

  @override
  State<DraggableView> createState() => _DraggableViewState();
}

class _DraggableViewState extends State<DraggableView> {
  Offset offset = Offset.zero;
  Offset delta = Offset.zero;

  bool draggingMode = true;

  late double ox;
  late double oy;

  @override
  void initState() {
    ox = widget.object.width;
    oy = widget.object.height;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, con) {
        return Stack(
          children: [
            AnimatedPositioned(
              duration: Duration(
                milliseconds: draggingMode
                    ? widget.draggingAnimTime
                    : widget.draggedAnimTime,
              ),
              left: offset.dx,
              top: offset.dy,
              child: GestureDetector(
                onPanUpdate: (details) {
                  draggingMode = true;
                  delta = details.delta;
                  setState(() {
                    offset = Offset(
                      _currentPosition(offset.dx, delta.dx, con.maxWidth, ox),
                      _currentPosition(offset.dy, delta.dy, con.maxHeight, oy),
                    );
                  });
                },
                onPanEnd: widget.type.isAnywhereMode
                    ? null
                    : (details) {
                        draggingMode = false;
                        if (widget.type.isCornerSideMode) {
                          _cornerSidePosition(con);
                        } else {}
                      },
                onTap: () {},
                child: widget.object,
              ),
            ),
            widget.child,
          ],
        );
      },
    );
  }

  double _currentPosition(
      double old, double current, double total, double ignorable) {
    return max(0, min(old + current, total - ignorable));
  }

  void _cornerSidePosition(BoxConstraints constraints) {
    setState(() {
      offset = DraggingPosition(
        offset: offset,
        constraints: constraints,
      ).centerPosition(ox, oy);
    });
  }
}

class DraggingPosition {
  final Offset offset;
  final BoxConstraints constraints;

  const DraggingPosition({
    required this.offset,
    required this.constraints,
  });

  Alignment get alignment {
    double x = offset.dx;
    double y = offset.dy;
    double xMid = constraints.maxWidth / 2;
    double yMid = constraints.maxHeight / 2;

    var leftSide = x <= xMid;
    var topSide = y <= yMid;
    if (topSide) {
      return leftSide ? Alignment.topLeft : Alignment.topRight;
    } else {
      return leftSide ? Alignment.bottomLeft : Alignment.bottomRight;
    }
  }

  Offset centerPosition(double ox, double oy) {
    double xCenter = offset.dx + ox / 2;
    double yCenter = offset.dy + oy / 2;
    double xMid = constraints.maxWidth / 2;
    double yMid = constraints.maxHeight / 2;

    double xTarget;
    double yTarget;

    if (xCenter <= xMid) {
      xTarget = 0;
    } else {
      xTarget = constraints.maxWidth - ox;
    }

    if (yCenter <= yMid) {
      yTarget = 0;
    } else {
      yTarget = constraints.maxHeight - oy;
    }
    return Offset(xTarget, yTarget);
  }
}

enum DraggingMode {
  anySide,
  anywhere,
  cornerSide;

  bool get isAnySide => this == DraggingMode.anySide;

  bool get isAnywhereMode => this == DraggingMode.anywhere;

  bool get isCornerSideMode => this == DraggingMode.cornerSide;
}

class DraggableObject extends StatelessWidget {
  final double width;
  final double height;
  final bool circular;
  final Widget? child;

  const DraggableObject({
    super.key,
    required this.width,
    required this.height,
    this.child,
  }) : circular = false;

  const DraggableObject.circle({
    super.key,
    required double size,
    this.child,
  })  : width = size,
        height = size,
        circular = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        shape: circular ? BoxShape.circle : BoxShape.rectangle,
      ),
      child: child,
    );
  }
}
