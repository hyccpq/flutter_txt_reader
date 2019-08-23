import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_txt_reader/model/edit_mode.dart';
import 'package:flutter_txt_reader/painter/my_painter.dart';
import 'package:flutter_txt_reader/painter/text_builder/edit_builder.dart';

const double TRIGGER_LENGTH = 80.0;
const int animatedMs = 150;

enum TurnPageStatus { lastPage, nextPage, currentPage }

class TurnPage extends StatefulWidget {
  final String text;
  final String nextText;

  final List<NotesContent> defEdit;

  final void Function({String selectText, int start, int end})
      onCommitSelectWord;

//  double dragPosition;
  final MediaQueryData mediaQueryData;
  final bool hasLast;
  final bool hasNext;
  final TurnPageState turnPageState = TurnPageState();

  TurnPage(
      {Key key,
      this.text,
      this.nextText = '',
//      this.dragPosition,
      this.defEdit = const <NotesContent>[],
      this.mediaQueryData,
      this.onCommitSelectWord,
      @required this.hasLast,
      @required this.hasNext})
      : assert(defEdit != null),
        super(key: key);

  @override
  TurnPageState createState() => turnPageState;
}

class TurnPageState extends State<TurnPage> with TickerProviderStateMixin {
  AnimationController _sizeNextController;
  Animation<double> _sizeAnimation;
  double _dragPosition;

  Offset selectStartOffset;

  bool isNext = true;
  bool isNotLock = true;

  int startBoxIndex; // 开始的盒子位置
  int endBoxIndex; // 结束的盒子位置

  int maxBoxIndex;
  int minBoxIndex;

  double oWidth;
  double oHeight;
  double eWidth;
  double eHeight;

  String curTextStr = '';
  String lastTextStr = '';

  Future<TurnPageStatus> newSet() async {
    try {
      TurnPageStatus status;
      isNotLock = false;
      _sizeNextController = AnimationController(
          vsync: this, duration: const Duration(milliseconds: animatedMs));
      if (_dragPosition > TRIGGER_LENGTH) {
        _sizeAnimation =
            _createAnimated(_dragPosition, widget.mediaQueryData.size.width);
        status = TurnPageStatus.lastPage;
      } else if (_dragPosition < -TRIGGER_LENGTH) {
        _sizeAnimation =
            _createAnimated(_dragPosition, -widget.mediaQueryData.size.width);
        status = TurnPageStatus.nextPage;
      } else if (_dragPosition != 0.0) {
        _sizeAnimation = _createAnimated(_dragPosition, 0.0);
        status = TurnPageStatus.currentPage;
      }
//      widget.dragPosition = 0.0;
      setState(() {
        _dragPosition = 0.0;
      });
      await _sizeNextController?.forward();
      _sizeNextController?.dispose();
      _sizeAnimation = null;
      return status;
    } catch (e, r) {
      print('$e \n $r');
    }
  }

  bool Function(int row, int column) _initCurClickLocation(Offset clickPoint) {
    return (int row, int column) =>
        clickPoint.dx >= (column * eWidth + oWidth) &&
        clickPoint.dx <= ((column + 1) * eWidth + oWidth) &&
        clickPoint.dy >= (row * eHeight + oHeight) &&
        clickPoint.dy <= ((row + 1) * eHeight + oHeight);
  }

  bool clickSelect(TapUpDetails details) {
    if (widget.defEdit.isNotEmpty) {
      Offset clickPoint = Offset(details.globalPosition.dx,
          details.globalPosition.dy - widget.mediaQueryData.padding.top);
      bool Function(int row, int column) isCurClick =
          _initCurClickLocation(clickPoint);
      bool isCur = false;
      MyPainter.rangStr(widget.text, callback: (String char,
          {int row,
          int column,
          int fontIndex, // 文字所在索引
          bool breakLine}) {
        int boxIndex = row * COLUMN + column + 1;
        if (boxIndex >= widget.defEdit[0].location.start &&
            boxIndex <= widget.defEdit[0].location.end) {
          if (isCurClick(row, column)) {
            isCur = true;
            widget.onCommitSelectWord(
                selectText: widget.defEdit[0].source,
                start: widget.defEdit[0].location.start,
                end: widget.defEdit[0].location.start);
            return isCur;
          } else if (boxIndex > widget.defEdit[0].location.end) return isCur;
        }
        return null;
      });
      return isCur;
    }
    return false;
  }

  /// 在选择模式下，点击开始触发
  void getSelectStart(DragStartDetails detail) {
    startBoxIndex = endBoxIndex = null;
    Offset p = Offset(detail.globalPosition.dx,
        detail.globalPosition.dy - widget.mediaQueryData.padding.top);
    startBoxIndex = computedBoxIndex(p);
  }

  void getSelectWords(DragUpdateDetails detail) {
    Offset p = Offset(detail.globalPosition.dx,
        detail.globalPosition.dy - widget.mediaQueryData.padding.top);
    endBoxIndex = computedBoxIndex(p);
    int minIndex = min(startBoxIndex, endBoxIndex);
    int maxIndex = max(startBoxIndex, endBoxIndex);
    if (minIndex != minBoxIndex || maxIndex != maxBoxIndex)
      print('$startBoxIndex, $endBoxIndex');
    setState(() {
      minBoxIndex = minIndex;
      maxBoxIndex = maxIndex;
    });
  }

  void selectedEnd() {
//    print('${TextBuilder.startIndex} ${TextBuilder.endIndex}');
//    print(widget.text
//        .substring(TextBuilder.startIndex, TextBuilder.endIndex + 1));
    if (widget.onCommitSelectWord != null)
      widget.onCommitSelectWord(
          selectText: curTextStr, start: minBoxIndex, end: maxBoxIndex);
  }

  int computedBoxIndex(Offset offset) {
    int row = (offset.dy - oHeight) ~/ eHeight;
    int column = (offset.dx - oWidth) ~/ eWidth;
    return row * COLUMN + column + 1;
  }

  Animation<double> _createAnimated(double start, double end) =>
      Tween(begin: start, end: end).animate(
          CurvedAnimation(parent: _sizeNextController, curve: Curves.easeIn))
        ..addListener(() {
          setState(() {});
        });

  void updatePosition(double dragPosition) {
    if (_sizeAnimation == null) {
      if (!widget.hasNext) dragPosition = max(dragPosition, 0.0);
      if (!widget.hasLast) dragPosition = min(dragPosition, 0.0);
      setState(() {
        _dragPosition = dragPosition;
      });
    }
  }

  @override
  void initState() {
    _dragPosition = 0.0;
    double width = widget.mediaQueryData.size.width;
    double height = widget.mediaQueryData.size.height;
    oWidth = width * 0.05;
    oHeight = height * 0.05;
    eWidth = (width - oWidth * 2) / COLUMN;
    eHeight = (height - oHeight * 2) / ROW;
    super.initState();
  }

  @override
  void dispose() {
    if (_sizeNextController?.isAnimating ?? false)
      _sizeNextController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(TurnPage oldWidget) {
    if (oldWidget.text != widget.text) {
      minBoxIndex = maxBoxIndex = 0;
    }
    super.didUpdateWidget(oldWidget);
  }

  void cancelClearEdit() {
    setState(() {
      minBoxIndex = maxBoxIndex = 0;
    });
  }

  /// 已选择的文本
  void setString({String curString, String lastString}) {
    curTextStr = curString;
    lastTextStr = lastString;
  }

  @override
  Widget build(BuildContext context) {
    MediaQueryData mediaQueryData = widget.mediaQueryData;
    double topPadding = mediaQueryData.padding.top;
    double bottomPadding = mediaQueryData.padding.bottom;
    double height = mediaQueryData.size.height - topPadding - bottomPadding;
    double width = mediaQueryData.size.width;
    print('=========>>>>>>> ${widget.text.length}');
    return Stack(
      children: <Widget>[
        Container(
          padding: EdgeInsets.only(top: topPadding, bottom: bottomPadding),
          child: RepaintBoundary(
            child: CustomPaint(
              size: Size(width, height),
              painter: MyPainter(text: widget.nextText),
            ),
          ),
        ),
        Positioned(
          top: 0,
          left: _sizeAnimation?.value ?? _dragPosition,
          child: RepaintBoundary(
            child: Container(
              padding: EdgeInsets.only(top: topPadding, bottom: bottomPadding),
              child: CustomPaint(
                size: Size(width, height),
                painter: MyPainter(text: widget.text),
                child: RepaintBoundary(
                  child: CustomPaint(
                    size: Size(width, height),
                    painter: EditAreaPainter(
                        text: widget.text,
                        endEdit: maxBoxIndex,
                        startEdit: minBoxIndex,
                        renderEditStart: widget.defEdit.isNotEmpty
                            ? widget.defEdit[0].location.start
                            : null,
                        renderEditEnd: widget.defEdit.isNotEmpty
                            ? widget.defEdit[0].location.end
                            : null,
                        onSetString: setString),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
