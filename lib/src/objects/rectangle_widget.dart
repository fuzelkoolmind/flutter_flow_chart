import 'package:flutter/material.dart';
import 'package:flutter_flow_chart/src/elements/flow_element.dart';
import 'package:flutter_flow_chart/src/objects/element_text_widget.dart';

/// A kind of element
class RectangleWidget extends StatelessWidget {
  ///
  const RectangleWidget({
    required this.element,
    super.key,
  });

  ///
  final FlowElement element;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: element.size.width,
      height: element.size.height,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: element.size.width,
            height: element.size.height,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: element.backgroundColor,
              border: Border.all(
                color: element.borderColor,
                width: element.borderThickness,
              ),
            ),
          ),
          Positioned(
            right: -8.0,
            top: -8.0,
            child: Icon(
              Icons.remove_circle,
              color: Colors.red,
            ),
          ),
          ElementTextWidget(element: element),
        ],
      ),
    );
  }
}
