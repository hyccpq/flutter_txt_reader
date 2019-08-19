import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_txt_reader/model/index_db_base.dart';
import 'package:flutter_txt_reader/model/line_model.dart';

import 'line_painter.dart';

const double maxTapDistance = 20.0; // 点击范围

class PainterLineArea extends StatefulWidget {
  final MediaQueryData mediaQueryData;
  final bool isNoteMode;
  final List<LineBase> defLine;
  final void Function(List<LineBase>) commitCurLines;
  final int page;

  double readHeight;
  double readWidth;

  PainterLineArea(
      {Key key,
      this.mediaQueryData,
      this.isNoteMode,
      this.defLine = const <LineBase>[],
      @required this.page,
      @required this.commitCurLines})
      : super(key: key) {
    double topPadding = mediaQueryData.padding.top;
    double bottomPadding = mediaQueryData.padding.bottom;
    readHeight = mediaQueryData.size.height - topPadding - bottomPadding;
    readWidth = mediaQueryData.size.width;
  }

  @override
  PainterLineAreaState createState() => PainterLineAreaState();
}

class PainterLineAreaState extends State<PainterLineArea> {
  static const List<LineColor> lineColorType = [
    const LineColor(desc: "墨色", color: 0xFF272C35),
    const LineColor(desc: "红", color: 0xFFF82301),
    const LineColor(desc: "蓝", color: 0xFF0089D7),
    const LineColor(desc: "绿", color: 0xFF00B12A)
  ];
  static const List<LineWidth> lineWidthType = [
    const LineWidth(desc: "细", width: 3.0),
    const LineWidth(desc: "正常", width: 6.0),
    const LineWidth(desc: "粗", width: 9.0)
  ];

  static const TextStyle textStyle =
      TextStyle(fontSize: 12.0, color: Colors.black, height: 1.0);

  List<LineBase> lines = <LineBase>[];
  List<Offset> nowPoints = <Offset>[];
  LineColor nowColor = lineColorType[0];
  LineWidth nowWidth = lineWidthType[0];

  Offset showRemovePosition;
  int pickRmLineIndex;

  @override
  void didUpdateWidget(PainterLineArea oldWidget) {
    if (widget.defLine != oldWidget.defLine) {
      lines = widget.defLine ?? [];
      print('${lines.length} <<<<<<< 好的！');
    }
    super.didUpdateWidget(oldWidget);
  }

  void moveEndAddLine() {
    if (nowPoints.length != 0) {
      createLineAndClearPoint();
      widget.commitCurLines(lines);
    }
  }

  void newGestureDetector(DragStartDetails detail) {
    if (nowPoints.length != 0) createLineAndClearPoint();
    Offset p = Offset(detail.globalPosition.dx,
        detail.globalPosition.dy - widget.mediaQueryData.padding.top);
    addNowPoints(p);
  }

  void moveGestureDetector(DragUpdateDetails detail) {
    Offset p = Offset(detail.globalPosition.dx,
        detail.globalPosition.dy - widget.mediaQueryData.padding.top);
    addNowPoints(p);
  }

  void addNowPoints(Offset p) {
    if (mounted) {
      setState(() {
        nowPoints.add(p);
      });
    }
  }

  void createLineAndClearPoint() {
    List<Offset> moves = List<Offset>.from(nowPoints);
    LineBase l = LineBase(
        start: moves[0],
        end: moves[moves.length - 1],
        page: widget.page,
        moves: moves,
        pathColor: nowColor.color,
        paintWidth: nowWidth.width as double,
        mStandardH: widget.readHeight,
        mStandardW: widget.readWidth);
    lines.add(l);
    nowPoints.clear();
  }

  void _changeLineColor(LineColor lineColor) {
    if (nowPoints.length != 0) createLineAndClearPoint();
    if (mounted) {
      setState(() {
        nowPoints.clear();
        nowColor = lineColor;
      });
    }
  }

  void _changeLineWidth(LineWidth lineWidth) {
    if (nowPoints.length != 0) createLineAndClearPoint();
    if (mounted) {
      setState(() {
        nowPoints.clear();
        nowWidth = lineWidth;
      });
    }
  }

  bool clickLine(TapUpDetails details) {
    Offset clickPoint = Offset(details.globalPosition.dx,
        details.globalPosition.dy - widget.mediaQueryData.padding.top);
    double tapDistance, x, y;
    for (int i = 0; i < lines.length; i++) {
      LineBase l = lines[i];
      for (Offset p in l.moves) {
        Offset tp = PaintCanvas.computedCurReaderOffset(
            p, l, widget.readWidth, widget.readHeight);
        x = (clickPoint.dx - tp.dx).abs();
        y = (clickPoint.dy - tp.dy).abs();
        tapDistance = math.sqrt(x * x + y * y);
        if (tapDistance < maxTapDistance) {
          setState(() {
            pickRmLineIndex = i;
            showRemovePosition = Offset(clickPoint.dx, clickPoint.dy - 40.0);
          });
          return true;
        }
      }
    }
    setState(() {
      showRemovePosition = null;
    });
    return false;
  }

  void _removeLine() {
    print(pickRmLineIndex);
    setState(() {
//      lines.removeAt(pickRmLineIndex);
      lines = lines.where((item) => item != lines[pickRmLineIndex]).toList();
//      lines = lines
      showRemovePosition = null;
      widget.commitCurLines(lines);
    });
  }

  @override
  Widget build(BuildContext context) {
    MediaQueryData mediaQueryData = widget.mediaQueryData;
    double topPadding = mediaQueryData.padding.top;
    double bottomPadding = mediaQueryData.padding.bottom;
    double height = mediaQueryData.size.height - topPadding - bottomPadding;
    double width = mediaQueryData.size.width;
    return Stack(
      children: <Widget>[
        Container(
          padding: EdgeInsets.only(top: topPadding, bottom: bottomPadding),
          child: RepaintBoundary(
            child: CustomPaint(
              size: Size(width, height),
              painter: PaintCanvas(
                lines: lines,
                nowPoints: nowPoints,
                nowColor: Color(nowColor.color),
                nowWidth: nowWidth.width,
                readHeight: height,
                readWidth: width,
              ),
            ),
          ),
        ),
        widget.isNoteMode
            ? Positioned(
                top: 0.0,
                left: 0.0,
                right: 0.0,
                child: Container(
                  padding: EdgeInsets.only(top: topPadding - 10.0),
                  height: 35.0 + topPadding,
                  color: Colors.white,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Expanded(
                        child: ListTile(
                          title: const Text('笔迹宽度', style: textStyle),
                          trailing: DropdownButton<LineWidth>(
                              isDense: true,
                              style: textStyle,
                              value: nowWidth,
                              items: lineWidthType
                                  .map((LineWidth val) =>
                                      DropdownMenuItem<LineWidth>(
                                        child: Text(val.desc),
                                        value: val,
                                      ))
                                  .toList(),
                              onChanged: _changeLineWidth),
                        ),
                      ),
                      Expanded(
                        child: ListTile(
                          title: const Text('笔迹颜色', style: textStyle),
                          trailing: DropdownButton<LineColor>(
                              style: textStyle,
                              value: nowColor,
                              isDense: true,
                              items: lineColorType
                                  .map((LineColor val) =>
                                      DropdownMenuItem<LineColor>(
                                        child: Row(
                                          children: <Widget>[
                                            ClipOval(
                                              child: Container(
                                                width: 15.0,
                                                height: 15.0,
                                                color: Color(val.color),
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 8.0),
                                              child: Text(val.desc),
                                            ),
                                          ],
                                        ),
                                        value: val,
                                      ))
                                  .toList(),
                              onChanged: _changeLineColor),
                        ),
                      )
                    ],
                  ),
                ))
            : Container(),
        showRemovePosition != null
            ? Positioned(
                top: showRemovePosition.dy,
                left: showRemovePosition.dx,
                child: Material(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(8.0)),
                  child: InkWell(
                    onTap: _removeLine,
                    child: Container(
                      padding: EdgeInsets.only(
                          top: 10.0, bottom: 10.0, left: 20.0, right: 20.0),
                      child: const Text('删除'),
                    ),
                  ),
                ),
              )
            : Container()
      ],
    );
  }
}
