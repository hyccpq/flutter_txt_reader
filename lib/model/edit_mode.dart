class NotesContent {
  final String content;
  final Location location;
  final String source;
  final String createDate;

  NotesContent(
      {this.createDate,
        this.content,
      this.location,
      this.source});
}

class Location {
  final int page;
  final int start;
  final int end;

  Location({this.page, this.start, this.end});

  Location.stringToThis(String str)
      : this(
            page: int.parse(str.split(',')[0]),
            start: int.parse(str.split(',')[1]),
            end: int.parse(str.split(',')[2]));

  @override
  String toString() => '$page,$start,$end';
}
