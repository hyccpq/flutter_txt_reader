import 'package:flutter/material.dart';

import 'full_screen_dialog.dart';

class AddNotes extends StatefulWidget {
  final String notesWord;

  const AddNotes({Key key, this.notesWord}) : super(key: key);

  @override
  _AddNotesState createState() => _AddNotesState();
}

class _AddNotesState extends State<AddNotes> {
  String notes = '';

  void _saveThis(BuildContext context) {
    if (notes.length == 0) {
      Scaffold.of(context).showSnackBar(SnackBar(
        content: const Text('不能提交空的笔记'),
      ));
      return;
    }
    Navigator.pop(context, notes);
  }

  void _changeText(String val) {
    notes = val;
  }

  @override
  Widget build(BuildContext context) {
    return FullScreenDiaLog(
      title: '添加笔记',
      saveThis: () => _saveThis(context),
      child: SafeArea(
        child: Column(
          children: <Widget>[
            Expanded(
              flex: 6,
              child: Container(
                child: Text(widget.notesWord),
              ),
            ),
            Expanded(
              flex: 6,
              child: TextField(
                onChanged: _changeText,
                autofocus: true,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: '请在此处填写您的笔记',
                  labelText: '您的笔记',
                ),
                maxLines: 10,
              ),
            ),
            Expanded(
              flex: 1,
              child: Container(),
            ),
          ],
        ),
      ),
    );
  }
}
