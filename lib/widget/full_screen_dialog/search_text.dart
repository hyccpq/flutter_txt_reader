import 'dart:math' as Math;

import 'package:flutter/material.dart';
import 'package:flutter_txt_reader/db/document.dart';
import 'package:flutter_txt_reader/model/index_db_base.dart';
import 'package:flutter_txt_reader/widget/full_screen_dialog/widget/item_view.dart';

import 'full_screen_dialog.dart';

class SearchIndex extends StatefulWidget {
  final DB db;
  final String id;

  const SearchIndex({Key key, @required this.db, this.id}) : super(key: key);

  @override
  _SearchIndexState createState() => _SearchIndexState();
}

class _SearchIndexState extends State<SearchIndex> {
  List<IndexDBBase> pageContents = <IndexDBBase>[];
  String str = '';
  List<SearchValue> searchValue = <SearchValue>[];

  Future<Null> searchStr(String str) async {
    pageContents = await widget.db.getBookPageHasOneTotal(widget.id, str);
    print(str);
    final List<SearchValue> searchValues = <SearchValue>[];
    this.str = str;
    if (pageContents.isEmpty) return;
    for (int i = 0; i < pageContents.length; i++) {
      String curText = pageContents[i].content;
      int conLen = curText.length;
      int position = curText.indexOf(str);
      if (position != -1) {
        searchValues.add(SearchValue(
            before: position - 6 > 0
                ? curText.substring(position - 6, position)
                : curText.substring(0, position),
            after: curText.substring(
                position + str.length, Math.min(position + 26, conLen - 1)),
            pageNum: pageContents[i].page));
      }
    }
    setState(() {
      searchValue = searchValues;
    });
  }

  _gotoClickPageNum(int pageNum, BuildContext context) {
    Navigator.pop<int>(context, pageNum);
  }

  @override
  Widget build(BuildContext context) {
    return FullScreenDiaLog(
        title: '全文搜索',
        isShowRightBtn: false,
        child: Column(
          children: <Widget>[
            Container(
                padding: const EdgeInsets.all(20.0),
                child: TextField(
                  autofocus: true,
                  onSubmitted: searchStr,
                  decoration: InputDecoration(
                      contentPadding: const EdgeInsets.only(left: 5.0),
                      icon: Icon(Icons.search),
                      labelText: '请输入您要搜索的内容'),
                )),
            Expanded(
              flex: 1,
              child: ListView(
                children: searchValue
                    .map((item) => ItemView(
                          onTap: () => _gotoClickPageNum(item.pageNum, context),
                          date: '第${item.pageNum}页',
                          advContent: RichText(
                            text: TextSpan(
                                style: TextStyle(color: Colors.black),
                                text: item.before,
                                children: <TextSpan>[
                                  TextSpan(
                                      text: str,
                                      style: TextStyle(
                                          color: Colors.deepOrangeAccent)),
                                  TextSpan(text: item.after + '...')
                                ]),
                          ),
                        ))
                    .toList(),
              ),
            )
          ],
        ));
  }
}

class SearchValue {
  final String before;
  final String after;
  final int pageNum;

  SearchValue({this.before, this.after, this.pageNum});
}
