import 'package:flutter/material.dart';
import 'package:flutter_txt_reader/model/index_db_base.dart';
// import 'package:flutter_reader/widget/model/index_db_base.dart';

class PaintCanvas extends CustomPainter {
  final List<LineBase> lines;
  final List<Offset> nowPoints;
  final Color nowColor;
  final double nowWidth;
  final double readWidth;
  final double readHeight;

  PaintCanvas(
      {this.lines,
      this.nowPoints,
      this.nowColor,
      this.nowWidth,
      @required this.readHeight,
      @required this.readWidth});

  static Offset computedCurReaderOffset(
      Offset p, LineBase l, double readWidth, double readHeight) {
    if (l.mStandardW != readWidth || l.mStandardH != readHeight) {
      double dx = (readWidth / l.mStandardW) * p.dx;
      double dy = (readHeight / l.mStandardH) * p.dy;
      return Offset(dx, dy);
    } else
      return p;
  }

  /// 对安卓的颜色进行处理
  int fixColors(int color) {
    if (color < 0) {
//      int fixedColor = ~color.abs() | 0xFF000000;
      int red = color & 0xff0000;
      int green = color & 0x00ff00;
      int blue = color & 0x0000ff;
      int fixedColor = 0xff000000 | red | green | blue;
      return fixedColor;
//      return fixedColor;
    } else {
      if (color.bitLength != 32) color |= 0xFF000000;
      return color;
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    print('绘制');
    Paint p = new Paint()..strokeCap = StrokeCap.round;
    canvas.save();
    for (int i = 0; i < lines.length; i++) {
      LineBase l = lines[i];
      for (int j = 1; j < l.moves.length; j++) {
        Offset p1 =
            computedCurReaderOffset(l.moves[j - 1], l, readWidth, readHeight);
        Offset p2 =
            computedCurReaderOffset(l.moves[j], l, readWidth, readHeight);
        p.color = Color(fixColors(l.pathColor));
        p.strokeWidth = l.paintWidth;
        canvas.drawLine(p1, p2, p);
      }
    }
    for (int i = 1; i < nowPoints.length; i++) {
      Offset p1 = nowPoints[i - 1];
      Offset p2 = nowPoints[i];
      p.color = nowColor;
      p.strokeWidth = nowWidth;
      canvas.drawLine(p1, p2, p);
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(PaintCanvas oldDelegate) {
    return this.lines.length != oldDelegate.lines.length ||
        nowPoints.length != 0;
  }
}
