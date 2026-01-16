import 'package:flutter/material.dart';
import 'package:flutter_flow_chart/flutter_flow_chart.dart';
import 'package:flutter_flow_chart/src/utils/stream_builder.dart';

class DraggableFlowElement extends StatefulWidget {
  final FlowElement element;
  final Widget child;
  final Dashboard dashboard;

  const DraggableFlowElement({
    Key? key,
    required this.element,
    required this.child,
    required this.dashboard,
  }) : super(key: key);

  @override
  State<DraggableFlowElement> createState() => _DraggableFlowElementState();
}

class _DraggableFlowElementState extends State<DraggableFlowElement> {
  late Offset delta;
  double _scale = 1.0;
  Color? _originalBorderColor;

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (event) {
        delta = event.localPosition;
      },
      child: LongPressDraggable<FlowElement>(
        data: widget.element,
        childWhenDragging: const SizedBox.shrink(),
        feedback: Material(
          color: Colors.transparent,
          child: AnimatedScale(
            scale: _scale,
            duration: const Duration(milliseconds: 150),
            child: widget.child,
          ),
        ),
        child: AnimatedScale(
          scale: _scale,
          duration: const Duration(milliseconds: 150),
          child: widget.child,
        ),
        onDragStarted: () {
          // Store original border color
          _originalBorderColor = widget.element.borderColor;
          // Change border color to blue during dragging
          widget.element.setBorderColor(Colors.blue);
          setState(() => _scale = 0.9);
        },
        onDragUpdate: (details) {
          widget.element.changePosition(
            details.globalPosition - widget.dashboard.position - delta,
          );
          if (!StreamBuilderUtils.isDragging.value) {
            StreamBuilderUtils.isDragging.add(true);
          }
        },
        onDragEnd: (details) {
          // Restore original border color
          if (_originalBorderColor != null) {
            widget.element.setBorderColor(_originalBorderColor!);
          }
          setState(() => _scale = 1.0);
          widget.element.changePosition(
            details.offset - widget.dashboard.position,
          );
          StreamBuilderUtils.isDragging.add(false);
        },
        onDraggableCanceled: (velocity, offset) {
          // Restore original border color
          if (_originalBorderColor != null) {
            widget.element.setBorderColor(_originalBorderColor!);
          }
          setState(() => _scale = 1.0);
        },
      ),
    );
  }
}
