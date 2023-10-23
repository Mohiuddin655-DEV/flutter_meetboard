import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

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
  BoxConstraints constraints = const BoxConstraints();
  Offset offset = Offset.zero;
  Size objectSize = Size.zero;

  bool draggingMode = true;

  @override
  void initState() {
    objectSize = Size(widget.object.width, widget.object.height);
    SchedulerBinding.instance.addPostFrameCallback(_onPanInit);
    super.initState();
  }

  @override
  void didUpdateWidget(covariant DraggableView oldWidget) {
    SchedulerBinding.instance.addPostFrameCallback(_onPanInit);
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, con) {
        constraints = con;
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
                onPanUpdate: _onPanUpdate,
                onPanEnd: widget.type.isAnywhere ? null : _onPanEndHandle,
                child: widget.object,
              ),
            ),
            widget.child,
          ],
        );
      },
    );
  }

  void _onPanInit([Duration? duration]) {
    draggingMode = true;
    offset = _position(widget.type);
    setState(() {});
  }

  void _onPanUpdate(DragUpdateDetails details) {
    draggingMode = true;
    offset = _position(DraggingMode.anywhere, details.delta);
    setState(() {});
  }

  void _onPanEndHandle(DragEndDetails details) {
    draggingMode = false;
    offset = _position(widget.type);
    setState(() {});
  }

  Offset _position(DraggingMode mode, [Offset delta = Offset.zero]) {
    var position = DraggingPosition(
      constraints: constraints,
      offset: offset,
      objectSize: objectSize,
    );
    switch (mode) {
      case DraggingMode.anywhere:
        return position.anywhere(delta);
      case DraggingMode.bottomCenterTopAnywhere:
        return position.bottomCenterTopAnywhere();
      case DraggingMode.bottomCenterTopCorner:
        return position.bottomCenterTopCorner();
      case DraggingMode.centerSide:
        return position.centerSide();
      case DraggingMode.cornerSide:
        return position.cornerSide();
      case DraggingMode.leftCenterRightAnywhere:
        return position.leftCenterRightAnywhere();
      case DraggingMode.leftCenterRightCorner:
        return position.leftCenterRightCorner();
      case DraggingMode.nearestSide:
        return position.nearestSide();
      case DraggingMode.rightCenterLeftAnywhere:
        return position.rightCenterLeftAnywhere();
      case DraggingMode.rightCenterLeftCorner:
        return position.rightCenterLeftCorner();
      case DraggingMode.topCenterBottomAnywhere:
        return position.topCenterBottomAnywhere();
      case DraggingMode.topCenterBottomCorner:
        return position.topCenterBottomCorner();
    }
  }
}

class DraggingPosition {
  final BoxConstraints constraints;
  final Offset offset;
  final Size objectSize;

  const DraggingPosition({
    required this.constraints,
    required this.offset,
    required this.objectSize,
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

  Offset anywhere(Offset delta) {
    /// Find the object size
    double ox = objectSize.width;
    double oy = objectSize.height;

    /// Find the old offset
    double xTarget = offset.dx;
    double yTarget = offset.dy;

    /// Find the total offset
    double xMax = constraints.maxWidth;
    double yMax = constraints.maxHeight;

    /// Calculate the position of the object
    double x = max(0, min(xTarget + delta.dx, xMax - ox));
    double y = max(0, min(yTarget + delta.dy, yMax - oy));

    return Offset(x, y);
  }

  Offset nearestSide() {
    /// Find the object size
    double ox = objectSize.width;
    double oy = objectSize.height;

    /// Find the old offset
    double xTarget = offset.dx;
    double yTarget = offset.dy;

    /// Find the total offset
    double xMax = constraints.maxWidth;
    double yMax = constraints.maxHeight;

    /// Calculate the center of the object
    double xCenter = xTarget + (ox / 2);
    double yCenter = yTarget + (oy / 2);

    /// Calculate the distances from each side
    double leftDistance = xCenter;
    double rightDistance = xMax - xCenter;
    double topDistance = yCenter;
    double bottomDistance = yMax - yCenter;

    /// Find the nearest side
    double minDistance = min(
      leftDistance,
      min(rightDistance, min(topDistance, bottomDistance)),
    );

    if (minDistance == leftDistance) {
      xTarget = 0;
    } else if (minDistance == rightDistance) {
      xTarget = xMax - ox;
    } else if (minDistance == topDistance) {
      yTarget = 0;
    } else if (minDistance == bottomDistance) {
      yTarget = yMax - oy;
    }

    return Offset(xTarget, yTarget);
  }

  Offset cornerSide() {
    /// Find the object size
    double ox = objectSize.width;
    double oy = objectSize.height;

    /// Find the old offset
    double xTarget = offset.dx;
    double yTarget = offset.dy;

    /// Find the total offset
    double xMax = constraints.maxWidth;
    double yMax = constraints.maxHeight;

    /// Calculate the center of the object
    double xCenter = xTarget + ox / 2;
    double yCenter = yTarget + oy / 2;

    /// Calculate the mid of the area
    double xMid = xMax / 2;
    double yMid = yMax / 2;

    /// Find the nearest corner
    if (xCenter <= xMid) {
      xTarget = 0;
    } else {
      xTarget = xMax - ox;
    }

    if (yCenter <= yMid) {
      yTarget = 0;
    } else {
      yTarget = yMax - oy;
    }

    return Offset(xTarget, yTarget);
  }

  Offset centerSide() {
    /// Find the object size
    double ox = objectSize.width;
    double oy = objectSize.height;

    /// Find the old offset
    double xTarget = offset.dx;
    double yTarget = offset.dy;

    /// Find the total offset
    double xMax = constraints.maxWidth;
    double yMax = constraints.maxHeight;

    /// Calculate the center of the object
    double xCenter = xTarget + ox / 2;
    double yCenter = yTarget + oy / 2;

    /// Calculate the distances from each side
    double leftDistance = xCenter;
    double rightDistance = xMax - (xCenter + ox);
    double topDistance = yCenter;
    double bottomDistance = yMax - (yCenter + oy);

    /// Find the nearest side
    double minDistance = min(
      leftDistance,
      min(rightDistance, min(topDistance, bottomDistance)),
    );

    if (minDistance == leftDistance) {
      xTarget = 0;
      yTarget = (yMax - oy) / 2;
    } else if (minDistance == rightDistance) {
      xTarget = xMax - ox;
      yTarget = (yMax - oy) / 2;
    } else if (minDistance == topDistance) {
      xTarget = (xMax - ox) / 2;
      yTarget = 0;
    } else if (minDistance == bottomDistance) {
      xTarget = (xMax - ox) / 2;
      yTarget = yMax - oy;
    }

    return Offset(xTarget, yTarget);
  }

  Offset bottomCenterTopAnywhere() {
    /// Find the object size
    double ox = objectSize.width;
    double oy = objectSize.height;

    /// Find the old offset
    double xTarget = offset.dx;
    double yTarget = offset.dy;

    /// Find the total offset
    double xMax = constraints.maxWidth;
    double yMax = constraints.maxHeight;

    /// Calculate the center of the object
    double yCenter = yTarget + (oy / 2);

    /// Calculate the distances from each side
    double topDistance = yCenter;
    double bottomDistance = yMax - yCenter;

    /// Find the nearest side
    double minDistance = min(topDistance, bottomDistance);

    if (minDistance == topDistance) {
      yTarget = 0;
    } else if (minDistance == bottomDistance) {
      xTarget = (xMax - ox) / 2;
      yTarget = yMax - oy;
    }

    return Offset(xTarget, yTarget);
  }

  Offset bottomCenterTopCorner() {
    /// Find the object size
    double ox = objectSize.width;
    double oy = objectSize.height;

    /// Find the old offset
    double xTarget = offset.dx;
    double yTarget = offset.dy;

    /// Find the total offset
    double xMax = constraints.maxWidth;
    double yMax = constraints.maxHeight;

    /// Calculate the center of the object
    double xCenter = xTarget + ox / 2;
    double yCenter = yTarget + oy / 2;

    /// Calculate the distances from each side
    double topDistance = yCenter;
    double bottomDistance = yMax - (yCenter + oy);

    /// Find the nearest side
    double minDistance = min(topDistance, bottomDistance);

    if (minDistance == topDistance) {
      yTarget = 0;

      /// Calculate the mid of the area
      double xMid = xMax / 2;

      /// Find the nearest corner
      if (xCenter <= xMid) {
        xTarget = 0;
      } else {
        xTarget = xMax - ox;
      }
    } else if (minDistance == bottomDistance) {
      xTarget = (xMax - ox) / 2;
      yTarget = yMax - oy;
    }

    return Offset(xTarget, yTarget);
  }

  Offset topCenterBottomAnywhere() {
    /// Find the object size
    double ox = objectSize.width;
    double oy = objectSize.height;

    /// Find the old offset
    double xTarget = offset.dx;
    double yTarget = offset.dy;

    /// Find the total offset
    double xMax = constraints.maxWidth;
    double yMax = constraints.maxHeight;

    /// Calculate the center of the object
    double yCenter = yTarget + (oy / 2);

    /// Calculate the distances from each side
    double topDistance = yCenter;
    double bottomDistance = yMax - yCenter;

    /// Find the nearest side
    double minDistance = min(topDistance, bottomDistance);

    if (minDistance == topDistance) {
      yTarget = 0;
      xTarget = (xMax - ox) / 2;
    } else if (minDistance == bottomDistance) {
      yTarget = yMax - oy;
    }

    return Offset(xTarget, yTarget);
  }

  Offset topCenterBottomCorner() {
    /// Find the object size
    double ox = objectSize.width;
    double oy = objectSize.height;

    /// Find the old offset
    double xTarget = offset.dx;
    double yTarget = offset.dy;

    /// Find the total offset
    double xMax = constraints.maxWidth;
    double yMax = constraints.maxHeight;

    /// Calculate the center of the object
    double xCenter = xTarget + ox / 2;
    double yCenter = yTarget + oy / 2;

    /// Calculate the distances from each side
    double topDistance = yCenter;
    double bottomDistance = yMax - (yCenter + oy);

    /// Find the nearest side
    double minDistance = min(topDistance, bottomDistance);

    if (minDistance == topDistance) {
      yTarget = 0;
      xTarget = (xMax - ox) / 2;
    } else if (minDistance == bottomDistance) {
      /// Calculate the mid of the area
      double xMid = xMax / 2;

      /// Find the nearest corner
      if (xCenter <= xMid) {
        xTarget = 0;
      } else {
        xTarget = xMax - ox;
      }

      yTarget = yMax - oy;
    }

    return Offset(xTarget, yTarget);
  }

  Offset leftCenterRightAnywhere() {
    /// Find the object size
    double ox = objectSize.width;
    double oy = objectSize.height;

    /// Find the old offset
    double xTarget = offset.dx;
    double yTarget = offset.dy;

    /// Find the total offset
    double xMax = constraints.maxWidth;
    double yMax = constraints.maxHeight;

    /// Calculate the center of the object
    double xCenter = xTarget + (ox / 2);

    /// Calculate the distances from each side
    double rightDistance = xCenter;
    double leftDistance = xMax - xCenter;

    /// Find the nearest side
    double minDistance = min(rightDistance, leftDistance);

    if (minDistance == rightDistance) {
      xTarget = 0;
      yTarget = (yMax - oy) / 2;
    } else if (minDistance == leftDistance) {
      xTarget = xMax - ox;
    }

    return Offset(xTarget, yTarget);
  }

  Offset leftCenterRightCorner() {
    /// Find the object size
    double ox = objectSize.width;
    double oy = objectSize.height;

    /// Find the old offset
    double xTarget = offset.dx;
    double yTarget = offset.dy;

    /// Find the total offset
    double xMax = constraints.maxWidth;
    double yMax = constraints.maxHeight;

    /// Calculate the center of the object
    double xCenter = xTarget + ox / 2;
    double yCenter = yTarget + oy / 2;

    /// Calculate the distances from each side
    double rightDistance = xCenter;
    double leftDistance = xMax - (xCenter + ox);

    /// Find the nearest side
    double minDistance = min(rightDistance, leftDistance);

    if (minDistance == rightDistance) {
      xTarget = 0;
      yTarget = (yMax - oy) / 2;
    } else if (minDistance == leftDistance) {
      xTarget = xMax - ox;

      /// Calculate the mid of the area
      double yMid = yMax / 2;

      if (yCenter <= yMid) {
        yTarget = 0;
      } else {
        yTarget = yMax - oy;
      }
    }

    return Offset(xTarget, yTarget);
  }

  Offset rightCenterLeftAnywhere() {
    /// Find the object size
    double ox = objectSize.width;
    double oy = objectSize.height;

    /// Find the old offset
    double xTarget = offset.dx;
    double yTarget = offset.dy;

    /// Find the total offset
    double xMax = constraints.maxWidth;
    double yMax = constraints.maxHeight;

    /// Calculate the center of the object
    double xCenter = xTarget + (ox / 2);

    /// Calculate the distances from each side
    double rightDistance = xCenter;
    double leftDistance = xMax - xCenter;

    /// Find the nearest side
    double minDistance = min(rightDistance, leftDistance);

    if (minDistance == rightDistance) {
      xTarget = 0;
    } else if (minDistance == leftDistance) {
      xTarget = xMax - ox;
      yTarget = (yMax - oy) / 2;
    }

    return Offset(xTarget, yTarget);
  }

  Offset rightCenterLeftCorner() {
    /// Find the object size
    double ox = objectSize.width;
    double oy = objectSize.height;

    /// Find the old offset
    double xTarget = offset.dx;
    double yTarget = offset.dy;

    /// Find the total offset
    double xMax = constraints.maxWidth;
    double yMax = constraints.maxHeight;

    /// Calculate the center of the object
    double xCenter = xTarget + ox / 2;
    double yCenter = yTarget + oy / 2;

    /// Calculate the distances from each side
    double rightDistance = xCenter;
    double leftDistance = xMax - (xCenter + ox);

    /// Find the nearest side
    double minDistance = min(rightDistance, leftDistance);

    if (minDistance == rightDistance) {
      xTarget = 0;

      /// Calculate the mid of the area
      double yMid = yMax / 2;

      /// Find the nearest corner
      if (yCenter <= yMid) {
        yTarget = 0;
      } else {
        yTarget = yMax - oy;
      }
    } else if (minDistance == leftDistance) {
      xTarget = xMax - ox;
      yTarget = (yMax - oy) / 2;
    }

    return Offset(xTarget, yTarget);
  }
}

enum DraggingMode {
  anywhere,
  centerSide,
  cornerSide,
  nearestSide,
  bottomCenterTopAnywhere,
  bottomCenterTopCorner,
  topCenterBottomAnywhere,
  topCenterBottomCorner,
  leftCenterRightAnywhere,
  leftCenterRightCorner,
  rightCenterLeftAnywhere,
  rightCenterLeftCorner;

  bool get isAnywhere => this == DraggingMode.anywhere;

  bool get isCenterSide => this == DraggingMode.centerSide;

  bool get isCornerSide => this == DraggingMode.cornerSide;

  bool get isNearestSide => this == DraggingMode.nearestSide;
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
