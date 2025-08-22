import 'package:flutter/material.dart';
import 'package:flutter_flow_chart/src/elements/flow_element.dart';
import 'package:flutter_flow_chart/src/objects/element_text_widget.dart';

/// A kind of element
class RectangleWidget extends StatelessWidget {
  ///
  const RectangleWidget({
    required this.element,
    required this.pressDelete,
    super.key,
  });

  ///
  final FlowElement element;
  final Function() pressDelete;

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
              color: element.isAssigned != null && element.isAssigned == true && element.isMyStep == true
                  ? Colors.black.withOpacity(0.2)
                  : element.backgroundColor,
              border: Border.all(
                color: element.borderColor,
                width: element.borderThickness,
              ),
            ),
          ),
          element.isAssigned != null && element.isAssigned == true
              ? element.stepStatus != null
                  ? element.stepStatus!.isEmpty
                      ? Container()
                      : Positioned(
                          right: -8.0,
                          top: -8.0,
                          child: GestureDetector(
                            onTap: () {
                              //pressDelete();
                            },
                            child: element.stepStatus!.toLowerCase() == 'in progress'
                                ? Container(
                                    width: 20.0,
                                    height: 20.0,
                                    decoration: BoxDecoration(shape: BoxShape.circle, color: element.borderColor),
                                    child: Center(
                                        child: Icon(
                                      Icons.hourglass_top,
                                      size: 15.0,
                                      color: Colors.black,
                                    )))
                                : Icon(
                                    element.stepStatus!.toLowerCase() == 'completed' ? Icons.check_circle : Icons.watch_later_rounded,
                                    color: element.stepStatus!.toLowerCase() == 'completed' ? Colors.black : element.borderColor,
                                    size: 20.0,
                                  ),
                          ),
                        )
                  : Container()
              : Positioned(
                  right: -8.0,
                  top: -8.0,
                  child: GestureDetector(
                    onTap: () {
                      pressDelete();
                    },
                    behavior: HitTestBehavior.translucent, // ensures empty space is clickable
                    child: Container(
                      padding: const EdgeInsets.all(12), // increase tappable area
                      color: Colors.transparent, // keep background invisible
                      child: Icon(
                        Icons.remove_circle,
                        color: Colors.black,
                        size: 25.0,
                      ),
                    ),
                  ),
                ),
          ElementTextWidget(element: element),
        ],
      ),
    );
  }
}
