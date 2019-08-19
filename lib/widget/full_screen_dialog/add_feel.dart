import 'package:flutter/material.dart';
import 'package:flutter_reader/widget/full_screen_dialog/full_screen_dialog.dart';
import 'package:flutter_reader/widget/model/index_db_base.dart';

class AddFeel extends StatefulWidget {
  @override
  _AddFeelState createState() => _AddFeelState();
}

class _AddFeelState extends State<AddFeel> {
  String title = '';
  String content = '';

  void _saveThis(BuildContext context) {
    Navigator.pop<FeelContent>(
        context, FeelContent(title: title, content: content));
  }

  void searchStr(String str) {
    title = str;
  }

  void _changeText(String value) {
    content = value;
  }

  @override
  Widget build(BuildContext context) {
    return FullScreenDiaLog(
      title: '添加感悟',
      saveThis: () => _saveThis(context),
      child: Column(
        children: <Widget>[
          Container(
              padding: const EdgeInsets.all(10.0),
              child: TextField(
                autofocus: true,
                onChanged: searchStr,
                decoration: InputDecoration(labelText: '您的标题'),
              )),
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                onChanged: _changeText,
                autofocus: true,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: '请在此处填写您的感悟',
                  labelText: '您的感悟',
                ),
                maxLines: 25,
              ),
            ),
          )
        ],
      ),
    );
  }
}
