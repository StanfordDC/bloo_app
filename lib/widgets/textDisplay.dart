import 'package:flutter/material.dart';
class TextDisplay extends StatelessWidget {
  const TextDisplay(
      this.color,
      this.text,
      this.fontSize,
      {super.key}
  );

  final Color color;
  final String text;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Text(text, style: TextStyle(
        letterSpacing: -0.5,
        color: color,
        fontSize: fontSize,
        fontFamily: 'Poppins'));
  }
}

class TextContainer extends StatelessWidget {
  final Widget widget;

  const TextContainer(
      this.widget,
      {super.key}
      );

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: const EdgeInsets.fromLTRB(12.0, 0.0, 12.0, 3.0),
        child: widget);
  }
}


