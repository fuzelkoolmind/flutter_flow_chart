import 'dart:async'; // Add this import for Timer
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_flow_chart/flutter_flow_chart.dart';
import 'package:flutter_flow_chart/src/ui/segment_handler.dart';

/// Arrow style enumeration
enum ArrowStyle {
  /// A curved arrow which points nicely to each handlers
  curve,

  /// A segmented line where pivot points can be added and curvature between
  /// them can be adjusted with a tension.
  segmented,

  /// A rectangular shaped line.
  rectangular,
}

/// Arrow parameters used by [DrawArrow] widget
class ArrowParams extends ChangeNotifier {
  ///
  ArrowParams({
    this.thickness = 1.7,
    this.headRadius = 6,
    double tailLength = 25.0,
    this.color = Colors.black,
    this.style,
    this.tension = 1.0,
    this.startArrowPosition = Alignment.centerRight,
    this.endArrowPosition = Alignment.centerLeft,
    this.clickableWidth = 20.0, // Added clickable width parameter
  }) : _tailLength = tailLength;

  ///
  factory ArrowParams.fromMap(Map<String, dynamic> map) {
    return ArrowParams(
      thickness: map['thickness'] as double,
      headRadius: map['headRadius'] as double? ?? 6.0,
      tailLength: map['tailLength'] as double? ?? 35.0,
      color: Color(map['color'] as int),
      style: ArrowStyle.values[map['style'] as int? ?? 0],
      tension: map['tension'] as double? ?? 1,
      startArrowPosition: Alignment(
        map['startArrowPositionX'] as double,
        map['startArrowPositionY'] as double,
      ),
      endArrowPosition: Alignment(
        map['endArrowPositionX'] as double,
        map['endArrowPositionY'] as double,
      ),
      clickableWidth: map['clickableWidth'] as double? ?? 20.0,
    );
  }

  ///
  factory ArrowParams.fromJson(String source) => ArrowParams.fromMap(json.decode(source) as Map<String, dynamic>);

  /// Arrow thickness.
  double thickness;

  /// The radius of arrow tip.
  double headRadius;

  /// Arrow color.
  final Color color;

  /// The start position alignment.
  final Alignment startArrowPosition;

  /// The end position alignment.
  final Alignment endArrowPosition;

  /// The tail length of the arrow.
  double _tailLength;

  /// The style of the arrow.
  ArrowStyle? style;

  /// The curve tension for pivot points when using [ArrowStyle.segmented].
  /// 0 means no curve on segments.
  double tension;

  /// The clickable width of the line (invisible hit area)
  double clickableWidth;

  ///
  ArrowParams copyWith({
    double? thickness,
    Color? color,
    ArrowStyle? style,
    double? tension,
    Alignment? startArrowPosition,
    Alignment? endArrowPosition,
    double? clickableWidth,
  }) {
    return ArrowParams(
      thickness: thickness ?? this.thickness,
      color: color ?? this.color,
      style: style ?? this.style,
      tension: tension ?? this.tension,
      startArrowPosition: startArrowPosition ?? this.startArrowPosition,
      endArrowPosition: endArrowPosition ?? this.endArrowPosition,
      clickableWidth: clickableWidth ?? this.clickableWidth,
    );
  }

  ///
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'thickness': thickness,
      'headRadius': headRadius,
      'tailLength': _tailLength,
      'color': color.value,
      'style': style?.index,
      'tension': tension,
      'startArrowPositionX': startArrowPosition.x,
      'startArrowPositionY': startArrowPosition.y,
      'endArrowPositionX': endArrowPosition.x,
      'endArrowPositionY': endArrowPosition.y,
      'clickableWidth': clickableWidth,
    };
  }

  ///
  String toJson() => json.encode(toMap());

  ///
  void setScale(double currentZoom, double factor) {
    thickness = thickness / currentZoom * factor;
    headRadius = headRadius / currentZoom * factor;
    _tailLength = _tailLength / currentZoom * factor;
    clickableWidth = clickableWidth / currentZoom * factor;
    notifyListeners();
  }

  ///
  double get tailLength => _tailLength;
}

/// Notifier to update arrows position, starting/ending points and params
class DrawingArrow extends ChangeNotifier {
  DrawingArrow._();

  /// Singleton instance of this.
  static final instance = DrawingArrow._();

  /// Arrow parameters.
  ArrowParams params = ArrowParams();

  /// Sets the parameters.
  void setParams(ArrowParams params) {
    this.params = params;
    notifyListeners();
  }

  /// Starting arrow offset.
  Offset from = Offset.zero;

  ///
  void setFrom(Offset from) {
    this.from = from;
    notifyListeners();
  }

  /// Ending arrow offset.
  Offset to = Offset.zero;

  ///
  void setTo(Offset to) {
    this.to = to;
    notifyListeners();
  }

  ///
  bool isZero() {
    return from == Offset.zero && to == Offset.zero;
  }

  ///
  void reset() {
    params = ArrowParams();
    from = Offset.zero;
    to = Offset.zero;
    notifyListeners();
  }
}

/// Draw arrow from [srcElement] to [destElement]
/// using [arrowParams] parameters
class DrawArrow extends StatefulWidget {
  ///
  DrawArrow({
    required this.srcElement,
    required this.destElement,
    required List<Pivot> pivots,
    required this.connectionLinePressed,
    super.key,
    ArrowParams? arrowParams,
    this.clickedColor = Colors.red, // Color when clicked
    this.clickDuration = const Duration(seconds: 3), // Duration to show clicked color
  })  : arrowParams = arrowParams ?? ArrowParams(),
        pivots = PivotsNotifier(pivots);

  ///
  final ArrowParams arrowParams;

  ///
  final FlowElement srcElement;

  ///
  final FlowElement destElement;

  ///
  final PivotsNotifier pivots;

  ///
  final Function(FlowElement, FlowElement, Offset) connectionLinePressed;

  ///
  final Color clickedColor;

  ///
  final Duration clickDuration;

  @override
  State<DrawArrow> createState() => _DrawArrowState();
}

class _DrawArrowState extends State<DrawArrow> {
  bool _isClicked = false;
  Timer? _colorTimer;

  @override
  void initState() {
    super.initState();
    widget.srcElement.addListener(_elementChanged);
    widget.destElement.addListener(_elementChanged);
    widget.pivots.addListener(_elementChanged);
  }

  @override
  void dispose() {
    _colorTimer?.cancel();
    widget.srcElement.removeListener(_elementChanged);
    widget.destElement.removeListener(_elementChanged);
    widget.pivots.removeListener(_elementChanged);
    super.dispose();
  }

  void _elementChanged() {
    if (mounted) setState(() {});
  }

  void _onLineClicked(Offset position) {
    // Cancel any existing timer
    _colorTimer?.cancel();

    // Set clicked state and change color
    setState(() {
      _isClicked = true;
    });

    // Call the original callback
    print('Click on Line - Source: ${widget.srcElement.id}, Destination: ${widget.destElement.id}');
    widget.connectionLinePressed(widget.srcElement, widget.destElement, position);

    // Start timer to revert color after specified duration
    _colorTimer = Timer(widget.clickDuration, () {
      if (mounted) {
        setState(() {
          _isClicked = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    var from = Offset.zero;
    var to = Offset.zero;
    var direction = 'Empty';

    from = Offset(
      widget.srcElement.position.dx +
          widget.srcElement.handlerSize / 2.0 +
          (widget.srcElement.size.width * ((widget.arrowParams.startArrowPosition.x + 1) / 2)),
      widget.srcElement.position.dy +
          widget.srcElement.handlerSize / 2.0 +
          (widget.srcElement.size.height * ((widget.arrowParams.startArrowPosition.y + 1) / 2)),
    );
    to = Offset(
      widget.destElement.position.dx +
          widget.destElement.handlerSize / 2.0 +
          (widget.destElement.size.width * ((widget.arrowParams.endArrowPosition.x + 1) / 2)),
      widget.destElement.position.dy +
          widget.destElement.handlerSize / 2.0 +
          (widget.destElement.size.height * ((widget.arrowParams.endArrowPosition.y + 1) / 2)),
    );

    direction = getOffsetDirection(to, widget.destElement.position, widget.destElement.size);

    // Create modified arrow params with clicked color if needed
    final currentArrowParams = _isClicked ? widget.arrowParams.copyWith(color: widget.clickedColor) : widget.arrowParams;

    return RepaintBoundary(
      child: CustomPaint(
        painter: ArrowPainter(
          params: currentArrowParams,
          from: from,
          to: to,
          pivots: widget.pivots.value,
          direction: direction,
          onLinePressed: _onLineClicked, // Pass the callback to the painter
        ),
        size: Size.infinite,
        child: Container(),
      ),
    );
  }

  String getOffsetDirection(Offset to, Offset boxPosition, Size boxSize) {
    final double centerX = boxPosition.dx + boxSize.width / 2;
    final double centerY = boxPosition.dy + boxSize.height / 2;

    final double deltaX = to.dx - centerX;
    final double deltaY = to.dy - centerY;

    if (deltaX.abs() > deltaY.abs()) {
      return deltaX > 0 ? "Right" : "Left"; // More horizontal movement
    } else {
      return deltaY > 0 ? "Bottom" : "Top"; // More vertical movement
    }
  }
}

/// Paint the arrow connection taking in count the
/// [ArrowParams.startArrowPosition] and
/// [ArrowParams.endArrowPosition] alignment.
class ArrowPainter extends CustomPainter {
  ///
  ArrowPainter({
    required this.params,
    required this.from,
    required this.to,
    required this.direction,
    List<Pivot>? pivots,
    this.onLinePressed,
  }) : pivots = pivots ?? [];

  ///
  final ArrowParams params;

  ///
  final Offset from;

  ///
  final Offset to;

  ///
  final Path path = Path();

  ///
  final List<List<Offset>> lines = [];

  ///
  final List<Pivot> pivots;

  ///
  final Function(Offset)? onLinePressed;

  var direction;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..strokeWidth = params.thickness
      ..color = params.color
      ..style = PaintingStyle.stroke;

    if (params.style == ArrowStyle.curve) {
      drawCurve(canvas, paint);
    } else if (params.style == ArrowStyle.segmented) {
      drawLine();
    } else if (params.style == ArrowStyle.rectangular) {
      drawRectangularLine(canvas, paint);
    }

    // Draw the arrowhead pointing in the correct direction
    if (direction == 'Left') {
      drawRightArrowHead(canvas, paint);
    } else if (direction == 'Right') {
      drawLeftArrowHead(canvas, paint);
    } else if (direction == 'Bottom') {
      drawTopArrowHead(canvas, paint);
    } else if (direction == 'Top') {
      drawBottomArrowHead(canvas, paint);
    } else {
      drawCircleAtEnd(canvas, paint);
    }

    paint.style = PaintingStyle.stroke;
    canvas.drawPath(path, paint);
  }

  /// Override hitTest to only respond to clicks on the actual line
  @override
  bool hitTest(Offset position) {
    return isPointOnLine(position);
  }

  /// Check if a point is on the line (used for explicit click detection)
  bool isPointOnLine(Offset position) {
    // Get the line path points
    final points = <Offset>[];
    if (params.style == ArrowStyle.curve) {
      // For curves, sample points along the path
      points.addAll(_sampleCurvePath());
    } else if (params.style == ArrowStyle.segmented) {
      // For segmented lines, use pivot points
      points.add(from);
      for (final pivot in pivots) {
        points.add(pivot.pivot);
      }
      points.add(to);
    } else {
      // For rectangular lines, use the corner points
      points.addAll(_getRectangularPoints());
    }

    // Create a thick stroke around the line for hit testing
    for (int i = 0; i < points.length - 1; i++) {
      final start = points[i];
      final end = points[i + 1];

      // Calculate the distance from point to line segment
      final distance = _distanceToLineSegment(position, start, end);

      if (distance <= params.clickableWidth / 2) {
        // If we have a callback, call it
        if (onLinePressed != null) {
          onLinePressed!(position);
        }
        return true;
      }
    }

    return false;
  }

  /// Calculate the minimum distance from a point to a line segment
  double _distanceToLineSegment(Offset point, Offset lineStart, Offset lineEnd) {
    final dx = lineEnd.dx - lineStart.dx;
    final dy = lineEnd.dy - lineStart.dy;

    if (dx == 0 && dy == 0) {
      // Line segment is actually a point
      return (point - lineStart).distance;
    }

    final t = ((point.dx - lineStart.dx) * dx + (point.dy - lineStart.dy) * dy) / (dx * dx + dy * dy);

    if (t < 0) {
      // Closest point is lineStart
      return (point - lineStart).distance;
    } else if (t > 1) {
      // Closest point is lineEnd
      return (point - lineEnd).distance;
    } else {
      // Closest point is on the line segment
      final closestPoint = Offset(lineStart.dx + t * dx, lineStart.dy + t * dy);
      return (point - closestPoint).distance;
    }
  }

  /// Draw a bottom-facing arrowhead
  void drawBottomArrowHead(Canvas canvas, Paint paint) {
    final arrowHeadSize = params.headRadius * 1.5;
    final arrowTip = to;
    final arrowLeft = Offset(to.dx - arrowHeadSize, to.dy - arrowHeadSize);
    final arrowRight = Offset(to.dx + arrowHeadSize, to.dy - arrowHeadSize);

    final arrowHeadPath = Path()
      ..moveTo(arrowTip.dx, arrowTip.dy)
      ..lineTo(arrowLeft.dx, arrowLeft.dy)
      ..lineTo(arrowRight.dx, arrowRight.dy)
      ..close();

    paint.style = PaintingStyle.fill;
    canvas.drawPath(arrowHeadPath, paint);
  }

  void drawTopArrowHead(Canvas canvas, Paint paint) {
    final arrowHeadSize = params.headRadius * 1.5;
    final arrowTip = to;
    final arrowLeft = Offset(to.dx - arrowHeadSize, to.dy + arrowHeadSize);
    final arrowRight = Offset(to.dx + arrowHeadSize, to.dy + arrowHeadSize);

    final arrowHeadPath = Path()
      ..moveTo(arrowTip.dx, arrowTip.dy)
      ..lineTo(arrowLeft.dx, arrowLeft.dy)
      ..lineTo(arrowRight.dx, arrowRight.dy)
      ..close();

    paint.style = PaintingStyle.fill;
    canvas.drawPath(arrowHeadPath, paint);
  }

  void drawLeftArrowHead(Canvas canvas, Paint paint) {
    final arrowHeadSize = params.headRadius * 1.5;
    final arrowTip = to;
    final arrowTop = Offset(to.dx + arrowHeadSize, to.dy - arrowHeadSize);
    final arrowBottom = Offset(to.dx + arrowHeadSize, to.dy + arrowHeadSize);

    final arrowHeadPath = Path()
      ..moveTo(arrowTip.dx, arrowTip.dy)
      ..lineTo(arrowTop.dx, arrowTop.dy)
      ..lineTo(arrowBottom.dx, arrowBottom.dy)
      ..close();

    paint.style = PaintingStyle.fill;
    canvas.drawPath(arrowHeadPath, paint);
  }

  void drawRightArrowHead(Canvas canvas, Paint paint) {
    final arrowHeadSize = params.headRadius * 1.5;
    final arrowTip = to;
    final arrowTop = Offset(to.dx - arrowHeadSize, to.dy - arrowHeadSize);
    final arrowBottom = Offset(to.dx - arrowHeadSize, to.dy + arrowHeadSize);

    final arrowHeadPath = Path()
      ..moveTo(arrowTip.dx, arrowTip.dy)
      ..lineTo(arrowTop.dx, arrowTop.dy)
      ..lineTo(arrowBottom.dx, arrowBottom.dy)
      ..close();

    paint.style = PaintingStyle.fill;
    canvas.drawPath(arrowHeadPath, paint);
  }

  void drawCircleAtEnd(Canvas canvas, Paint paint) {
    final double circleRadius = params.headRadius * 1.5;
    canvas.drawCircle(to, circleRadius, paint);
  }

  /// Draw a segmented line with a tension between points.
  void drawLine() {
    final points = [from];
    for (final pivot in pivots) {
      points.add(pivot.pivot);
    }
    points.add(to);

    path.moveTo(points.first.dx, points.first.dy);

    for (var i = 0; i < points.length - 1; i++) {
      final p0 = (i > 0) ? points[i - 1] : points[0];
      final p1 = points[i];
      final p2 = points[i + 1];
      final p3 = (i != points.length - 2) ? points[i + 2] : p2;

      final cp1x = p1.dx + (p2.dx - p0.dx) / 6 * params.tension;
      final cp1y = p1.dy + (p2.dy - p0.dy) / 6 * params.tension;

      final cp2x = p2.dx - (p3.dx - p1.dx) / 6 * params.tension;
      final cp2y = p2.dy - (p3.dy - p1.dy) / 6 * params.tension;

      path.cubicTo(cp1x, cp1y, cp2x, cp2y, p2.dx, p2.dy);
    }
  }

  /// Draw a rectangular line
  void drawRectangularLine(Canvas canvas, Paint paint) {
    var pivot1 = Offset(from.dx, from.dy);
    if (params.startArrowPosition.y == 1) {
      pivot1 = Offset(from.dx, from.dy + params.tailLength);
    } else if (params.startArrowPosition.y == -1) {
      pivot1 = Offset(from.dx, from.dy - params.tailLength);
    }

    final pivot2 = Offset(to.dx, pivot1.dy);

    path
      ..moveTo(from.dx, from.dy)
      ..lineTo(pivot1.dx, pivot1.dy)
      ..lineTo(pivot2.dx, pivot2.dy)
      ..lineTo(to.dx, to.dy);

    lines.addAll([
      [from, pivot2],
      [pivot2, to],
    ]);
  }

  /// Draws a curve starting/ending the handler linearly from the center
  /// of the element.
  void drawCurve(Canvas canvas, Paint paint) {
    var distance = 0.0;
    var dx = 0.0;
    var dy = 0.0;

    final p0 = Offset(from.dx, from.dy);
    final p4 = Offset(to.dx, to.dy);
    distance = (p4 - p0).distance / 3;

    if (params.startArrowPosition.x > 0) {
      dx = distance;
    } else if (params.startArrowPosition.x < 0) {
      dx = -distance;
    }
    if (params.startArrowPosition.y > 0) {
      dy = distance;
    } else if (params.startArrowPosition.y < 0) {
      dy = -distance;
    }
    final p1 = Offset(from.dx + dx, from.dy + dy);
    dx = 0;
    dy = 0;

    if (params.endArrowPosition.x > 0) {
      dx = distance;
    } else if (params.endArrowPosition.x < 0) {
      dx = -distance;
    }
    if (params.endArrowPosition.y > 0) {
      dy = distance;
    } else if (params.endArrowPosition.y < 0) {
      dy = -distance;
    }
    final p3 = params.endArrowPosition == Alignment.center ? Offset(to.dx, to.dy) : Offset(to.dx + dx, to.dy + dy);
    final p2 = Offset(
      p1.dx + (p3.dx - p1.dx) / 2,
      p1.dy + (p3.dy - p1.dy) / 2,
    );

    path
      ..moveTo(p0.dx, p0.dy)
      ..conicTo(p1.dx, p1.dy, p2.dx, p2.dy, 1)
      ..conicTo(p3.dx, p3.dy, p4.dx, p4.dy, 1);
  }

  @override
  bool shouldRepaint(ArrowPainter oldDelegate) {
    return true;
  }

  List<Offset> _sampleCurvePath() {
    final points = <Offset>[];
    const sampleCount = 20;

    for (int i = 0; i <= sampleCount; i++) {
      final t = i / sampleCount;
      points.add(_getCurvePoint(t));
    }

    return points;
  }

  Offset _getCurvePoint(double t) {
    // Recreate the curve calculation from drawCurve method
    var distance = 0.0;
    var dx = 0.0;
    var dy = 0.0;

    final p0 = Offset(from.dx, from.dy);
    final p4 = Offset(to.dx, to.dy);
    distance = (p4 - p0).distance / 3;

    if (params.startArrowPosition.x > 0) {
      dx = distance;
    } else if (params.startArrowPosition.x < 0) {
      dx = -distance;
    }
    if (params.startArrowPosition.y > 0) {
      dy = distance;
    } else if (params.startArrowPosition.y < 0) {
      dy = -distance;
    }
    final p1 = Offset(from.dx + dx, from.dy + dy);
    dx = 0;
    dy = 0;

    if (params.endArrowPosition.x > 0) {
      dx = distance;
    } else if (params.endArrowPosition.x < 0) {
      dx = -distance;
    }
    if (params.endArrowPosition.y > 0) {
      dy = distance;
    } else if (params.endArrowPosition.y < 0) {
      dy = -distance;
    }
    final p3 = params.endArrowPosition == Alignment.center ? Offset(to.dx, to.dy) : Offset(to.dx + dx, to.dy + dy);
    final p2 = Offset(
      p1.dx + (p3.dx - p1.dx) / 2,
      p1.dy + (p3.dy - p1.dy) / 2,
    );

    // Quadratic Bézier curve calculation - Fixed to use 4 control points
    final mt = 1 - t;
    final mt2 = mt * mt;
    final t2 = t * t;

    // For the conic curves, we need to handle them as two separate quadratic curves
    if (t <= 0.5) {
      // First conic curve from p0 to p2
      final localT = t * 2;
      final localMt = 1 - localT;
      final x = localMt * localMt * p0.dx + 2 * localMt * localT * p1.dx + localT * localT * p2.dx;
      final y = localMt * localMt * p0.dy + 2 * localMt * localT * p1.dy + localT * localT * p2.dy;
      return Offset(x, y);
    } else {
      // Second conic curve from p2 to p4
      final localT = (t - 0.5) * 2;
      final localMt = 1 - localT;
      final x = localMt * localMt * p2.dx + 2 * localMt * localT * p3.dx + localT * localT * p4.dx;
      final y = localMt * localMt * p2.dy + 2 * localMt * localT * p3.dy + localT * localT * p4.dy;
      return Offset(x, y);
    }
  }

  List<Offset> _getRectangularPoints() {
    final points = <Offset>[];

    var pivot1 = Offset(from.dx, from.dy);
    if (params.startArrowPosition.y == 1) {
      pivot1 = Offset(from.dx, from.dy + params.tailLength);
    } else if (params.startArrowPosition.y == -1) {
      pivot1 = Offset(from.dx, from.dy - params.tailLength);
    }

    final pivot2 = Offset(to.dx, pivot1.dy);

    points.addAll([from, pivot1, pivot2, to]);
    return points;
  }
}

/// Notifier for pivot points.
class PivotsNotifier extends ValueNotifier<List<Pivot>> {
  ///
  PivotsNotifier(super.value) {
    for (final pivot in value) {
      pivot.addListener(notifyListeners);
    }
  }

  /// Add a pivot point.
  void add(Pivot pivot) {
    value.add(pivot);
    pivot.addListener(notifyListeners);
    notifyListeners();
  }

  /// Remove a pivot point.
  void remove(Pivot pivot) {
    value.remove(pivot);
    pivot.removeListener(notifyListeners);
    notifyListeners();
  }

  /// Insert a pivot point.
  void insert(int index, Pivot pivot) {
    value.insert(index, pivot);
    pivot.addListener(notifyListeners);
    notifyListeners();
  }

  /// Remove a pivot point by its index.
  void removeAt(int index) {
    value.removeAt(index).removeListener(notifyListeners);
    notifyListeners();
  }
}
