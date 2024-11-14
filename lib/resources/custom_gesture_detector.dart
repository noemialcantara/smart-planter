import 'package:hortijoy_mobile_app/resources/themed_widgets.dart';
import 'package:flutter/material.dart';

class CustomGestureDetector extends StatelessWidget {
  final VoidCallback tapHandler;
  final String text;
  final Color color;

  CustomGestureDetector(
    this.tapHandler,
    this.text,
    this.color,
  );

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: tapHandler,
      child: CustomWidget.textBuilder(
        text,
        color: color,
      ),
    );
  }
}
