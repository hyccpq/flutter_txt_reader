import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_txt_reader/painter/line_painter/painter_line_area.dart';
import 'package:flutter_txt_reader/tool/tool.dart';
import 'package:flutter_txt_reader/widget/bar_content/bar_content.dart';
import 'package:flutter_txt_reader/widget/bar_content/edit_bar.dart';
import 'package:flutter_txt_reader/widget/turn_page.dart';

import 'db/document.dart';
import 'model/edit_mode.dart';
import 'model/index_db_base.dart';

const double triggerLength = 80.0;
const int paperColor = 0xFFcdb175;
const int activeColor = 0xFFFF8D1A;
enum ReadStatus { readerMode, selectMode, noteModel, eraserMode }
enum IntoDialog { search, addFeel, viewResult, viewBookmarks, viewDirectory }

typedef CommitProcess = void Function(double, int, {bool isPdf});
typedef CommitPageLine = void Function(int, List<LineBase>, {bool isPdf});
typedef CommitSelectWord = void Function(int, BuildContext,
    {String word, int start, int end});
typedef GetLineSelect = LineAndNote Function([int, bool isPdf]);
typedef DeleteSelected = void Function({int index, int pageNum});
typedef GetBookMarks = List<BookMark> Function([int]);
typedef EditMark = void Function(
    {int pageNum, double progress, String bookmarkAbstract, int wordLocation});

class ReadIndex extends StatefulWidget {
  final bool isAdvance;
  final String keyName;
  final int readPage;
  final DB db;
  final CommitProcess onCommitProcess;
  final CommitPageLine onCommitPageLine;
  final CommitSelectWord onCommitSelectWord;
  final DeleteSelected onCommitDeleteSelect;
  final GetLineSelect getLineAndSelect;
  final GetBookMarks getBookMarks;
  final EditMark editMark;
  final void Function(IntoDialog) intoNextDialog;
  final int contentTextLen;
  final int contentTotalPageLen;
  final String fistText;

  const ReadIndex(
      {Key key,
      @required this.keyName,
      @required this.db,
      @required this.getLineAndSelect,
      @required this.onCommitProcess,
      @required this.onCommitPageLine,
      @required this.onCommitSelectWord,
      @required this.fistText,
      this.readPage = 1,
      this.contentTextLen,
      this.contentTotalPageLen,
      this.onCommitDeleteSelect,
      @required this.intoNextDialog,
      this.isAdvance,
      this.getBookMarks,
      this.editMark})
      : assert(readPage != null),
        assert(isAdvance ? getBookMarks != null : true),
        assert(isAdvance ? editMark != null : true),
        super(key: key);

  @override
  ReadIndexState createState() => ReadIndexState();
}

class ReadIndexState extends State<ReadIndex> {
  MediaQueryData mediaQueryData;

  IndexDBBase curPageData;
  IndexDBBase nextPageData;

  List<LineBase> _defLine;
  List<NotesContent> _defEdit = const <NotesContent>[];

  int curPage = 1;
  bool curMarks = false;
  bool hasLast = false;
  bool hasNext = false;
  bool showBar = false;
  bool _isShowLineArea = true;
  bool _isShowEdit = false; // 是否在文本选择的编辑模式
  bool _isDeleteMode = false; // 是否是在删除历史笔记模式
  String editText; // 文本选择的文字
  ReadStatus _readStatus = ReadStatus.readerMode;
  double lastProcess;
  int initializeTimestamp;

  int editStart; // 已选择的起始字符序号
  int editEnd; // 已选择的结束字符序号

  final Map<Type, GestureRecognizerFactory> gestures =
      <Type, GestureRecognizerFactory>{};

  double dragStartPoint;
  double dragPosition = 0.0;

  GlobalKey<TurnPageState> turnPageKey = GlobalKey();
  GlobalKey<PainterLineAreaState> painterLineKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    initializeTimestamp = DateTime.now().millisecondsSinceEpoch; // 本次阅读时间
    _initDBState();
  }

  @override
  void didUpdateWidget(ReadIndex oldWidget) {
    if (oldWidget.readPage != widget.readPage) _initDBState();
    super.didUpdateWidget(oldWidget);
  }

  Future<Null> _initDBState() async {
    BookDBBase doc = await widget.db.getBookLastPage(widget.keyName);
    assert(doc != null);
    LineAndNote lineAndNote = widget.getLineAndSelect(widget.readPage);
    IndexDBBase indexDBBase = await computedPageString(widget.readPage);
    print('${lineAndNote.notes} <<<<<<<<<');
    setState(() {
      if (widget.isAdvance) {
        curMarks = widget.getBookMarks(widget.readPage).isNotEmpty;
      }
      _defEdit = List<NotesContent>.from(lineAndNote.notes) ?? <NotesContent>[];
      _defLine = lineAndNote.lines;
      setCurPage(widget.readPage);
      curPageData = indexDBBase;
    });
  }

  void setCurPage(int pageNum) {
    hasLast = hasNext = false;
    curPage = pageNum;
    if (pageNum != 1) hasLast = true;
    if (pageNum != widget.contentTotalPageLen) hasNext = true;
  }

  /// 读取对应页码的文本
  Future<IndexDBBase> computedPageString(int pageNum) async =>
      await widget.db.getPageContent(widget.keyName, pageNum);

  /// 滑动翻页开始时候操作
  void _startTurnPage() {
    setState(() {
      _isShowLineArea = false; // 隐藏页面的线（防止翻页失败后，对原数据进行重绘）
    });
  }

  /// 翻页结束后的操作
  Future<Null> _turnPageEnd(TurnPageStatus isNext) async {
    if (isNext != TurnPageStatus.currentPage) {
//      List<LineBase> localLines = <LineBase>[];
      _setCurPageInfo();
    } else {
      setState(() {
        _isShowLineArea = true;
      });
    }
  }

  Future<void> _setCurPageInfo() async {
    widget.db.updateBookDoc(widget.keyName, 0, curPage);
    // TODO 获取新页面的笔记，线段等
    LineAndNote lineAndNote = widget.getLineAndSelect(curPage);
    print(lineAndNote?.toString());
    print(lineAndNote.notes);
    setState(() {
      if (widget.isAdvance) {
        curMarks = widget.getBookMarks(curPage).isNotEmpty;
      }
      _defEdit = List<NotesContent>.from(lineAndNote.notes) ?? <NotesContent>[];
      _defLine = lineAndNote.lines ?? <LineBase>[];
      _isShowLineArea = true;
    });
  }

  Future<Null> _panEnd(DragEndDetails detail) async {
    if (_readStatus == ReadStatus.readerMode) {
      TurnPageStatus isNext = await turnPageKey.currentState.newSet();
      setState(() {
        dragPosition = 0.0;
        if (isNext == TurnPageStatus.nextPage ||
            isNext == TurnPageStatus.lastPage) curPageData = nextPageData;
        if (isNext == TurnPageStatus.nextPage)
          setCurPage(curPage + 1);
        else if (isNext == TurnPageStatus.lastPage) setCurPage(curPage - 1);
        _isShowEdit = false;
//        nextPageData = null;
      });
      await _turnPageEnd(isNext);
    } else if (_readStatus == ReadStatus.noteModel) {
      painterLineKey.currentState.moveEndAddLine();
    } else if (_readStatus == ReadStatus.selectMode) {
      turnPageKey.currentState.selectedEnd();
    }
  }

  void _panUpdate(DragUpdateDetails detail) {
    if (_readStatus == ReadStatus.readerMode) {
      double moveDetail = detail.delta.dx;
      double dragDistance = moveDetail + dragPosition;

      if (!hasNext) dragDistance = max(0.0, dragDistance);
      if (!hasLast) dragDistance = min(0.0, dragDistance);

      if (dragPosition == 0.0 && moveDetail != 0.0) _startTurnPage();

      if ((dragPosition == 0.0 && moveDetail > 0 ||
              dragDistance > 0.0 && dragPosition <= 0.0) &&
          hasLast)
        updateNextPageContent(curPage - 1);
      else if ((dragPosition == 0.0 && moveDetail < 0 ||
              dragDistance < 0.0 && dragPosition >= 0.0) &&
          hasNext) updateNextPageContent(curPage + 1);
      turnPageKey.currentState.updatePosition(dragDistance);
      dragPosition = dragDistance;
    } else if (_readStatus == ReadStatus.noteModel) {
      painterLineKey.currentState.moveGestureDetector(detail);
    } else if (_readStatus == ReadStatus.selectMode) {
      turnPageKey.currentState.getSelectWords(detail);
    }
  }

  Future<Null> updateNextPageContent(int pageNum) async {
    IndexDBBase indexDBBase = await computedPageString(pageNum);
    setState(() {
      nextPageData = indexDBBase;
    });
  }

  void _panStart(DragStartDetails detail) {
    if (_readStatus == ReadStatus.noteModel) {
      painterLineKey.currentState.newGestureDetector(detail);
    } else if (_readStatus == ReadStatus.selectMode) {
      turnPageKey.currentState.getSelectStart(detail);
    }
  }

  void _selectMode(ReadStatus readStatus) {
    setState(() {
      if (readStatus == _readStatus)
        _readStatus = ReadStatus.readerMode;
      else
        _readStatus = readStatus;
      _isShowEdit = false;
      _isDeleteMode = false;
      showBar = false;
    });
  }

  String _getModeToString(ReadStatus readStatus) {
    switch (readStatus) {
      case ReadStatus.readerMode:
        return '阅读模式';
      case ReadStatus.selectMode:
        return '勾选模式';
      case ReadStatus.noteModel:
        return '笔记模式';
      default:
        return '未知模式';
    }
  }

  get contentProgress {
//    if(curPageData)
    return (curPageData.startIndex + curPageData.content.length) /
        widget.contentTextLen;
  }

  String _getProcessToString(int pageNum) {
    if (curPageData == null) return '${(1.0 * 100).toStringAsFixed(2)}%';
    print(pageNum);
    double process =
        widget.contentTotalPageLen > pageNum ? contentProgress : 1.0;
    if (lastProcess == null) lastProcess = process; // 第一次获取时候得到上一次进度
    if (lastProcess < process) {
      int duration =
          DateTime.now().millisecondsSinceEpoch - initializeTimestamp;
      widget.onCommitProcess(process, duration ~/ 1000); // 比上一次看的进度多的情况下提交进度
    }

    return '${(process * 100).toStringAsFixed(2)}%';
  }

  void _panTapUp(TapUpDetails details) {
    if (!showBar && _readStatus == ReadStatus.noteModel) {
      bool isPickLine = painterLineKey.currentState.clickLine(details);
      print('选择 $isPickLine');
      if (isPickLine) return;
    } else if (_readStatus == ReadStatus.selectMode) {
      bool isPickSelect = turnPageKey.currentState.clickSelect(details);
      print('选择 $isPickSelect');
      if (isPickSelect) {
        setState(() {
          _isShowEdit = true;
          _isDeleteMode = true;
          if (showBar) showBar = false;
        });
        return;
      } else
        clearCurEdit();
    }
    setState(() {
      showBar = !showBar;
    });
  }

  void _commitCurPageLines(List<LineBase> lines) {
    print(lines);
    widget.onCommitPageLine(curPage, lines);
  }

  void _userEditMode(int val, BuildContext context) async {
    switch (val) {
      case 0:
        Clipboard.setData(ClipboardData(text: editText));
        break;
      case 1:
        if (!_isDeleteMode)
          widget.onCommitSelectWord(curPage, context,
              start: editStart, end: editEnd, word: editText);
        else {
          bool isConfirm = await Tool.showAlert(
              text: '确定删除:\n\"$editText\"的笔记吗？',
              context: context,
              confirmName: '删除');
          if (!isConfirm) return;
          if (widget.onCommitDeleteSelect != null)
            widget.onCommitDeleteSelect(index: 0, pageNum: curPage);
          setState(() {
            _defEdit = _defEdit.where((item) => item != _defEdit[0]).toList();
            print(_defEdit.length);
          });
        }
        clearCurEdit();
        break;
      case 2:
        clearCurEdit();
    }
  }

  void clearCurEdit() {
    turnPageKey.currentState.cancelClearEdit();
    setState(() {
      _isShowEdit = false;
      _isDeleteMode = false;
    });
  }

  // 成功添加笔记
  void addNoteLocation(NotesContent notesContent) {
    setState(() {
      _defEdit.add(notesContent);
    });
  }

  @override
  void dispose() {
    widget.db.close();
    super.dispose();
  }

  void _commitSelectWord({String selectText, int start, int end}) {
    print('选中文字 >> $selectText');
    if (selectText?.length != 0 && selectText != null) {
      editStart = start;
      editEnd = end;
      setState(() {
        editText = selectText;
        _isShowEdit = true;
        _isDeleteMode = false;
      });
    }
  }

  /// 改变mark状态
  void _changeMark() {
    widget.editMark(
        pageNum: curPage,
        progress: contentProgress,
        bookmarkAbstract: curPageData.content.length >= 50
            ? curPageData.content.substring(0, 50)
            : curPageData.content.substring(0, curPageData.content.length - 1),
        wordLocation: curPageData.startIndex + curPageData.content.length + 1);
    setState(() {
      curMarks = !curMarks;
    });
  }

  @override
  Widget build(BuildContext context) {
//    SafeArea
    if (mediaQueryData == null) mediaQueryData = MediaQuery.of(context);
    double safePaddingBottom = mediaQueryData.padding.bottom;
    double screenWidth = mediaQueryData.size.width;
    return Scaffold(
      backgroundColor: Color(paperColor),
      body: BarContent(
        title: '书',
        isAdvance: widget.isAdvance,
        isMarked: curMarks,
        readStatus: _readStatus,
        mediaQueryData: mediaQueryData,
        isShowBar: showBar,
        intoNextDialog: widget.intoNextDialog,
        onChangeMark: _changeMark,
        selectMode: _selectMode,
        child: GestureDetector(
          onTapUp: _panTapUp,
          onPanStart: _panStart,
          onPanEnd: _panEnd,
//          onHorizontalDragUpdate: _horizontalDragUpdate,
          onPanUpdate: _panUpdate,
          child: Stack(
            children: <Widget>[
              TurnPage(
                  key: turnPageKey,
                  text: curPageData?.content ?? widget.fistText,
                  nextText: nextPageData?.content ?? '',
//                dragPosition: dragPosition,
                  onCommitSelectWord: _commitSelectWord,
                  mediaQueryData: mediaQueryData,
                  hasLast: hasLast,
                  hasNext: hasNext,
                  defEdit: _defEdit),
              Positioned(
                  bottom: 0,
                  child: Container(
                    width: screenWidth,
                    padding: EdgeInsets.only(
                        bottom: safePaddingBottom, left: 30.0, right: 30.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(_getModeToString(_readStatus)),
                        Text(_getProcessToString(curPage))
                      ],
                    ),
                  )),
              Opacity(
                opacity: _isShowLineArea ? 1.0 : 0.0,
                child: PainterLineArea(
                  key: painterLineKey,
                  mediaQueryData: mediaQueryData,
                  isNoteMode: _readStatus == ReadStatus.noteModel,
                  commitCurLines: _commitCurPageLines,
                  page: curPage,
                  defLine: _defLine,
                ),
              ),
              _isShowEdit
                  ? Positioned(
                      left: 0.0,
                      right: 0.0,
                      bottom: 0.0,
                      child: Container(
                        padding: EdgeInsets.only(
                            left: screenWidth / 5, right: screenWidth / 5),
                        child: EditBar(
                          userEditMode: _userEditMode,
                          isDeleteMode: _isDeleteMode,
                        ),
                      ),
                    )
                  : Container()
            ],
          ),
        ),
      ),
    );
  }
}
