library text_builder;

import 'package:flutter/material.dart';

import '../reader_index.dart';

part './text_builder/text_builder.dart';

const int ROW = 19;
const int COLUMN = 16;
const int LARGEST_NUMBER_WORDS = ROW * COLUMN;

typedef TextBuilderCb(String char,
    {int row, // 行
    int column, // 列
    int fontIndex, // 文字所在索引
    bool breakLine // 是否换行
    });

class MyPainter extends CustomPainter {
  final String text;

  static RegExp _reg = RegExp(r'\n|\r', multiLine: true);

  MyPainter({@required this.text})
      : assert(text.length <= LARGEST_NUMBER_WORDS);

  static int rangStr(String text,
      {TextBuilderCb callback,
      int curFontIndex = 0,
      maxLen = LARGEST_NUMBER_WORDS}) {
    var isFin;
    for (int j = 0; j < ROW; j++) {
      for (int i = 0; i < COLUMN && curFontIndex < maxLen; i++) {
        if (text[curFontIndex].indexOf(_reg) != -1) {
          if (callback != null)
            isFin ??= callback(text[curFontIndex],
                row: j, column: i, fontIndex: curFontIndex, breakLine: true);
          curFontIndex++;
          if (isFin != null) return curFontIndex;
          break;
        }
        if (callback != null)
          isFin ??= callback(text[curFontIndex],
              row: j, column: i, fontIndex: curFontIndex, breakLine: false);
        curFontIndex++;
        if (isFin != null) return curFontIndex;
        if (curFontIndex == text.length) break;
      }
    }
    return curFontIndex;
  }

  @override
  bool shouldRepaint(MyPainter oldDelegate) {
    return oldDelegate.text != this.text;
  }

  @override
  void paint(Canvas canvas, Size size) {
    print('文本触发更新！！！！！！！');

    double omitWidth = size.width * 0.05;
    double omitHeight = size.height * 0.05;
    double eWidth = (size.width - omitWidth * 2) / COLUMN;
    double eHeight = (size.height - omitHeight * 2) / ROW;
    double fontSize = eWidth;

    Paint paint = Paint()
      ..isAntiAlias = true
      ..style = PaintingStyle.fill //填充
      ..color = Color(paperColor); //背景为纸黄色
    canvas.drawRect(Offset.zero & size, paint);

    TextBuilder textBuilder = TextBuilder(
        eHeight: eHeight,
        eWidth: eWidth,
        omitHeight: omitHeight,
        omitWidth: omitWidth,
        fontSize: fontSize,
        canvas: canvas);

    rangStr(text, callback: textBuilder.build, maxLen: text.length);
  }
}
