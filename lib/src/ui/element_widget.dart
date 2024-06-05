import 'package:flutter/material.dart';
import 'package:flutter_flow_chart/flutter_flow_chart.dart';
import 'package:flutter_flow_chart/src/objects/diamond_widget.dart';
import 'package:flutter_flow_chart/src/objects/hexagon_widget.dart';
import 'package:flutter_flow_chart/src/objects/oval_widget.dart';
import 'package:flutter_flow_chart/src/objects/parallelogram_widget.dart';
import 'package:flutter_flow_chart/src/objects/rectangle_widget.dart';
import 'package:flutter_flow_chart/src/objects/storage_widget.dart';
import 'package:flutter_flow_chart/src/ui/element_handlers.dart';
import 'package:flutter_flow_chart/src/ui/resize_widget.dart';

/// Widget that use [element] properties to display it on the dashboard scene
class ElementWidget extends StatefulWidget {
  ///
  const ElementWidget({
    required this.dashboard,
    required this.element,
    super.key,
    this.onElementPressed,
    this.onElementSecondaryTapped,
    this.onElementLongPressed,
    this.onElementSecondaryLongTapped,
    this.onHandlerPressed,
    this.onHandlerSecondaryTapped,
    this.onHandlerLongPressed,
    this.onHandlerSecondaryLongTapped,
  });

  ///
  final Dashboard dashboard;

  ///
  final FlowElement element;

  ///
  final void Function(BuildContext context, Offset position)? onElementPressed;

  ///
  final void Function(BuildContext context, Offset position)?
      onElementSecondaryTapped;

  ///
  final void Function(BuildContext context, Offset position)?
      onElementLongPressed;

  ///
  final void Function(BuildContext context, Offset position)?
      onElementSecondaryLongTapped;

  ///
  final void Function(
    BuildContext context,
    Offset position,
    Handler handler,
    FlowElement element,
  )? onHandlerPressed;

  ///
  final void Function(
    BuildContext context,
    Offset position,
    Handler handler,
    FlowElement element,
  )? onHandlerSecondaryTapped;

  ///
  final void Function(
    BuildContext context,
    Offset position,
    Handler handler,
    FlowElement element,
  )? onHandlerLongPressed;

  ///
  final void Function(
    BuildContext context,
    Offset position,
    Handler handler,
    FlowElement element,
  )? onHandlerSecondaryLongTapped;

  @override
  State<ElementWidget> createState() => _ElementWidgetState();
}

class _ElementWidgetState extends State<ElementWidget> {
  // local widget touch position when start dragging
  Offset delta = Offset.zero;

  @override
  void initState() {
    super.initState();
    widget.element.addListener(_elementChanged);
  }

  @override
  void dispose() {
    widget.element.removeListener(_elementChanged);
    super.dispose();
  }

  void _elementChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    Widget element;

    switch (widget.element.kind) {
      case ElementKind.diamond:
        element = DiamondWidget(element: widget.element);
      case ElementKind.storage:
        element = StorageWidget(element: widget.element);
      case ElementKind.oval:
        element = OvalWidget(element: widget.element);
      case ElementKind.parallelogram:
        element = ParallelogramWidget(element: widget.element);
      case ElementKind.hexagon:
        element = HexagonWidget(element: widget.element);
      case ElementKind.rectangle:
        element = RectangleWidget(element: widget.element);
    }

    if (widget.element.isResizing) {
      return Transform.translate(
        offset: widget.element.position,
        child: ResizeWidget(
          element: widget.element,
          dashboard: widget.dashboard,
          child: element,
        ),
      );
    }

    element = Padding(
      padding: EdgeInsets.all(widget.element.handlerSize / 2),
      child: element,
    );

    var tapLocation = Offset.zero;
    var secondaryTapDownPos = Offset.zero;
    return Transform.translate(
      offset: widget.element.position,
      transformHitTests: true,
      child: GestureDetector(
        onTapDown: (details) => tapLocation = details.globalPosition,
        onSecondaryTapDown: (details) =>
            secondaryTapDownPos = details.globalPosition,
        onTap: () {
          widget.onElementPressed?.call(context, tapLocation);
        },
        onSecondaryTap: () {
          widget.onElementSecondaryTapped?.call(context, secondaryTapDownPos);
        },
        onLongPress: () {
          widget.onElementLongPressed?.call(context, tapLocation);
        },
        onSecondaryLongPress: () {
          widget.onElementSecondaryLongTapped
              ?.call(context, secondaryTapDownPos);
        },
        child: Listener(
          onPointerDown: (event) {
            delta = event.localPosition;
          },
          child: Draggable<FlowElement>(
            data: widget.element,
            dragAnchorStrategy: childDragAnchorStrategy,
            childWhenDragging: const SizedBox.shrink(),
            feedback: Material(
              color: Colors.transparent,
              child: element,
            ),
            child: ElementHandlers(
              dashboard: widget.dashboard,
              element: widget.element,
              handlerSize: widget.element.handlerSize,
              onHandlerPressed: widget.onHandlerPressed,
              onHandlerSecondaryTapped: widget.onHandlerSecondaryTapped,
              onHandlerLongPressed: widget.onHandlerLongPressed,
              onHandlerSecondaryLongTapped: widget.onHandlerSecondaryLongTapped,
              child: element,
            ),
            onDragUpdate: (details) {
              widget.element.changePosition(
                details.globalPosition - widget.dashboard.position - delta,
              );
            },
            onDragEnd: (details) {
              widget.element
                  .changePosition(details.offset - widget.dashboard.position);
            },
          ),
        ),
      ),
    );
  }
}
