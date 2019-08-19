import 'package:flutter/material.dart';
import 'package:flutter_reader/widget/full_screen_dialog/full_screen_dialog.dart';
import 'package:flutter_reader/widget/model/index_db_base.dart';

class ViewMark extends StatefulWidget {
  final List<BookMark> bookMarks;
  final void Function(BookMark) onRemoveBookMarks;

  const ViewMark({Key key, this.bookMarks, this.onRemoveBookMarks})
      : super(key: key);

  @override
  _ViewMarkState createState() => _ViewMarkState();
}

class _ViewMarkState extends State<ViewMark> {
  List<BookMark> curBookMarks = [];

  void _gotoThis(BuildContext context, BookMark bookMark) {
    Navigator.pop(context, bookMark);
  }

  @override
  void initState() {
    curBookMarks = widget.bookMarks;
    super.initState();
  }

  @override
  void didUpdateWidget(ViewMark oldWidget) {
    if(oldWidget.bookMarks != widget.bookMarks) curBookMarks = widget.bookMarks;
    super.didUpdateWidget(oldWidget);
  }

  void _removeItem(BookMark item) {
    widget.onRemoveBookMarks(item);
    setState(() {
      curBookMarks.remove(item);
    });
  }

  Widget renderItem(BookMark item, BuildContext context) {
    return Card(
      child: Material(
        child: InkWell(
          onTap: () => _gotoThis(context, item),
          child: Column(
            children: <Widget>[
              Container(
                child: Row(
                  children: <Widget>[
                    Text('第${item.pageNum}页', style: TextStyle(fontSize: 18.0, color: Colors.white)),
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Text('进度${item.progress}%',  style: TextStyle(color: Colors.white)),
                    )
                  ],
                ),
                padding: const EdgeInsets.all(10.0),
                color: Colors.red,
              ),
              Container(padding: const EdgeInsets.all(10.0), child: Column(children: <Widget>[
                Text('${item.bookmarkAbstract}', maxLines: 2,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    IconButton(icon: const Icon(Icons.delete), onPressed: () => _removeItem(item)),
                  ],
                )
              ],),)
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FullScreenDiaLog(
        isShowRightBtn: false,
        title: '添加笔记',
        child: Container(
          padding: const EdgeInsets.all(10.0),
          child: ListView(
            children: widget.bookMarks
                .map((item) => renderItem(item, context))
                .toList(),
          ),
        ));
  }
}
