import 'package:flutter/material.dart';
import 'package:flutter_reader/widget/full_screen_dialog/full_screen_dialog.dart';
import 'package:flutter_html_view/flutter_html_view.dart';

class ViewFeel extends StatelessWidget {

  final String title;
  final String content;

  const ViewFeel({Key key, this.title, this.content}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FullScreenDiaLog(
      title: '查看感悟',
      isShowRightBtn: false,
      child: Column(
        children: <Widget>[
          Container(
              padding: const EdgeInsets.all(10.0),
              child: Text(title, textAlign: TextAlign.center,)),
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: HtmlView(
                data: content,
              ),
            ),
          )
        ],
      ),
    );
  }
}
