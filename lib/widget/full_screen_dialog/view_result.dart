import 'package:flutter/material.dart';
import 'package:flutter_txt_reader/model/edit_mode.dart';
import 'package:flutter_txt_reader/model/index_db_base.dart';
import 'package:flutter_txt_reader/tool/tool.dart';
import 'package:flutter_txt_reader/widget/full_screen_dialog/view_feel.dart';
import 'package:flutter_txt_reader/widget/full_screen_dialog/widget/item_view.dart';

import 'full_screen_dialog.dart';

enum ViewResultStatus { feel, note }

typedef CommitEditNoteOrFeel = void Function(int, ViewResultStatus);

class ViewResult extends StatefulWidget {
  final List<NotesContent> notes;
  final List<FeelContent> feels;
  final CommitEditNoteOrFeel onCommitEditNoteOrFeel;

  const ViewResult(
      {Key key,
      @required this.notes,
      @required this.feels,
      @required this.onCommitEditNoteOrFeel})
      : super(key: key);

  @override
  _ViewResultState createState() => _ViewResultState();
}

class _ViewResultState extends State<ViewResult>
    with SingleTickerProviderStateMixin {
  final List<Tab> viewTab = <Tab>[
    Tab(
      text: '心得体会',
    ),
    Tab(
      text: '读书笔记',
    )
  ];

  List<NotesContent> notes = <NotesContent>[];
  TabController _tabController;

  @override
  void initState() {
    super.initState();
    notes = widget.notes;
    _tabController = TabController(vsync: this, length: viewTab.length);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

//  @override
//  void didUpdateWidget(ViewResult oldWidget) {
//    if(oldWidget.notes != widget.notes) notes ??= widget.notes;
//    super.didUpdateWidget(oldWidget);
//  }

  Future<Null> _removeNoteList(int index) async {
    bool isConfirm = await Tool.showAlert(
        text: '确定删除:\n\"${notes[index].source}\"的笔记吗？',
        context: context,
        confirmName: '删除');
    if (!isConfirm) return;
    widget.onCommitEditNoteOrFeel(index, ViewResultStatus.note);
    setState(() {
      notes.removeAt(index);
    });
  }

  void viewFeel(FeelContent item, BuildContext context) {
    Navigator.push(
        context,
        MaterialPageRoute<FeelContent>(
          builder: (BuildContext context) =>
              ViewFeel(title: item.title, content: item.content),
          fullscreenDialog: true,
        ));
  }

  @override
  Widget build(BuildContext context) {
    return FullScreenDiaLog(
      bottom: TabBar(
        controller: _tabController,
        tabs: viewTab,
      ),
      title: '查看记录',
      isShowRightBtn: false,
      child: TabBarView(
        controller: _tabController,
        children: <Widget>[
          ListView(
            children: widget.feels
                .map((item) => ItemView(
                      onTap: () => viewFeel(item, context),
//                  onTap: () => widget.onCommitEditNoteOrFeel(widget.feels.indexOf(item), ViewResultStatus.feel),
                      title: item.title,
                      content: item.content,
                      date: item.createDate,
                    ))
                .toList(),
          ),
          ListView(
            children: notes
                .map((item) => ItemView(
                      onTap: () => _removeNoteList(notes.indexOf(item)),
                      title: item.source,
                      content: item.content,
                      date: item.createDate,
                    ))
                .toList(),
          )
        ],
      ),
    );
  }
}
