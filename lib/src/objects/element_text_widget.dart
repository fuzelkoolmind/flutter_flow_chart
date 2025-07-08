import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_flow_chart/flutter_flow_chart.dart';

/// Common widget for the element text
class ElementTextWidget extends StatefulWidget {
  ///
  const ElementTextWidget({
    required this.element,
    super.key,
  });

  ///
  final FlowElement element;

  @override
  State<ElementTextWidget> createState() => _ElementTextWidgetState();
}

class _ElementTextWidgetState extends State<ElementTextWidget> {
  final _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller
      ..text = widget.element.text
      ..addListener(() => widget.element.text = _controller.text);
  }

  @override
  Widget build(BuildContext context) {
    final textStyle = TextStyle(
      color: widget.element.textColor,
      fontSize: widget.element.textSize,
      fontWeight: widget.element.textIsBold ? FontWeight.bold : FontWeight.normal,
      fontFamily: widget.element.fontFamily,
    );

    var data1;
    String date = '';
    try {
      if (widget.element.data != null) {
        String moreData = widget.element.data as String;
        data1 = jsonDecode(moreData);
        date = data1['date'] as String;
      }
    } catch (e, stack) {
      print('JSON Parse Error: ${e.toString()}');
      print('JSON Parse Stack: $stack');
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Align(
          child: widget.element.isEditingText
              ? TextFormField(
                  controller: _controller,
                  autofocus: true,
                  onTapOutside: (event) => dismissTextEditor(),
                  onFieldSubmitted: dismissTextEditor,
                  textAlign: TextAlign.center,
                  style: textStyle,
                )
              : Text(
                  widget.element.text,
                  textAlign: TextAlign.center,
                  style: textStyle.copyWith(fontSize: 11.0),
                ),
        ),
        SizedBox(
          height: widget.element.data == null ? 2.0 : 0.0,
        ),
        if (widget.element.data == null)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  '${widget.element.duration.toString() ?? ''} days',
                  textAlign: TextAlign.center,
                  style: textStyle.copyWith(fontSize: 8.0, color: Color(0xff6C7278)),
                ),
              )
            ],
          ),
        SizedBox(
          height: widget.element.data != null ? 2.0 : 0.0,
        ),
        if (widget.element.data != null)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  '$date (${widget.element.duration.toString() ?? ''}d)',
                  textAlign: TextAlign.center,
                  style: textStyle.copyWith(fontSize: 8.0, color: Color(0xff6C7278)),
                ),
              )
            ],
          )
      ],
    );
  }

  void dismissTextEditor([String? text]) {
    if (text != null) widget.element.text = text;
    setState(() => widget.element.isEditingText = false);
  }
}
