import 'dart:convert';
import 'dart:ui';

import 'package:flutter_reader/widget/model/edit_mode.dart';

Offset createOffset(dynamic json) =>
    Offset(json['dx'].toDouble(), json['dy'].toDouble());

Map<String, dynamic> offsetToJson(Offset offset) =>
    {'dy': offset?.dy ?? 0, 'dx': offset?.dx ?? 0};

class IndexDBBase {
  int page;
  int startIndex;
  String content;

  IndexDBBase({this.page, this.startIndex, this.content});

  IndexDBBase.fromMap(Map<String, dynamic> map) {
    print(map);
    page = map['page'];
    startIndex = map['start_index'];
    content = map['content'];
  }
}

class BookDBBase {
  int last_read_pos;
  int last_read_page;
  int total_page_num;
  int total_size;
  String book_dir;

  BookDBBase(
      {this.last_read_pos,
      this.last_read_page,
      this.total_page_num,
      this.total_size,
      this.book_dir});

  BookDBBase.fromMap(Map<String, dynamic> map) {
    last_read_pos = map['last_read_pos'];
    last_read_page = map['last_read_page'];
    total_page_num = map['total_page_num'];
    total_size = map['total_size'];
    book_dir = map['book_dir'];
  }
}

class LocalLineBase {
  final List<Offset> moves;
  final int pathColor;
  final double paintWidth;
  final int oX;
  final int oY;

  LocalLineBase(this.moves, this.pathColor, this.paintWidth,
      {this.oX = 0, this.oY = 0});
}

class LineBase extends LocalLineBase {
  final int page;
  final Offset start;
  final Offset end;
  final double mStandardW;
  final double mStandardH;
  final bool isEraser;

  LineBase(
      {this.isEraser = false,
      this.page,
      this.end,
      this.start,
      moves,
      this.mStandardH,
      this.mStandardW,
      paintWidth,
      pathColor,
      oX,
      oY})
      : super(moves, pathColor, paintWidth, oX: oX, oY: oY);

  factory LineBase.fromJson(dynamic json) => new LineBase(
        isEraser: json["isEraser"],
        end: createOffset(json["end"]),
        oX: json["oX"],
        start: createOffset(json["start"]),
        mStandardH: json["mStandardH"] is double ? json["mStandardH"] : json["mStandardH"].toDouble(),
        pathColor: json["paintColor"] is int ? json["paintColor"] : int.parse(json["paintColor"], radix: 16),
        moves: new List<Offset>.from(json["moves"].map((x) => createOffset(x))),
        mStandardW: json["mStandardW"] is double ? json["mStandardW"] : json["mStandardW"].toDouble(),
        oY: json["oY"],
        paintWidth: json["paintWidth"] is double ? json["paintWidth"] : json["paintWidth"].toDouble(),
      );

  Map<String, dynamic> toJson() => {
    "isEraser": isEraser,
    "end": offsetToJson(end),
    "oX": oX,
    "start": offsetToJson(start),
    "mStandardH": mStandardH,
    "paintColor": pathColor.toRadixString(16).padLeft(6, '0'),
    "moves": new List<dynamic>.from(moves.map((x) => offsetToJson(x))),
    "mStandardW": mStandardW,
    "oY": oY,
    "paintWidth": paintWidth,
  };
}

class PointF {
  final x;
  final y;

  PointF(this.x, this.y);
}

class LineAndNote {
  final List<LineBase> lines;
  final List<NotesContent> notes;

  LineAndNote({this.lines = const <LineBase>[], this.notes});

  @override
  String toString() {
    return lines.toString();
  }
}

class FeelContent {
  String title;
  String content;
  String createDate;

  FeelContent({this.title, this.content, this.createDate});
}

class BookMark {
  final int pageNum;

  final int wordLocation;

  final String bookmarkAbstract;

  final double progress;

  BookMark(
      {this.pageNum, this.wordLocation, this.bookmarkAbstract, this.progress});
}

List<BookDirectoryModel> bookMarksFromJson(String str) {
  if (str.isEmpty) return <BookDirectoryModel>[];
  return new List<BookDirectoryModel>.from(
      json.decode(str).map((x) => BookDirectoryModel.fromJson(x)));
}

String bookMarksToJson(List<BookDirectoryModel> data) =>
    json.encode(new List<dynamic>.from(data.map((x) => x.toJson())));

class BookDirectoryModel {
  String title;
  int pageNum;

  BookDirectoryModel({
    this.title,
    this.pageNum,
  });

  factory BookDirectoryModel.fromJson(Map<String, dynamic> json) =>
      new BookDirectoryModel(
        title: json["title"],
        pageNum: json["pageNum"],
      );

  Map<String, dynamic> toJson() => {
        "title": title,
        "pageNum": pageNum,
      };
}
