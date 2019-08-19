library edit_builder;

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_txt_reader/painter/my_painter.dart';

part './edit_area_builder.dart';

const int deepEditColor = 0x666DA9EE;
const int editColor = 0x662A82E4;

class EditAreaPainter extends CustomPainter {
  final String text;
  final int startEdit;
  final int endEdit;
  final int renderEditStart;
  final int renderEditEnd;
  final void Function({String curString, String lastString}) onSetString;

  EditAreaPainter({
    @required this.text,
    this.renderEditStart,
    this.renderEditEnd,
    this.startEdit,
    this.endEdit,
    this.onSetString,
  });

  @override
  bool shouldRepaint(EditAreaPainter oldDelegate) {
    return oldDelegate.text != this.text ||
        oldDelegate.startEdit != this.startEdit ||
        oldDelegate.endEdit != this.endEdit ||
        oldDelegate.renderEditEnd != this.renderEditEnd ||
        oldDelegate.renderEditStart != this.renderEditStart;
  }

  @override
  void paint(Canvas canvas, Size size) {
    print('$renderEditStart, $renderEditEnd');

    double omitWidth = size.width * 0.05;
    double omitHeight = size.height * 0.05;
    double eWidth = (size.width - omitWidth * 2) / COLUMN;
    double eHeight = (size.height - omitHeight * 2) / ROW;
    double fontSize = eWidth;

    EditAreaBuilder editAreaBuilder = EditAreaBuilder(
        eHeight: eHeight,
        eWidth: eWidth,
        omitHeight: omitHeight,
        omitWidth: omitWidth,
        fontSize: fontSize,
        startEdit: startEdit,
        endEdit: endEdit,
        renderEditEnd: renderEditEnd,
        renderEditStart: renderEditStart,
        canvas: canvas);

    MyPainter.rangStr(text,
        callback: editAreaBuilder.build, maxLen: text.length);
    onSetString(
        curString: editAreaBuilder.curString,
        lastString: editAreaBuilder.lastString);
  }
}
