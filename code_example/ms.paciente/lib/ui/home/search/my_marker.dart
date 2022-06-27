import 'package:flutter/material.dart';

class MyPainter extends CustomPainter {
  final String label;

  MyPainter(this.label);

  @override
  void paint_redcross(Canvas canvas, Size size) {
    Paint paint = Paint();
    paint.color = Colors.white;
    canvas.drawCircle(Offset(size.width * 0.07, size.height * 0.8),
        size.width * 0.075, paint);
    final rectH = Rect.fromLTWH(
        0, size.height * 0.7, size.width * 0.15, size.height * 0.125);
    final rectV = Rect.fromLTWH(
        size.width / 18, size.height / 2, size.width / 28, size.height);
    paint.color = Colors.red;
    canvas.drawRect(rectH, paint);
    canvas.drawRect(rectV, paint);

    final painter = TextPainter(
        text: TextSpan(
            text: this.label,
            style: TextStyle(fontSize: 10, color: Colors.black)),
        maxLines: 2,
        textDirection: TextDirection.ltr);
    painter.layout();
    painter.paint(canvas, Offset(0, 0));
  }

  void paint(Canvas canvas, Size size) {
    Paint paint = Paint();
    paint.color = Colors.lightGreen;
    canvas.drawCircle(Offset(size.width * 0.07, size.height * 0.8),
        size.width * 0.055, paint);

    final painter = TextPainter(
        text: TextSpan(
            text: this.label,
            style: TextStyle(fontSize: 60, color: Colors.black)),
        maxLines: 2,
        textDirection: TextDirection.ltr);
    painter.layout();
    painter.paint(canvas, Offset(0, 0));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
