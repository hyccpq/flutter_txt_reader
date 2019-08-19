part of text_builder;

class TextBuilder {
  final double omitWidth;
  final double omitHeight;
  final double eWidth;
  final double eHeight;
  final double fontSize;
  final Canvas canvas;

  Paint paintBgc;

  static const double lineHeight = 10 / 9;

  TextBuilder(
      {@required this.eWidth,
      @required this.fontSize,
      @required this.eHeight,
      @required this.omitHeight,
      @required this.omitWidth,
      @required this.canvas,});

  Offset createOffset(int row, int column) =>
      Offset(omitWidth + (column * eWidth), omitHeight + (row * eHeight));

  void renderColorText(String char, Offset offset) {
    if (paintBgc == null)
      paintBgc = Paint()
        ..isAntiAlias = true
        ..style = PaintingStyle.fill //填充
        ..color = Colors.blue[300];
    TextPainter(
        textAlign: TextAlign.center,
        text: TextSpan(
            text: char,
            style: TextStyle(
                color: Color(0xFF000000),
                fontSize: fontSize,
                inherit: false,
                background: paintBgc,
                height: lineHeight)),
        textDirection: TextDirection.ltr)
      ..layout(minWidth: eWidth, maxWidth: eWidth)
      ..paint(canvas, offset);
  }

  void build(String char,
      {int row = 0, int column = 0, int fontIndex, bool breakLine // 是否换行
      }) {
    assert(char.length == 1);
    Offset offset = createOffset(row, column);

    TextPainter(
        textAlign: TextAlign.center,
        text: TextSpan(
            text: char,
            style: TextStyle(
                color: Color(0xFF000000),
                fontSize: fontSize,
                inherit: false,
                height: lineHeight)),
        textDirection: TextDirection.ltr)
      ..layout(minWidth: eWidth, maxWidth: eWidth)
      ..paint(canvas, offset);
  }
}
