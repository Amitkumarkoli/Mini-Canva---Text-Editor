import 'package:flutter/material.dart';

class TextElement {
  String text;
  double x;
  double y;
  double fontSize;
  FontStyle fontStyle;
  FontWeight fontWeight;

  TextElement({
    this.text = 'New Text',
    this.x = 100.0,
    this.y = 100.0,
    this.fontSize = 20.0,
    this.fontStyle = FontStyle.normal,
    this.fontWeight = FontWeight.normal,
  });

  // Deep copy constructor
  TextElement.copy(TextElement other)
      : text = other.text,
        x = other.x,
        y = other.y,
        fontSize = other.fontSize,
        fontStyle = other.fontStyle,
        fontWeight = other.fontWeight;

  // For debugging
  @override
  String toString() {
    return 'TextElement(text: $text, x: $x, y: $y, size: $fontSize)';
  }
}