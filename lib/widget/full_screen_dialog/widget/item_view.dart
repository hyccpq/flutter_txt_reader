import 'package:flutter/material.dart';

class ItemView extends StatelessWidget {
  final String date;
  final String title;
  final String content;
  final int maxLines;
  final VoidCallback onTap;
  final Widget advContent;

  const ItemView(
      {Key key, this.date = '', this.title = '', this.content = '', this.maxLines = 2, this.onTap, this.advContent})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      child: InkWell(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(border: Border(bottom: BorderSide(width: 1.0, color: const Color(0xFFCDCDCD)))),
            padding: EdgeInsets.all(10.0),
            width: double.infinity,
            child: Column(
              children: <Widget>[
                Container(
                  width: double.infinity,
                  child: Text(
                    title,
                    maxLines: 1,
                  ),
                ),
                Container(
                  width: double.infinity,
                  child: advContent ?? Text(
                    content,
                    maxLines: maxLines,
                  ),
                ),
                Container(
                  width: double.infinity,
                  child: Text(
                    date,
                    textAlign: TextAlign.end,
                  ),
                ),
              ],
            )),
      ),
    );
  }
}
